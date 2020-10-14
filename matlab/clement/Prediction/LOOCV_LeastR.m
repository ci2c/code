function [pred,W,Opt_lambda] = LOOCV_LeastR( X, Y, opts, Lambda)

%% edited by Clément Bournonville, CHU Lille - Ci2C - Feb 2017


% performance vector
perform_mat = [];
lambd = [];
bestlambda = [];
%
loo=@(i,x) x([[1:i-1] [i+1:size(x,1)]],:); %  this leaves input i out


opts.fName='LeastR'; 
pred = [];
L=length(Lambda);
% begin cross validation
fprintf('Starting LOOCV for Multitask Learning... ')

for i = 1:length(Y)
    disp(i)
    
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    
   %%% COMPUTATION %%% 

   W = pathSolutionLeast(X_k, Y_k, Lambda, opts);
   %%%             %%%
   
   errl=zeros(1,L);
   for l = 1: L
       y_pred = X_out * W(:,l);
       errl(l) = ( sum( (y_pred - Y_out).^2 ) ) / L;     
   end
   
   plot(Lambda, errl);
   hold on
   [~,bestL]=min(errl);
   bestlambda(end+1)=Lambda(bestL); 
   
end

Opt_lambda = mean(bestlambda);
   
for i = 1:length(Y)
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    [W, ~, ~]= LeastC(X_k, Y_k, Opt_lambda, opts);
   
    pred(i,:) = [W' * X_out']';   
end

[W, ~, ~]= LeastR(X, Y, Opt_lambda, opts);

fprintf('... End of LOOCV')