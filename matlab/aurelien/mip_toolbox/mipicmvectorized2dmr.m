function simg = mipicmvectorized2dmr(gimg,simg,nClass,nhood,beta,numOfIteration);
% MIPVECTORIZED2DMR  MRF based segmentation
%
% SIMG = MIPICMVECTORIZED2DMR(IMG,SIMG,NCLASS,BETA,...
%        NHOOD,NOOFITERATION)
%
% img       : input image
% simg      : initial segmentation
% nClass    : number of classes
% beta      : Beta
% nHood     : neighborhood (3D: 6, 18, 26)
% noOfIteration : number of iteration

%
% simg      : output image
%
%   See also MIPICM2DMR MIPICM2D2R MIPMETROPOLIS2D2R 
%            MIPMETROPOLIS2DMR MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox


% Replicate the images edges
gimg = padarray(gimg,[1 1],'replicate','both');
simg = padarray(simg,[1 1],'replicate','both');
%initialize the variables
[row,col] = size(gimg); k = 1;
while k <= numOfIteration
    [mus,sigs] = mipregionstats(gimg(2:end-1,2:end-1),...
        simg(2:end-1,2:end-1),nClass); 
    sigs = sigs + 0.001;
    vars = sigs.^2;
    Nimg = mipneighborhood2d(simg,nhood);
    Himg = histc(Nimg,1:nClass,3);
    for L=1:nClass     
        likeimg(:,:,L) = (0.5./vars(L)).*(gimg(:,:) - ...
            mus(L)).^2 + log(sigs(L)) - beta*Himg(:,:,L);
    end
    [MN,simg] = min(likeimg,[],3);
    k = k + 1;
end;
simg = simg(2:end-1,2:end-1);
