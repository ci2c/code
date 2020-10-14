function varargout = DynamicFunctionalConnectivityAnalysis(tseries,varargin)

% usage : varargout = DynamicFunctionalConnectivityAnalysis(tseries,varargin)
%
% Inputs :
%    tseries       : BOLD time-courses [nodes x Time]
%
% Options
%    TR            : TR value (Default: 2)
%    detrendNumber : do detrending if value > 0 (Default: 3)
%    tc_filter     : do filtering if value > 0 (Default: 0.15)
%    Despiking     : do despiking (Default: no)
%    window_alpha  : (Default: 3)
%    wsize         : window size (Default: 30)
%    numRepet      : (Default: 10)
%    method        : type of correlation ("correlation" - "L1" - "kalman") (Default: 'correlation') 
%
% Output :
%    FNCdyn        : Dynamic BOLD connectivity
%    blambda       : Best lambda
%    c             : 
%    A             :
%    epi           : preprocessed epi
%
% Renaud Lopes @ CHRU Lille, Oct. 2013


%% ----------default arguments-----------
Args = struct('TR',2, ...
            'wsize',30, ... 
            'detrendNumber',3, ...
            'window_alpha',3, ...
            'method','correlation', ...
            'numRepet',10, ...
            'tc_filter',0.15, ...
            'Covariates','', ...
            'Despiking','no');

Args = parseArguments(varargin,Args,{'BlackandWhite'});

tic

[numVox,nT] = size(tseries);


%% ========================================================================
%%                            Preprocess...
%% ========================================================================

% Detrending...
if (Args.detrendNumber>0)
    
    tseries = icatb_detrend(tseries, 1, [], Args.detrendNumber);
    
end

% Regress covariates
if ~isempty(Args.Covariates)
    
    file_name = deblank(Args.Covariates);
    X = icatb_load_ascii_or_mat(file_name);
    X = icatb_zscore(X);
    betas = pinv(X)*tseries;
    % Remove variance associated with the covariates
    tseries = tseries - X*betas;
    
end

% Despiking and filtering...
if (strcmpi(Args.Despiking, 'yes')) || (Args.tc_filter > 0)
    for vox = 1:numVox

        current_tc = squeeze(tseries(vox, :));

        % Despiking timecourses
        if (strcmpi(Args.Despiking, 'yes'))
            current_tc = icatb_despike_tc(current_tc, Args.TR);
        end
        
        % Filter timecourses
        if (Args.tc_filter > 0)
            current_tc = icatb_filt_data(current_tc, Args.TR, Args.tc_filter);
        end

        tseries(vox,:) = current_tc;

    end
end
    
%% ========================================================================
%%                   Compute dynamic FNC of time-courses
%% ========================================================================

% Windows
c = compute_sliding_window(nT, Args.window_alpha, Args.wsize);
A = repmat(c, 1, numVox);

Nwin = nT - Args.wsize;
initial_lambdas = (0.1:.03:.40);
    
FNCdyn  = zeros(Nwin, numVox*(numVox - 1)/2);
Lambdas = zeros(Args.numRepet, length(initial_lambdas));
blambda = 0;

% Apply circular shift to timecourses
tcwin   = zeros(Nwin, nT, numVox);
tseries = tseries';
for ii = 1:Nwin
    Ashift = circshift(A, round(-nT/2) + round(Args.wsize/2) + ii);
    tcwin(ii, :, :) = tseries.*Ashift;
end
windowTimes = zeros(1,nT);
windowTimes(round(nT/2)+round(-nT/2)+round(Args.wsize/2)+[1:Nwin]) = 1;

