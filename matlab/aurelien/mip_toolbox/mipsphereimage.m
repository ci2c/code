function imSphere = mipsphereimage(imSize,Radius,Center); 
% MIPSPHEREIMAGE  Sphere image
%
%   IMSPHERE = MIPSPHEREIMAGE(IMSIZE,RADIUS,CENTER)
%
%   This function generates a sphere, which was defined by 
%   RADIUS and CENTER, image IMDISK
%
%   See also MIPSIGMOIDIMAGE MIPDISKIMAGE

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox
       
[x, y,z] = meshgrid(1:imSize(1), 1:imSize(2),1:imSize(3));
imSphere = sqrt((x-Center(1)).^2 + (y-Center(2)).^2+(z-Center(3)).^2);
imSphere = imSphere<=Radius;