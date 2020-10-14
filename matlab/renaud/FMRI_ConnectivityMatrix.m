function [tseries,C,Cpar,Cz,Cparz] = FMRI_ConnectivityMatrix(epiFile,maskFile,loiFile)

V   = spm_vol(epiFile);
epi = spm_read_vols(V);
dim = size(epi);
epi = reshape(epi,dim(1)*dim(2)*dim(3),dim(4));

Vm   = spm_vol(maskFile);
mask = spm_read_vols(Vm);
mask = mask(:);

[nums,names] = textread(loiFile,'%d%s');

tseries = zeros(length(nums),dim(4));

for k = 1:length(nums)

    val = nums(k);
    ind = find(mask==val);
    tseries(k,:) = mean(epi(ind,:),1);
    
end

tseries = tseries';

tseries = detrend_tseries(tseries,2);
tseries = st_normalise(tseries);

S = (dim(4)-1)*cov(tseries);

% Correlation
D = diag(1./sqrt(diag(S)));
C = D*S*D;

% Partial Correlation 
U       = inv(S);
DiagMat = diag(1./sqrt(diag(U)));
Cpar    = 2*eye(length(nums))-DiagMat*U*DiagMat;

% Diagonal at 0
C    = triu(C,1)+tril(C,-1);
Cpar = triu(Cpar,1)+tril(Cpar,-1);

% Fisher Z-score
Cz    = 0.5 * log( ( 1 + C ) ./ ( 1 - C ) );
Cparz = 0.5 * log( ( 1 + Cpar ) ./ ( 1 - Cpar ) );

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_d = detrend_tseries(data,pow)

% On effectue la regression
nt = size(data,1);
for i = 0:pow
    X(:,i+1) = ((1:nt)').^i;
end
% - calcul des betas
beta = (pinv(X'*X)*X')*data;

% - calcul des residus
data_d = data - X*beta;
