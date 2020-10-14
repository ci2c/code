function M = mipstructuretensor(I,smooth,sigma,vnormtype,p)
% MIPSTRUCTURETENSOR     TENSOR Function
%
%   ST = MIPSTRUCTURETENSOR(V,TYPE,P)
%
% TYPE : 'linf':L-infinity norm; 'l1':L-1 norm; 'lp': L-P norm
%        default is L-2 norm
% P    : value of the p in lp norm
% FGRAD: Magnitude of the final gradient
%
%  Example: fgrad = mipvectorgrad(I,'lp',2) % L2 norm
%
% This function computes the gradient of color or multispectral images
%
%   See also

%   Omer Demirkaya, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin < 2
    smooth = 0;
    vnormtype = 'l1';
elseif nargin < 3
    sigma = 1;
    vnormtype = 'l1';
elseif nargin < 4
    vnormtype = 'l1';
elseif nargin < 5
    p = 2;
end


[r,c,nChannels] = size(I);
DIxx = zeros(r,c,nChannels);
DIxy = zeros(r,c,nChannels);
DIyy = zeros(r,c,nChannels);
% Compute the gradient for ever channel separately
count = 0;
% create 1D DoG and 2D Gaussian kernels
DoG = mipdog(sigma);
gimg = mipgauss(sigma,2);
for i = 1:nChannels
    if smooth == 1 || smooth == 2
        % smooth both during gradient calc and gradients themselves
        Ix = conv2(single(I(:,:,i)),DoG,'same');
        Iy = conv2(double(I(:,:,i)),DoG','same');
    elseif smooth == 2
        % smooth gradients only
        Ix = conv2(Ix,gimg,'same');
        Iy = conv2(Iy,gimg,'same');
    else
        % no smoothing
        [Ix,Iy] = gradient(single(I(:,:,i)));
    end
    DIxx(:,:,i) = Ix.*Ix;
    DIxy(:,:,i) = Ix.*Iy;
    DIyy(:,:,i) = Iy.*Iy;
end
M = zeros(r,c,3);
switch vnormtype
    case 'linf'
        % L-infinity norm
        M(:,:,1) = max(DIxx,[],3);
        M(:,:,2) = max(DIxy,[],3);
        M(:,:,3) = max(DIyy,[],3);
    case 'l1'
        %L-1 norm
        M(:,:,1) = sum(DIxx,3);
        M(:,:,2) = sum(DIxy,3);
        M(:,:,3) = sum(DIyy,3);
    case 'lp'
        %L-p norm
        for jj = 1:nChannels
            M(:,:,1) = M(:,:,1) + DIxx(:,:,jj).^p;
            M(:,:,2) = M(:,:,2) + DIxy(:,:,jj).^p;
            M(:,:,3) = M(:,:,3) + DIyy(:,:,jj).^p;
        end
        M(:,:,1) = M(:,:,1).^1/p;
        M(:,:,2) = M(:,:,2).^1/p;
        M(:,:,3) = M(:,:,3).^1/p;
    otherwise
        error('unknown type');
end

