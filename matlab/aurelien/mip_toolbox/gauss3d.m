% function h = gauss3d(sigma,HSIZE)
% This function computes a 3D Gaussian function
% Input is the sigma of the Gaussian and the kernel size
% if HSIZE is not defined than it is calculated

function h = gauss3d(sigma,HSIZE)
if sigma <= 0 
    fprintf(1,'Sigma is smaller than or equal to zero\n'); 
    h=0;
    return;
end;

if (nargin <2)
    ksize = ceil(sigma*8.5);
    if(iseven(ksize))
        ksize = ksize-1;
    end;
else
    ksize = HSIZE;
end;
lm = (ksize-1)/2;
c1 = sigma*sigma;
[x,y,z] = meshgrid(-lm:lm,-lm:lm,-lm:lm);
arg   = -(x.*x + y.*y + z.*z)/(2*c1);
h = exp(arg);
