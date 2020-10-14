function img = mipremoveundefinedNums(X)
% MIPREMOVEUNDEFINEDNUMS  Replaces NANs and infs with zeros in a matrix
%
%   [H,CBIN] = MIPREMOVEUNDEFINEDNUMS(X)
%
%   See also

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[r,c] = size(X);
X = X(:);
X(isnan(X))=0;
X(isinf(X))=0;
img = reshape(X,r,c);

