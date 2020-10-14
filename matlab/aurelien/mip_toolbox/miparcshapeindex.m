function [d, lamda] = miparcshapeindex(nsmat)
% MIPARCSHAPEINDEX  
%
%   [D,LAMDA] = MIPARCSHAPEINDEX(NSMAT)
%
% This  function calculates the eigenvalues (lamda) and the shape index d
%  from the norm. scatter matrix
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

lamda  = eig(nsmat);
d      = sqrt(1-4*det(nsmat));

