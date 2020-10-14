function [dg, x] = mipdog(sigma,K)
% MIPDOG     Derivative of Gaussian
%
%   [DG,X] = MIPDOG(SIGMA,K)
%        
%        SIGMA: Sigma of Gaussian
%        K: Kernel size. If not specified, K = ceil(sigma*8.5)
%        X: Domain of Gaussian
%       DG: Range of Gaussian
%
%
% 
%   See also MIPSDOG, MIPGAUSS

%   Author: Omer Demirkaya, demirkaya@ieee.org
%   The Medical Image Processing Toolbox

if sigma <= 0
    error('Sigma should be larger than zero'); 
end
% Kernel size K is not specified
if nargin < 2
    ksize = ceil(sigma*8.5);
    % If ksize is even
    if mod(ksize,2) == 0
        K = ksize - 1;
    else
        K = ksize;
    end     
end
% If specified and even
if mod(K,2) == 0
    warning('K should be odd; thus, incremented by 1')
    K = K + 1;
end

x  = -(K-1)/2:(K-1)/2;
C  = sigma^3*sqrt(2*pi);
dg = (-x./C).*exp(-( x.*x)/(2*sigma*sigma));

