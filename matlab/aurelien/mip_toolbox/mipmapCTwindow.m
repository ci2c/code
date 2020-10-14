function oimg = mipmapCTwindow(img,wl,ww)
% MIPMAPCTWINDOW
%
%   DIMG = MIPMAPCTWINDOW(IMG,WL,WW)
% This function adjusts the CT intensity window
% Inputs: 
%   IMG: CT image.
%   WL: center of the window
%   WW: window width
% Output:
%   OIMG: output image
%
%   See also 
%   
%   Omer Demirkaya ... 9/1/06
%   Medical Image Processing Toolbox

% Calculate the CT number limits
L = wl - ww/2;
U = wl + ww/2;
img = double(img);
% Assign the display limits to the intensities 
% outside the display range.
img(img < L) = 0;
img(img > U) = 255;
minL  = -min(img(:));
img   = img + minL;
mxL   = max(img(:));
% Calculate the slope
slope = 255/mxL;
% Carry out the mapping 
% and convert to 8-bit unsigned integer
oimg  = uint8(slope*img);
