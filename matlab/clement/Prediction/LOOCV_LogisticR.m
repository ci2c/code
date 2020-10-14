function [pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

%% edited by Clément Bournonville, CHU Lille - Ci2C - Apr 2017


% performance vector
perform_mat = [];
lambd = [];
bestlambda = [];
%
loo=@(i,x) x([[1:i-1] [i+1:size(x,1)]],:); %  this leaves input i out


opts.fName='LogisticR'; 
pred = [];
L=length(Lambda);
% begin cross validation
fprintf('Starting LOOCV for Logistic Regression... ')

for i = 1:length(Y)
    disp(i)
    
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    [xy,yy,~] = size(Y_out);
    
   %%% COMPUTATION %%% 

   [W,c] = pathSolutionLogistic(X_k, Y_k, Lambda, opts);
   %%%             %%%
   
   
   errl=zeros(1,L);
   for l = 1: L
       y_pred = X_out * W(:,l);
       predb = y_pred;
       predb(y_pred < 0) = -1;
       predb(y_pred > 0) = 1;
       tmp = predb - Y_out;
       
       errl(l) = (predb == Y_out);      
   end
   
   id = find(errl == 1);
   if ~isempty(id)    
    bestlambda(end+1)=mean(id); 
   end
   
end

Opt_lambda = floor(mean(bestlambda));
   
for i = 1:length(Y)
    X_k=loo(i,X);
    Y_k=loo(i,Y);    
    
    X_out = X(i,:);
    Y_out = Y(i,:);
    
    [W, ~, ~]= LogisticR(X_k, Y_k, Lambda(Opt_lambda), opts);
    
    tmpred = [W' * X_out']' / abs([W' * X_out']');
    
    pred(i,:) = (Y_out == tmpred);   

end



[W, ~, ~]= LogisticR(X, Y, Opt_lambda, opts);

fprintf('... End of LOOCV')