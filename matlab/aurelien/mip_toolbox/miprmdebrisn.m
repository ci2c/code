function oimg = miprmdebrisn(img,excSize)
% MIPRMDEBRISN  Removes small binary objects from the image whose dimension is
% larger than 3
%
%   OIMG = MIPRMDEBRISN(IMG,EXCSIZE)
%
%   This function removes structures smaller than EXCSIZE 
%   in the binary image IMG. The output OIMG is also a binary image
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

L = bwlabeln(image,18);
S = regionprops(L,'Area');
oimg = ismember(L,find([S.Area] >= excSize));
