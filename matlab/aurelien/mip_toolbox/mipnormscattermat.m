function nscatmat = mipnormscattermat(x1,x2)
% MIPNORMSCATTERMAT     Bins pixels
%
%   NSM = MIPNORMSCATTERMAT(X1,X2)
%
% This  function calculates the normalized scatter matrix
% 
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

scatmat  = (length(x1)-1)*cov(x1,x2);
nscatmat = scatmat/trace(scatmat);

