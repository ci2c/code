function dimg = mipforwarddiff(img,direction)
% MIPFORWARDDIFF     Finite difference calculations 
%
%   DIMG = MIPFORWARDDIFF(IMG,DIRECTION)
%
%  Calculates the central-difference for a given direction
%  IMG       : input image
%  DIRECTION : 'dx' or 'dy'
%  DIMG      : resultant image
%
%   See also MIPCENTRALDIFF MIPBACKWARDDIFF MIPSECONDDERIV
%   MIPSECONDPARTIALDERIV

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

img = padarray(img,[1 1],'symmetric','both');
[row,col] = size(img);
dimg = zeros(row,col);
switch (direction)   
case 'dx',
   dimg(:,1:col-1) = img(:,2:col)-img(:,1:col-1);
case 'dy',
   dimg(1:row-1,:) = img(2:row,:)-img(1:row-1,:); 
otherwise, disp('Direction is unknown');
end;
dimg = dimg(2:end-1,2:end-1);