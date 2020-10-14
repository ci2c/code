function simg = mipicm2d2r(gimg,simg,beta,numOfIteration);
% MIPICM2D2R  MRF based segmentation
%
%   SIMG = MIPICM2D2R(IMG,SIMG,BETA,NOOFITERATION)
%
% img       : input image
% simg      : initial segmentation
% beta      : Beta
% noOfIteration     : number of iteration
%
% simg      : output image
%
%   See also MIPICM2DMR MIPMETROPOLIS2D2R MIPMETROPOLIS2DMR
%            MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% Replicate the images edges
gimg = padarray(gimg,[1 1],'replicate','both');
simg = padarray(simg,[1 1],'replicate','both');
%initialize the variables
[row,col] = size(gimg); k = 1;
while k <= numOfIteration
    [mus,sigs] = mipregionstats(gimg,simg,2);
    vars = sigs.^2 + 0.01;
    for ii = 2:row-1
        for jj = 2:col-1
            s  = simg(ii,jj);
            r  = 3 - s;
            e1 = mipTotalEnergy(gimg,simg,mus,vars,ii,jj,s,beta);
            e2 = mipTotalEnergy(gimg,simg,mus,vars,ii,jj,r,beta);
            if ( e2 < e1)
                simg(ii,jj) = r;
            end
        end
    end
    k = k + 1;
end;
simg = simg(2:end-1,2:end-1);
