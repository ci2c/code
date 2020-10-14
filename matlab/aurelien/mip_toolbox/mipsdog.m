function [sdg, x] = mipsdog(sigma,K)
% MIPSDOG  Second derivative of Gaussian   
%
%   [SDG,X] = MIPSDOG(SIGMA,K)
%        
%        SIGMA: Sigma of Gaussian
%        K: Kernel size. If not specified, K = ceil(sigma*8.5)
%        X: Domain of Gaussian
%      SDG: Range of Gaussian
%
%
% 
%   See also MIPDOG, MIPGAUSS

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
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
C1  = sigma*sigma;
C2  = sigma^5*sqrt(2*pi);
sdg = (1/C2)*( x.*x - C1 ).*exp(-(x.*x)/(2*C1));



