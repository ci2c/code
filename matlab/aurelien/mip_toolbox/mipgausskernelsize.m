function ksize = mipgausskernelsize(sigma)
% MIPGAUSSKERNELSIZE  Anisotropic Diffusion
%
%   KSIZE = MIPGAUSSKERNELSIZE(SIGMA)
%
%   Calculates the kernel size of a Gaussian function given its sigma
%
%   See also MIPGAUSS

ks = round(8.5*sigma);
if 2*floor(ks/2) == ks
    ksize = ks+1;
else
    ksize = ks;
end;
