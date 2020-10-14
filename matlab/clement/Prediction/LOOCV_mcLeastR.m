function [pred,W,Opt_lambda] = LOOCV_mcLeastR( X, Y, opts, Lambda)

%% edited by Clément Bournonville, CHU Lille - Ci2C - Feb 2017


% performance vector
perform_mat = [];
lambd = [];
bestlambda = [];
%
loo=@(i,x) x([[1:i-1] [i+1:size(x,1)]],:); %  this leaves input i out


opts.fName='mcLeastR'; 
pred = [];
L=length(Lambda);
% begin cross validation
fprintf('Starting LOOCV for Multitask Learning... ')

[Yx,~,~] = size(Y);


for i = 1:Yx
    
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    
   %%% COMPUTATION %%% 

   W = pathSolutionLeast(X_k, Y_k, Lambda, opts);
   %%%             %%%
   
   errl=zeros(1,L);
   for l = 1: L
       y_pred = X_out * W(:,:,l);
       errl(l) = ( sum( (y_pred - Y_out).^2 ) ) / L;     
   end
   
   plot(Lambda, errl);
   hold on
   [~,bestL]=min(errl);
   bestlambda(end+1)=Lambda(bestL); 
   
end

Opt_lambda = mean(bestlambda);
   
for i = 1:Yx
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    [W, ~, ~]= mcLeastR(X_k, Y_k, Opt_lambda, opts);
    
    % Liear fitting of the training set (Following Yourganov 2016)
    tmp = [W' * X_k']'; 
    p = polyfit(Y_k(:),tmp(:),1);
    %

    tmpred = [W' * (X_out'/max(X_k(:)))]' * p(1) + p(2); % Normalization following Youganov 2016
   
    pred(i,:) = tmpred; 
    
end

[W, ~, ~]= mcLeastR(X, Y, Opt_lambda, []);

fprintf('... End of LOOCV \n')