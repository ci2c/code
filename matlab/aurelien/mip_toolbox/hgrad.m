function gf = hgrad(dI,k)
% HGRAD  Diffusivity functions
%
%   gf = HGRAD(K,DI)
%
%   Favors high gradients
%   K: Noise threshold, DI: image gradient
%
%   See also WEICKERT WREGION TUKEYBIWEIGHT

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

gf = exp(-(dI/k).^2);

