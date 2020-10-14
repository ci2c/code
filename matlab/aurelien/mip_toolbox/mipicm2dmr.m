function simg = mipicm2dmr(gimg,simg,nClass,beta,numOfIteration);
% MIPICM2DMR  MRF based segmentation
%
%   SIMG = MIPICM2DMR(IMG,SIMG,NCLASS,BETA,NOOFITERATION)
%
% img       : input image
% simg      : initial segmentation
% nClass    : number of classses or regions
% beta      : Beta
% noOfIteration : number of iteration
%
% simg      : output image
%
%   See also MIPICM2D2R MIPMETROPOLIS2D2R MIPMETROPOLIS2DMR
%            MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox


% Replicate the images edges
gimg = padarray(gimg,[1 1],'replicate','both');
simg = padarray(simg,[1 1],'replicate','both');
%initialize the variables
[row,col] = size(gimg);
k = 1;
while k <= numOfIteration
    [mus,sigs] = mipregionstats(gimg,simg,nClass);
    sigs = sigs + 0.01;
    vars = sigs.^2;
    for ii = 2:row-1
        for jj = 2:col-1
            for l = 1:nClass
                TEng(l) = mipTotalEnergyInteraction...
                    (gimg,simg,mus,vars,ii,jj,l,beta);
            end
            [mn,label]  = min(TEng);
            simg(ii,jj) = label;
        end
    end
    k = k + 1;
end;
simg = simg(2:end-1,2:end-1);
