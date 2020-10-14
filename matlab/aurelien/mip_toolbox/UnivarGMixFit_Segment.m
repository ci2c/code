function [Im_out,logL_K,bic_K] = UnivarGMixFit_Segment(Im_in,K,transformtype)
% UNIVARGMIXFIT_SEGMENT  Image segmentation via Gaussian/normal mixture
% modeling
%
%   [IM_OUT,lOGL_K,BIC_K] =
%   UNIVARGMIXFIT_SEGMENT(IIM_IN,K,TRANSFORMTYPE)
%
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin==1
    K = 2; transformtype = 1;
elseif nargin==2
    transformtype = 1;
end
data = double(Im_in(:)); n = length(data); % data is nx1
 
switch transformtype
%   case 1 data = data; No tranform, default
    case 2 % log-tranform
        % avoid log of zero by shifting pixel values by 1
        data = log(1+data);
    case 3 % Cube-root
        data = data.^(1/3);
    case 4 % Scaling by SD
        data = data/mystd(data,n);
end
 
% Efficient initialization for k-means using quantiles
sorted_data = sort(data);
quantile_lims = zeros(1,K);
delta_q = 1/K; quantile_start = delta_q/2;
quantile_lims = quantile_start:delta_q:1;
mues_in = sorted_data(round(n*quantile_lims))';
% An alternative way of finding the initial means
% by using the prctile function could be as follows
% K2 = 2*K; mues_in = prctile(data,(1:2:K2)*100/K2)
 
% Efficient initialization for EM using k-means
pies_in = zeros(1,K); sum_k = zeros(1,K);
iter = 0; idx = zeros(n,1); idx_old = ones(n,1);
while ~isequal(idx,idx_old) & iter < 25
    idx_old = idx;
    [dummy_values,idx] = min(abs(repmat(data,1,K)…
                             -repmat(mues_in,n,1)),[],2);
    for i = 1:K
        idx_k = find(idx==i);
        pies_in(i) = length(idx_k);
        mues_in(i) = sum(data(idx_k))/pies_in(i);
    end        
    iter = iter+1;
end
 
% EM
fprintf('Mixture Model via EM\n')
pies_in = pies_in/n; vars_in = zeros(1,K);
for i = 1:K
    idx_k = find(idx==i);
    vars_in(i) = var(data(idx_k));
