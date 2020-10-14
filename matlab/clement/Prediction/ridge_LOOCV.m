function [B,R,rmse,var_expl,pred,errs,P_perm,blambda,Rsq_all] = ridge_LOOCV(X,Y,doPerm)

%%
%[bW,var_expl,pred,errs,P_perm] = ridge_LOOCV(X,Y) 
% Perform ridge regression to predict Y from X using a leave one out
% cross-validation (LOOCV). Also perform permutation (10,000) to assess
% prediction by chance.
%
% - INPUT : 
%           X : n-by-c matrix with n subjects and c components
%           Y : n-by-1 vector of score to predict
%
% - OUTPUT : 
%           bW : n-by-c matrix of weights
%           var_expl : squared root of the correlation coefficient between
%           predicted and input score;
%           pred : predicted score
%           errs : error of accuracy of each subject
%           P_perm : probability of var_expl better in permutation to
%           original
%
%
% Adapted from Siegel et al., 2016 PNAS (doi: 10.1073/pnas.1521083113) by
% Clément Bournonville. CHU Lille - Ci2C - February 2017.


%
[B,rmse,pred,errs,blambda]=looloo(X',Y');
beta=nanmean(B,2);
[RHO,~,~,~]=corrcoef(Y,pred);
R = RHO(1,2);
rsq(1,1)=R.^2;
var_expl = rsq(1);

nper = 5000;
%% Permutation
tic;
if doPerm
    parfor i = 1:nper
        %fprintf('Permutation testing : %d\n',i)
        rnd = randperm(length(Y));
        Yrnd = Y(rnd);

        [~,~,tmpred,~,~]=looloo(X',Yrnd');
        [RHO,~,~,~]=corrcoef(Y,tmpred);
        rsq(i+1,1)=RHO(1,2)^2;
    end
[x,y,~] = size(find(rsq(2:end,:) > rsq(1,1)));
P_perm = x / nper;

fprintf('Probability of observing the reported R² : %d\n',P_perm)
else
    P_perm = NaN;
end
toc;
