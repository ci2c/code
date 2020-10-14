function gf = tukeybiweight(dI,k)
% TUKEY  Diffusivity functions
%
%   gf = TUKEY(K,DI)
%
%   Tukey's biweight robust error norm
%   K: Noise threshold, DI: image gradient
%
%   See also WEICKERT HGRAD WREGION

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

gf = zeros(size(dI));
id = (x<=k);
xid = dI(id);
gf(id) = xid.*((1-(xid/k).^2).^2);
