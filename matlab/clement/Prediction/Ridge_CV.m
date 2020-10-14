function [B,rmse,preds,errs,lambdaave]=looloo(xTr,yTr,lambda)
%	function err=looreg(xTr,yTr,lambda);
%
%   INPUT:
%   xTr = dxn matrix of n input vectors 
%	yTr = 1xn vector of n target values
%   lambdas = a vector of possible lambda values default=[0.0001 0.001 0.01 0.1 1 10 100 1000]
%
%   OUTPUT:
%   rmse = root mean-squared error of linear regression with LOOCV
%   preds = 1xn vector of the leave-one-out predictions 
%   err = 1xn vector of the leave-one-out prediction errors
%
% copyright Kilian Q. Weinberger 2013 (Washington University in St. Louis)
%
% if ~matlabpool('size'); matlabpool(8);end
if nargin>2, 
    if length(lambda)==2
lmin=lambda(1);lmax=lambda(2);
steps=50;
lstep=(lmax-lmin)/steps;
p=lmin:lstep:lmax;
lambdas=10.^p; % default parameter search
    else
        lambdas=lambda;
    end
else
    
lambdas = [5000 7500  10000 20000 30000 40000 50000 60000 70000 80000 90000 100000 110000];
lambdas = [1:100:10000];
%lambdas = [0.01:1:50];

end;

ridge=@(x,y,lambda) (x*x'+lambda*eye(size(x,1)))\x*y'; % this learns a simple ridge regressor with set lambda

[d,n]=size(xTr); % dimensions of your data (d=number of features, n=number of inputs)

B = zeros(d,n);
pred = zeros(n,1);

% do the Leave-one-out parameter sweep
err=zeros(1,n);
preds=zeros(1,n);
L=length(lambdas);

for i=1:n
    % remove input 
    ID = crossvalind('Kfold',xTr,2);
    
    oyTr = yTr(:,ID == 1);
    oxTr = xTr(:,ID == 1);
    % find best lambda
    if L>1
        errl=zeros(1,L);
        for l=1:L
            errl(l)=looregRidge(oxTr,oyTr,lambdas(l));
        end;
        plot(lambdas, errl);
        hold on
        [~,bestL]=min(errl);
        bestlambda(i)=lambdas(bestL);
    else
        bestlambda(i)=lambda;
    end
    
    % do prediction for i
    B(:,ID == 1)=ridge(oxTr,oyTr,bestlambda(i));
    preds(ID == 2)=B(:,ID == 1)'*xTr(:,ID == 2); %Beta weight matrix

    %fprintf('%i: Label:%f Prediction:%f Best Lambda:%e\n',i,yTr(i),preds(i),bestlambda(i))
end;
% compute the final error
errs=(preds-yTr).^2;
rmse=sqrt(mean(errs));

% computer null error
norm=ones(size(yTr)).*mean(yTr);
nullerrs=(norm-yTr).^2;
nullrmse=sqrt(mean(nullerrs));
lambdaave=mean(bestlambda);