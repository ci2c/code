function simg = mipicm3d(gimg,simg,nClass,beta,nHood,noOfIteration);
% MIPICM3D  MRF based segmentation
%
% SIMG = MIPICM3D(IMG,SIMG,NCLASS,BETA,NHOOD,NOOFITERATION)
%
% img       : input image
% simg      : initial segmentation
% nClass    : number of classes
% beta      : Beta
% nHood     : neighborhood (3D: 6, 18, 26)
% noOfIteration     : number of iteration

%
% simg      : output image
%
%   See also MIPICM2DMR MIPICM2D2R MIPMETROPOLIS2D2R 
%            MIPMETROPOLIS2DMR MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

%padding the image boundaries
gimg = single(padarray(gimg,[1 1 1],'replicate','both'));
simg = single(padarray(simg,[1 1 1],'replicate','both'));
%initialize the variables
[row, col, numSlices] = size(gimg);
totalE = zeros(row,col,sliceNum,nClass,'single');
numPixelsChanged = row;
k  = 0;
% Allocate space for the neighborhood image
VN = zeros(row,col,numSlices,nHood,'single');
% Start iterating
while  k <= noOfIteration
    [mus, sigs] = regionstats(gimg,simg,nClass);
    vars = (sigs + 0.001).^2;
    VN   = neighborhood3d(simg,nHood);
    Himg = single(histc(VN,1:nClass,4));
    for l = 1:nClass
        totalE(:,:,:,l) = 1./(2*vars(i)).*(gimg-mus(l)).^2 + ...
            log(sigs(l))- beta*Himg(:,:,:,l);
    end
    [MN,simg] = min(totalE,[],4);
    k = k + 1;
end;
simg = simg(2:end-1,2:end-1,2:end-1);
