clear all
%% CONFIG

domain_name = 'Multitask';
fsdir  = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask';
lesdir = '/NAS/tupac/protocoles/Strokdem/Lesions/72H/';


% load input and output data for ridge
load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','S','coeff','id'); % id correspond to the connexions in the PSCI network

[a,~,~] = xlsread('/NAS/tupac/protocoles/Strokdem/Prediction/MTL_zscore.xls');

Y = a;
%% Leave one out prediction
% Extract data

[C,~,~] = intersect(S,find(~isnan(mean(Y,2)))); % Find subjects with input AND output valid data

X = X(C,:);
Y = Y(C,:);



%% Do MultiTask Learning

[Yx,Yy,~] = size(Y);

Yf={};
Xf={};
for i=1:Yy
    Yf{end+1} = Y(:,i);
    Xf{end+1} = X(:,:);
end


task_num = length(X);

% the function used for evaluation.
eval_func_str = 'eval_MTL_mse';
higher_better = false; % mse is lower the better.
% optimization options
opts = [];
opts.maxIter = 10000;
opts.tFlag = 3;
opts.tol = 10^-10; 
% model parameter range
param_range = [0.0001 0.001 0.01 0.1 1 5 10];

%pred = zeros(length(C),task_num);

[pred,W,L] = LOOCV_MTL( Xf, Yf, 'Least_Lasso', opts, param_range, eval_func_str, higher_better);

X_k = cell(task_num, 0);
Y_k = cell(task_num, 0);
X_out = cell(task_num, 0);
Y_out = cell(task_num, 0);


for i = 1:length(Y{1}) % For the case where all of task have the same subjects. 
    
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
       
    [W,c] = Least_Trace(X_k, Y_k, best_param, opts); % Si fais le least sur le sujet out, ça marche pas, ça le prédit direct;
    
    for t=1:task_num
        pred(i,t)=W(:,t)'*X_out{1}'; %Beta weight matrixCrossValidation1Param
    end
   
end  
training_percent = 0.5;
[X_tr, Y_tr, X_te, Y_te] = mtSplitPerc(X, Y, training_percent);

% cross validation
best_param = CrossValidation1Param( X_tr, Y_tr, 'Least_Trace', opts, param_range, ...
cv_fold, eval_func_str, higher_better);

[W,c] = Least_Trace(X_te, Y_te, best_param, opts);
final_performance = eval_MTL_mse(Y_te, X_te, W);