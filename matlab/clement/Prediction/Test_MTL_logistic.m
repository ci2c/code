clear all
load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','S','coeff','Y','id','nFC');
sy = sum(Y,2);
[C,~,~] = intersect(S,find(~isnan(sy)));
X = X(C,:);
Y = Y(C,:);

[xy,yy,~] = size(Y);

Z=[1 : 10 : 200];


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
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;

% ---- 

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;



% ----

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;

%----------------------- Set optional items -----------------------
opts=[];
opts.q=2;   
opts.rFlag=0;
opts.init = 2;
            
%----------------------- Run the code -----------------------
opts.mFlag=0;       % treating it as compositive function 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;

% ---- 

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=0;       % Nemirovski's line search
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;
% ----

opts.mFlag=1;       % smooth reformulation 
opts.lFlag=1;       % adaptive line search
[pred,W,Opt_Z] = LOOCV_LeastR( X, Y, opts, Z)

[R,~] = corrcoef(Y,pred);

Rate(1,i) =  R(1,2);

i = i+1;

