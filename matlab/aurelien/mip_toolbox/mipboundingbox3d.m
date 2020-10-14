function Ldatao = mipboundingbox3d(Ldata,ImSize)
% MIPBOUNDINGBOX3D
%
%   DIMG = MIPBOUNDINGBOX3D(LDATA,IMSIZE,CNST)
% This function calculates the bounding box around a 3D object 
%  in a 3D image
% Inputs: 
%   Ldata is the structure, the output of regionprops, with at least,
%   PixelList field. The function uses the pixel list to calculate the
%   bounding box.
%   ImSize is the size of the 3D image e.g., size(img)
% Output:
%   Ldata.boundBox
% Example: 
%   Ldata = mipboundingbox3d(Ldata,size(img))
%   Ldata.boundBox =[xmin xmax ymin ymax zmin zmax] 
%   One can extract this volume using MATLAB's subvolume function
%
%   See also 
%   

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

aborder = [1 ImSize(2) 1 ImSize(1) 1 ImSize(3)]; % [1 x 1 y 1 z]
ido = [1,3,5];
ide = [2,4,6];
bbox = zeros(1,6);
nObjects = length(Ldata);
Ldatao = Ldata;
constant = 1;
for i=1:nObjects
    p = Ldata(i).PixelList;
    minp = min(p,[],1);
    maxp = max(p,[],1);
    bbx  = [minp(1)-constant, maxp(1)+constant,...
        minp(2)-constant,maxp(2)+ constant,...
        minp(3)-constant maxp(3)+constant];
    % checks for the borders of the image since we add and subtract 1 from
    % the minima and maxima, respectively.
    bbox(1,ido) = max(bbx(1,ido),aborder(1,ido));
    bbox(1,ide) = min(bbx(1,ide),aborder(1,ide));
    Ldatao(i).BoundBox = bbox;
end