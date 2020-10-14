function oimg  = mipmed3d(img,ksize)
% MIPMED3D  3D median filtering
% 
%   OIMG = MIPMED3D(IMG,KSIZE)
%
%
% This function median filters a volume image slice by slice
% IMG:   3D input image
% KSIZE: median filter kernel size
% OIMG:  output image
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

nslice =size(img,3);
for i=1:nslice
    oimg(:,:,i) = medfilt2(img(:,:,i),[ksize ksize]);
end;
