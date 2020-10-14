function gf = wregion(k,dI)
% WREGION  Diffusivity functions
%
%   gf = WREGION(K,DI)
%
%   This fucntion favors wider regions
%   K: Noise threshold, DI: image gradient
%
%   See also WEICKERT HGRAD

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

t1 = dI/k;
t2 = 1+t1.*t1;
gf = 1./t2;