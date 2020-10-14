function oimg = mipimoverlay(gimg,bimg,c)
% MIPIMOVERLAY     Overlays the binary image on a graylevel image
%
%   OIMG = MIPIMOVERLAY(GIMG,BIMG,C)
%
%   This function overlays the binary image BIMG onto the gray level GIMG
%   in color c. The output image OIMG is a color image.
%   c = 1,2,3 will assign the binary image red, green, blue colors.
%
%   See also

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox


if nargin < 3
    c = 1;
end
oimg = imscale(gimg,1);
gimg (bimg==1) = 0;
oimg = cat(3,gimg,gimg,gimg);
gimg (bimg==1) = 1;
oimg(:,:,c) = gimg;
