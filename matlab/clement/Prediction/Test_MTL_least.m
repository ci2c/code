clear all

wholeCo = 0;
fileName = 'NoFazekas_PSCINetwork_Optimized';


load('/NAS/tupac/protocoles/Strokdem/Prediction/DoE_MTL.mat','DoE');
[Dx,~,~] = size(DoE);
Varf=[];
for D = 1:Dx;

load('/NAS/tupac/protocoles/Strokdem/Prediction/Data_for_prediction.mat','X','S','coeff','Y','id','nFC');
sy=sum(Y,2);
[C,~,~] = intersect(S,find(~isnan(sy)));

A = X(C,:);
y = Y(C,:);

% ----- Optimization ----- %

opts = [];

 opts.q = 2;
 opts.mFlag = 1;
 opts.nFlag = 0;
 
 opts.init = DoE(D,2);
 opts.tFlag = DoE(D,3);
 opts.lFlag = DoE(D,4);
 opts.rFlag = DoE(D,5);
 
 Spars = DoE(D,1);

if opts.rFlag == 0
    Z = [0.001 : 0.1 : 10];
else opts.rFlag == 1
    Z = [0.001 : 0.01 : 1];
end 

[S,I] = sort(A(:),'descend');
A( A < S(round(length(S(:)) / Spars) +1)) = 0; % Introduce sparsity
[pred,B,Opt_lambda] = LOOCV_LeastR(A,-y, opts, Z);


%figure; plot(y(:),pred(:),'+')
[R,~] = corrcoef(y,pred);
var_expl = R(1,2).^2;
Varf(end+1,1) = var_expl;
%disp(['Variance explained : ' num2str(var_expl)])

end
