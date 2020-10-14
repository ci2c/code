function imDisk = mipdiskimage(imSize,Radius,Center); 
% MIPDISKIMAGE   DISK IMAGE
%
%   IMDISK = MIPDISKIMAGE(IMSIZE,RADIUS,CENTER)
%
%   This function generates a disk, which was defined by 
%   RADIUS and CENTER, image IMDISK
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox
       
[x, y] = meshgrid(1:imSize(1), 1:imSize(2));
imCircle = sqrt((x-Center(1)).^2 + (y-Center(2)).^2);
imDisk = double(imCircle<= Radius);
