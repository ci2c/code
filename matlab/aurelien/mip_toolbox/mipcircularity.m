function c = mipcircularity(p)
% MIPCIRCULARITY   Computes perimeter length
%
%   C = MIPCIRCULARITY(P)
%
%   P is the ordered boundary pixels
% 
%   This function calculates circularity of a region
% 
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

xmean = mean(p(:,1));
ymean = mean(p(:,2));
npoints = size(p,1)
for i=1:npoints
    d(i) =  pdist([p(i,1) p(i,2) ;xmean ymean]);
end
mur = sum(d)/npoints;
sgmr = 0;
for i=1:npoints
    sgmr = sgmr + (d(i) - mur)^2;
end
sgmr = sgmr/npoints;
c = mur/sqrt(sgmr);


