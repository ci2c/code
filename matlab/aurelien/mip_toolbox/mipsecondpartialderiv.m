function dimg = mipsecondpartialderiv(img)
% MIPCENTRALDIFF     Finite difference calculations 
%
%   DIMG = MIPSECONDPARTIALDERIV(IMG)
%
%  Calculates second partial derivative delta/(deltaxdeltay) using 
%  central-difference
%  IMG      : input image
%  DXY      : resultant image
%
%   See also MIPFORWARDDIFF MIPBACKWARDDIFF MIPCENTRALDIFF MIPSECONDDERIV

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[row,col] = size(img);
img = padarray(img,[1 1],'symmetric','both');
dimg = zeros(size(img));
dimg(2:row+1,2:col+1) = ( img(3:row+2,3:col+2) + img(1:row,1:col)...
    - img(3:row+2,1:col) - img(1:row,3:col+2) )/4;
dimg = dimg(2:end-1,2:end-1);
   