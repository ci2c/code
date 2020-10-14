function Nimg = mipneighborhood2d(img,nhood,cpixel)
% MIPNEIGHBORHOOD2D  2D Neighborhood calculations
%
%   NIMG = MIPNEIGHBORHOOD2D(IMG,NHOOD,CPIXEL)
%
%   This function computes the neighborhood in 2d to be used 
%   in image processing that needs the neighborhood. NHOOD can
%   either be 4 or 8. The output image NIMG will have the size of 
%   r*c*nhood  where r and c are the number of rows and columns
%   If cpixel = 1 center pixel is included or else not
%
%   See also MIPNEIGHBORHOOD3D 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin < 3 cpixel = 0; end
    [R,C] = size(img);
if cpixel == 1
    Nimg  = zeros(R,C,nhood+1);
else
    Nimg  = zeros(R,C,nhood);
end
r0 = 2:R-1;
c0 = 2:C-1;
switch nhood
    case 4
        Nimg(r0,c0,1) = img(r0-1,c0);
        Nimg(r0,c0,2) = img(r0,c0+1);
        Nimg(r0,c0,3) = img(r0+1,c0);
        Nimg(r0,c0,4) = img(r0,c0-1);
    case 8
        % from upper-left corner in clock-wise direction
        Nimg(r0,c0,1) = img(r0-1,c0-1);
        Nimg(r0,c0,2) = img(r0-1,c0);
        Nimg(r0,c0,3) = img(r0-1,c0+1);
        Nimg(r0,c0,4) = img(r0,c0+1);
        Nimg(r0,c0,5) = img(r0+1,c0+1);
        Nimg(r0,c0,6) = img(r0+1,c0);
        Nimg(r0,c0,7) = img(r0+1,c0-1);
        Nimg(r0,c0,8) = img(r0,c0-1);
    otherwise
        errorgdlg('Neighborhood is unkown');
end
if cpixel == 1
    Nimg(r0,c0,nhood+1) = img(r0,c0);
end
    