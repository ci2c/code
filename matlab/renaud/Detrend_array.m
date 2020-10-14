function data_d = Detrend_array(data,pow)

% On effectue la regression
nt = size(data,1);
for i = 0:pow
    X(:,i+1) = ((1:nt)').^i;
end
% - calcul des betas
beta = (pinv(X'*X)*X')*data;

% - calcul des residus
data_d = data - X*beta;