function gf = weickert(dI,k)
% WEICKERT  Diffusivity functions
%
%   gf = WEICKERT(K,DI)
%
%   Weickert's diffusivity function
%   K: Noise threshold, DI: image gradient
%
%   See also TUKEYBIWEIGHT HGRAD WREGION

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

gf   = ones(size(dI));
ind  = (dI > 0);
xind = dI(ind);
gf(ind) = 1-exp(-3.15./((xind/k).^4));

