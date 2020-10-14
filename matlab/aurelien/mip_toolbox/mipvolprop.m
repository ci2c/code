function [C,vol,A] = mipvolprop(P)
% MIPVOLPROP     Computes the properties of a volume object
%
%   [C,V,A] = MIPVOLPROP(P)
%
%   See also  

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[C,vol] = convhulln(P);
d = [1 2 3];
nTriangle = size(C,1);
A = 0;
for i = 1:nTriangle
      j  = C(i,d);
      v1 = P(j(2),:)-P(j(1),:);
      v2 = P(j(3),:)-P(j(1),:);
      A  = A + 0.5*norm(cross(v1,v2));
end
