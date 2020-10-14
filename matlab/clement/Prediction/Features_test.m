function bpred = Features_test(X,Y,B)

[S,I] = sort(B,'ascend');

doPerm = 0;
bpred = [];


for i = 1:length(I)
    disp (['Features 1 to ' num2str(i)]);
    id = I(1:i);
    [B,R,rmse,var_expl,pred,errs,P_perm,blambda] = ridge_LOOCV(X(:,id),-Y,doPerm);
    
    bpred(end+1,1) = var_expl;
end