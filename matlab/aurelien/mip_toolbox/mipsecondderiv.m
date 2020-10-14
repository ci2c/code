function dimg = mipsecondderiv(img,direction)
% MIPCENTRALDIFF     Finite difference calculations 
%
%   DIMG = MIPSECONDDERIV(IMG,DIRECTION)
%
%  Calculates second derivative using central-difference for a given direction
%  IMG       : input image
%  DIRECTION : 'dx' or 'dy'
%  DIMG      : resultant image
%
%   See also MIPFORWARDDIFF MIPBACKWARDDIFF MIPCENTRALDIFF
%   MIPSECONDPARTIALDERIV

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[row,col] = size(img);
img = padarray(img,[1 1],'symmetric','both');
dimg = zeros(size(img));
switch (direction)
    case 'dx',
        dimg(2:row+1,2:col+1)= img(2:row+1,3:col+2) + img(2:row+1,1:col) - 2*img(2:row+1,2:col+1); 
    case 'dy',
        dimg(2:row+1,2:col+1)= img(3:row+2,2:col+1) + img(1:row,2:col+1) - 2*img(2:row+1,2:col+1);
    otherwise,
        disp('Direction is unknown'); 
end
dimg = dimg(2:end-1,2:end-1);