end
posterior_probs = zeros(n,K);
pies_up = zeros(1,K);
mues_up = zeros(1,K);
vars_up =  zeros(1,K);
iter = 0; deltol = 10;
while iter < 200 & deltol > 1e-5
    for i = 1:K
        posterior_probs(:,i) = …
                pies_in(i)*normpdfvar(data,mues_in(i),vars_in(i));
    end
    totprob = sum(posterior_probs,2);
    posterior_probs = posterior_probs./repmat(totprob,1,K);
    postsum = sum(posterior_probs);
    pies_up = postsum/n;
    mues_up = (data'*posterior_probs)./postsum;
    for i = 1:K
        xx = (data-mues_in(i)).^2; % centered data for class_k
        vars_up(i) = xx'*posterior_probs(:,i)/postsum(i);
    end
    % quit if any of the estimated component vars is close 0
    if any(vars_up<eps), break, end
    % check the relative change in weights
    deltol = abs(pies_in(1)-pies_up(1))/pies_in(1);
    % update mixture model param.s
    pies_in = pies_up;
    mues_in = mues_up;
    vars_in = vars_up;
    % finally, update the iteration count
    iter = iter+1;
end
fprintf('Mixture model converged after %d iterations...\n',iter)
sigs_up = sqrt(vars_up);
fprintf('Weights: '), fprintf('%.4f\t',pies_up); fprintf('\n')
fprintf('Means: '), fprintf('%.4f\t',mues_up); fprintf('\n')
fprintf('SDs: '), fprintf('%.4f\t',sigs_up); fprintf('\n')
 
% number of model parameters is K*(1+d+d*(d+1)/2)-1
% with d (data dimensionality) being 1
num_params = 3*K-1;
% log likelihood
logL_K = sum(log(totprob))
bic_K = -2*logL_K + num_params*log(n);

% % Nelder-Mead Simplex Search (uncomment to activate)
% % requires the Matlab’s optimization toolbox
% theta0 = [pies_in(1:K-1) mues_in vars_in];
% fprintf('Mixture Model via Nelder-Mead Simplex Search\n')
% [thetamin,Lmin] = fminsearch(@myloglikelihood,theta0,optimset(…
      'MaxFunEvals',3000,'TolX',1e-5,'TolF',1e-5),data,K,n); -Lmin
% pies = thetamin(1:K-1);
% pies_last = 1-sum(pies);
% pies_all = [pies pies_last];
% fprintf('Weights: ')
% fprintf('%.4f\t',pies_all); fprintf('\n')
% fprintf('Means: ')
% fprintf('%.4f\t',thetamin(K:2*K-1)); fprintf('\n')
% fprintf('SDs: ')
% fprintf('%.4f\t',sqrt(thetamin(2*K:end))); fprintf('\n')

% Generate the labeled/segmented image based on posterior prob.s
Im_out = Im_in;
% take the max along the second dim (rows)
[dummy_values,Im_out(:)] = max(posterior_probs,[],2); 
% Produce histogram pdf and mixture pdf plots
figure(1)
bin_centers = 0:255;
% make the hist pdf estimate plot first
myhist(data,n,bin_centers), hold on
 
line_colors = ['k';'b';'m';'c';'g';'y']; Lc = length(line_colors); % colors for plotting different mixture components
fitpdf = zeros(K,256);
for i = 1:K
    fitpdf(i,:) = pies_up(i)*…
                  normpdfvar(bin_centers,mues_up(i),vars_up(i));
    % cycle plot colors
    plot(bin_centers,fitpdf(i,:),line_colors(mod(i,Lc)))
end
plot(bin_centers,sum(fitpdf),'r'), hold off
xlabel('Pixel value'), ylabel('Probability')
title('Histogram estimate of pixel values pdf…
       and weighted mixture model components')
if K == 4 % this is the correct/optimal number of components
    set(gca,'ylim',[0 0.035])
    legend('Histogram','Component 1','Component 2',…
           'Component 3','Component 4','Overall mix. model fit')
end
 
figure
% Assess quality of mixture model’s fit to data's pdf using qqplot
model_data = []; n_qq = 400;
for i = 1:K
    ni = round(n_qq*pies_up(i));
    % generate random data from ith component
    xi = randn(ni,1); xi = (xi-mean(xi))/std(xi);
    xi = mues_up(i) + sigs_up(i)*xi;
    % Aggragate the simulated new model data
    model_data = [model_data; xi]; 
end
size(model_data) % initial size (should be n_qq which is 400)
% Remove pixels with values <0 or >255 from the random data
model_data = model_data(model_data>=0 & model_data<=255);
size(model_data) % size of the random data after cleanup
qqplot(data,model_data)
xlabel('Quantiles of Actual Pixel Values')
ylabel('Quantiles of Random Data from Mixture Model')
axis equal, axis([0 255 0 255])
title ('QQ Plot of Random Data from Mixture Model…
        versus Actual Pixel Values')
 
function p = normpdfvar(x,mu,xvar)
p = exp(-(x-mu).^2/(2*xvar))/sqrt(xvar*2*pi);
 
function y = mystd(x,n)
if n == 1, y = NaN; return, end
y = sqrt(sum((x-mymean(x,n)).^2)/(n-1));
 
function y = mymean(x,n)
y = sum(x)/n;
 
function myhist(data,n,bin_centers)
bin_counts = hist(data,bin_centers);
ah = bar(bin_centers,bin_counts/n,1);
set(ah,'facecolor',[1 1 1],'edgecolor',[.5 .5 .5]), axis tight
 
function L = myloglikelihood(theta,data,K,n)
pies = theta(1:K-1); pies_last = 1-sum(pies); pies_all = [pies pies_last];
mues = theta(K:2*K-1);
vars = theta(2*K:end); % end = 3*K-1
y = zeros(n,1);
for i = 1:K
    y = y + pies_all(i)*normpdfvar(data,mues(i),vars(i));
end
L = -sum(log(y));
