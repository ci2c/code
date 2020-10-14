function simg = mipmetropolis2d2r(gimg,simg,beta,numOfIteration)
% MIPMETROPOLIS2D2R  MRF based segmentation
%
% SIMG = MIPMETROPOLIS2D2R(GIMG,SIMG,BETA,NOOFITERATION)
%
% gimg      : input image
% simg      : initial segmentation
% nClass    : number of classes
% beta      : Beta
% noOfIteration : number of iteration

%
% simg      : output image
%
%   See also MIPICM2DMR MIPICM2D2R MIPMETROPOLIS2DMR
%            MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% Replicate the images edges
gimg = padarray(gimg,[1 1],'replicate','both');
simg = padarray(simg,[1 1],'replicate','both');
[row, col] = size(gimg);
% Initilize the parameters
T = 4; C = 0.97; k = 0;
% Caculate region statistics
[mus, sigs] = mipregionstats(gimg(2:end-1,2:end-1),...
    simg(2:end-1,2:end-1),2);
vars = (sigs + 0.01).^2;
while (k <= numOfIteration)
    % Random numbers from uniform distribution and take the log
    aprob = log(random('Uniform',0,1,row,col));
    % raster scan the image
    for i = 2:row-1
        for j = 2:col-1
            s = simg(i,j);
            r = 3 - s;  % Region labels start from 1,..., numRegions
            e1 = mipTotalEnergy(gimg,simg,mus,vars,i,j,s,beta);
            e2 = mipTotalEnergy(gimg,simg,mus,vars,i,j,r,beta);
            if (e2 - e1) <= 0
                simg(i,j) = r;
            elseif ( aprob(i,j) <= (e1 - e2)/T)
                simg(i,j) = r;
            end
        end
    end
    T = T*C; k = k + 1;
    [mus, sigs] = mipregionstats(gimg(2:end-1,2:end-1),...
        simg(2:end-1,2:end-1),2);
    vars = (sigs + 0.01).^2;
end
simg = simg(2:end-1,2:end-1);