 function [pred,W,Opt_lambda] = LOOCV_MTL( X, Y, obj_func_str, obj_func_opts, Lambda, eval_func_str, higher_better)

%% edited by Clément Bournonville, CHU Lille - Ci2C - Feb 2017
 
%%
eval_func = str2func(eval_func_str);
obj_func  = str2func(obj_func_str);

% compute sample size for each task
task_num = length(X);

% performance vector
perform_mat = [];
lambd = [];
bestlambda = [];
%
loo=@(i,x) x([[1:i-1] [i+1:size(x,1)]],:); %  this leaves input i out

X_k = cell(task_num, 0);
Y_k = cell(task_num, 0);
X_out = cell(task_num, 0);
Y_out = cell(task_num, 0);

pred = zeros(length(Y{1}),task_num);
L=length(Lambda);
% begin cross validation
fprintf('Starting LOOCV for Multitask Learning... ')

for i = 1:length(Y{1})
    disp(i)
    for t=1:task_num 
        xTr = X{t};
        yTr = Y{t};
        
        oxTr=loo(i,xTr);
        oyTr=loo(i,yTr);    

        X_k{t} = oxTr;
        Y_k{t} = oyTr;
        X_out{t} = X{t}(i,:);
        Y_out{t} = Y{t}(i,:);
    end
    
   errl=zeros(1,L);
   for l = 1: length(Lambda)
        W = Least_Trace(X_k, Y_k, Lambda(l), obj_func_opts);
        sW(l) = sum(W(:));
        errl(l) = eval_func(Y_out, X_out, W);
   end
   errl = errl(sW ~= 0);
   
   [~,bestL]=min(errl);
   bestlambda(end+1)=Lambda(bestL); 
   
end

Opt_lambda = mean(bestlambda);
   
for i = 1:length(Y{1})
    for t=1:task_num 
        xTr = X{t};
        yTr = Y{t};
        
        oxTr=loo(i,xTr);
        oyTr=loo(i,yTr);    

        X_k{t} = oxTr;
        Y_k{t} = oyTr;
        X_out{t} = X{t}(i,:);
        Y_out{t} = Y{t}(i,:);
    end
    
    W = Least_Trace(X_k, Y_k, Opt_lambda, obj_func_opts);
   
    pred(i,:) = [W' * X_out{1}']';   
end

W = Least_Trace(X, Y, Opt_lambda, obj_func_opts);

fprintf('... End of LOOCV')
y = [Y{1} Y{2} Y{3} Y{4} Y{5} Y{6} Y{7}];
plot(y,pred,'+')
