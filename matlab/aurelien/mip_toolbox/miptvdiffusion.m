function dimg = miptvdiffusion(img,NofI,lambda)
% MIPTVDISSUSION  PDE based image diffusion
%
%   DIMG = MIPTVDIFFUSION(IMG, NOFI, LAMBDA)
%
%   Diffuses images using total variation based diffusion of
%   Rudin-Osher-fatami
% img       : input image
% nofi      : number of iterations
% lamda     : (diffusion speed) assumes values in the range [0, 0.25]
%
% dimg      : output image
%
%   See also MIPISODIFFUSION2D MIPAFFINECURVATUREMOVE

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

epsilon = 1;
for i=1:NofI
    dimgx  = mipcentraldiff(img,'dx');
    dimgy  = mipcentraldiff(img,'dy');
    dimgxx = mipsecondderiv(img,'dx');
    dimgyy = mipsecondderiv(img,'dy');
    dimgxy = mipsecondpartialderiv(img);
    dimgt1 = (dimgxx.*(epsilon + dimgy.^2) - 2*dimgx.*dimgy.*dimgxy ...
           + dimgyy.*(epsilon + dimgx.^2));
    dimgt2 = (epsilon + dimgx.^2 + dimgy.^2).^(3/2);
    img    = img + lambda*dimgt1./dimgt2;
end
dimg = img;