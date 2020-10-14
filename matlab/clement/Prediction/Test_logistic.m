clear all
load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','S','coeff','Y','id','nFC');
sy = sum(Y,2);
[C,~,~] = intersect(S,find(~isnan(sy)));
X = X(C,:);
Y = Y(C,:);

[xy,yy,~] = size(Y);

Lambda=[0.001 : 0.001 : 1];


%----------------------- Set optional items -----------------------
opts=[];
opts.q=2;   
opts.rFlag=0;
opts.init = 2;
Rate = []; % 1,: = Faux positifs, 2,: = Faux négatifs
            
i = 1;
%----------------------- Run the code -----------------------
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

%% Permutation
tic;
    parfor i = 1:10000
        %fprintf('Permutation testing : %d\n',i)
        rnd = randperm(length(Y));
        Yrnd = Y(rnd);

        [pred,~,~] = LOOCV_LogisticR( X, Yrnd, opts, Lambda)
        rsq(i+1,1)=length(find(pred == 1));
    end
toc;


Rate(1,i) =  length(find(pred == 1));





i = i+1;

% ---- 

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

Rate(1,i) =  length(find(pred == 1));

i = i+1;



% ----

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

Rate(1,i) =  length(find(pred == 1));

i = i+1;

%----------------------- Set optional items -----------------------
opts=[];
opts.q=2;   
opts.rFlag=0;
opts.init = 2;
            
%----------------------- Run the code -----------------------
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

Rate(1,i) =  length(find(pred == 1));

i = i+1;

% ---- 

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

Rate(1,i) =  length(find(pred == 1));

i = i+1;
% ----

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
[pred,W,Opt_lambda] = LOOCV_LogisticR( X, Y, opts, Lambda)

Rate(1,i) =  length(find(pred == 1));

i = i+1;