% Dynamic connectivity
if strcmpi(Args.method, 'L1')

    useMEX = 0;

    try
        GraphicalLassoPath([1, 0; 0, 1], 0.1);
        useMEX = 1;
    catch
    end

    %disp('Using L1 regularisation ...');

    % L1 regularisation
    Pdyn = zeros(Nwin, numVox*(numVox - 1)/2);

    %fprintf('\t rep ')
    % Loop over no of repetitions
    for r = 1:Args.numRepet
        %fprintf('%d, ', r)
        [trainTC, testTC] = split_timewindows(tcwin, 1);
        trainTC = icatb_zscore(trainTC);
        testTC = icatb_zscore(testTC);
        [wList, thetaList] = computeGlasso(trainTC, initial_lambdas, useMEX);
        obs_cov = icatb_cov(testTC);
        L = cov_likelihood(obs_cov, thetaList);
        Lambdas(r, :) = L;
    end

    %fprintf('\n')
    [mv, minIND] =min(Lambdas, [], 2);
    blambda = mean(initial_lambdas(minIND));
    %fprintf('\tBest Lambda: %0.3f\n', blambda)

    % now actually compute the covariance matrix
    %fprintf('\tWorking on estimating covariance matrix for each time window...\n')
    for ii = 1:Nwin
        %fprintf('\tWorking on window %d of %d\n', ii, Nwin)
        [wList, thetaList] = computeGlasso(icatb_zscore(squeeze(tcwin(ii, :, :))), blambda, useMEX);
        a = icatb_corrcov(wList);
        a = a - eye(numVox);
        FNCdyn(ii, :) = mat2vec(a);
        InvC = -thetaList;
        r = (InvC ./ repmat(sqrt(abs(diag(InvC))), 1, numVox)) ./ repmat(sqrt(abs(diag(InvC)))', numVox, 1);
        r = r + eye(numVox);
        Pdyn(ii, :) = mat2vec(r);
    end

    %FNCdyn = atanh(FNCdyn);

elseif strcmpi(Args.method, 'correlation')
    
    % No L1
    for ii = 1:Nwin
        a = icatb_corr(squeeze(tcwin(ii, :, :)));
        FNCdyn(ii, :) = mat2vec(a);
    end
    %FNCdyn = atanh(FNCdyn);
    Pdyn = [];

end

% disp('Done');
% fprintf('\n');

totalTime = toc;

% fprintf('\n');


%% ========================================================================
%%                            Outputs
%% ========================================================================

varargout={FNCdyn,windowTimes,blambda,tcwin,A,Pdyn};
varargout=varargout(1:nargout);

disp('Analysis Complete');

disp(['Total time taken to complete the analysis is ', num2str(totalTime/60), ' minutes']);

diary('off');

% fprintf('\n');


function c = compute_sliding_window(nT, win_alpha, wsize)
%% Compute sliding window
%

nT1 = nT;
if mod(nT, 2) ~= 0
    nT = nT + 1;
end

m = nT/2;
w = round(wsize/2);
%if (strcmpi(win_type, 'tukey'))
%    gw = icatb_tukeywin(nT, win_alpha);
%else
gw = gaussianwindow(nT, m, win_alpha);
%end
b = zeros(nT, 1);  b((m -w + 1):(m+w)) = 1;
c = conv(gw, b); c = c/max(c); c = c(m+1:end-m+1);
c = c(1:nT1);


function [vec, IND] = mat2vec(mat)
% vec = mat2vec(mat)
% returns the lower triangle of mat
% mat should be square

[n,m] = size(mat);

if n ~=m
    error('mat must be square!')
end


temp = ones(n);
%% find the indices of the lower triangle of the matrix
IND = find((temp-triu(temp))>0);

vec = mat(IND);


% function w = gaussianwindow(N,x0,sigma)
%
% x = 0:N-1;
% w = exp(- ((x-x0).^2)/ (2 * sigma * sigma))';


function L = cov_likelihood(obs_cov, theta)
% L = cov_likelihood(obs_cov, sigma)
% INPUT:
% obs_cov is the observed covariance matrix
% theta is the model precision matrix (inverse covariance matrix)
% theta can be [N x N x p], where p lambdas were used
% OUTPUT:
% L is the negative log-likelihood of observing the data under the model
% which we would like to minimize

nmodels = size(theta,3);

L = zeros(1,nmodels);
for ii = 1:nmodels
    % log likelihood
    theta_ii = squeeze(theta(:,:,ii));
    L(ii) = -log(det(theta_ii)) + trace(theta_ii*obs_cov);
end

function [trainTC, testTC] = split_timewindows(TCwin, ntrain)
%[Nwin, nT, nC] = size(TCwin);


[Nwin, nT, nC] = size(TCwin);

r = randperm(Nwin);
trainTC = TCwin(r(1:ntrain),:,:);
testTC = TCwin(r(ntrain+1:end),:,:);

trainTC = reshape(trainTC, ntrain*nT, nC);
testTC = reshape(testTC, (Nwin-ntrain)*nT, nC);


function w = gaussianwindow(N,x0,sigma)

x = 0:N-1;
w = exp(- ((x-x0).^2)/ (2 * sigma * sigma))';


function [wList, thetaList] = computeGlasso(tc, initial_lambdas, useMEX)
%% Compute graphical lasso


if (useMEX == 1)
    [wList, thetaList] = GraphicalLassoPath(tc, initial_lambdas);
else
    tol = 1e-4;
    maxIter = 1e4;
    S = icatb_cov(tc);
    thetaList = zeros(size(S, 1), size(S, 2), length(initial_lambdas));
    wList = thetaList;
    
    for nL = 1:size(wList, 3)
        [thetaList(:, :, nL), wList(:, :, nL)] = icatb_graphicalLasso(S, initial_lambdas(nL), maxIter, tol);
    end
    
end


function tc = regress_cov(tc, X)
%% Regress covariates from timecourses
%

scansToInclude = (1:size(X, 1));

scansToInclude(scansToInclude > size(X, 1)) = [];

X = icatb_zscore(X);

X = X(scansToInclude, :);

if (size(X, 1) ~= size(tc, 1))
    error('Please check the timepoints');
end

% Include temporal derivatives as well
%X = [X, [zeros(1, size(X, 2)); diff(X)]];

betas = pinv(X)*tc;

% Remove variance associated with the covariates
tc = tc - X*betas;
