function h = mipgauss(sigma,N,K)
% MIPGAUSS  Gaussian function kernel
%
%   H = MIPGAUSS(SIGMA,N,K)
% 
%        SIGMA: Sigma of Gaussian
%        N = 1,2,3 is the dimension of the function
%        K: Kernel size. If not specified, K = ceil(sigma*8.5)
%        H: Range of Gaussian
%
%  Total area under the kernel is normalized to 1.
% 
% 
%   See also MIPSDOG, MIPSDOG 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06 
%   The Medical Image Processing Toolbox

if sigma <= 0
    error('Sigma should be larger than zero'); 
end
if nargin < 2
    error('Dimesion is missing');
end

% Kernel size K is not specified
if nargin < 3
    ksize = ceil(sigma*8.5);
    % If ksize is even
    if mod(ksize,2) == 0
        K = ksize - 1;
    else
        K = ksize;
    end     
end

if mod(K,2) == 0
    warning('N should be odd; thus, incremented by 1')
    K = K + 1;
end

W = -(K-1)/2:(K-1)/2;

switch N
    case 1
        R = W.*W;
    case 2
        [x,y] = ndgrid(W);
        R = x.^2 + y.^2;
    case 3
        [x,y,z] = ndgrid(W);
        R = x.^2 + y.^2 + z.^2;
    otherwise
        error('Dimension N (arg #2) should be 1,2 or 3')
end
C1    = sigma*sqrt(2*pi);
h     = (1.0/(C1))*exp(-R./(2*sigma*sigma));
h     = h./sum(h(:));
