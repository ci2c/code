function [simg, simgV] = mipmetropolis2dmr(gimg,simg,beta,...
    numRegions,numOfIteration)
% MIPMETROPOLIS2DMR  MRF based segmentation
%
% [SIMG SIMGV] = MIPMETROPOLIS2DMR(GIMG,SIMG,BETA,...
%                NUMOFREGIONS,NOOFITERATION)
%
% gimg      : input image
% simg      : initial segmentation
% nClass    : number of classes
% beta      : Beta
% numRegions: number of regions
% noOfIteration : number of iteration

%
% simg      : output image
%
%   See also MIPICM2DMR MIPICM2D2R MIPMETROPOLIS2D2R
%            MIPGIBBS2D2R MIPGIBBS2DMR
%
%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

% Replicate the images edges
gimg = padarray(gimg,[1 1],'replicate','both');
simg = padarray(simg,[1 1],'replicate','both');
[row, col]=size(gimg);
% Initilize the parameters
T = 4; C = 0.97; k = 1;
% Caculate region statistics
[mus, sigs] = mipregionstats(gimg(2:end-1,2:end-1),...
    simg(2:end-1,2:end-1),numRegions);
vars = (sigs + 0.01).^2;
% Create a matrix which will be used to draw a random label that 
% is not equal to current label
regionLabels = 1:numRegions;
Lmatrix = zeros(numRegions-1);
for kk = 1:numRegions
    Lmatrix(kk,:) = regionLabels(regionLabels ~= kk);
end
while (k <= numOfIteration)
    % Random numbers from uniform distribution and take the log
    LogU = log(random('Uniform',0,1,row,col));
    % raster scan the image
    for i = 2:row-1
        for j = 2:col-1
            s = simg(i,j);
            e1 = mipTotalEnergy(gimg,simg,mus,vars,i,j,s,beta);
            rL = randomLabel(Lmatrix,s,numRegions);
            e2 = mipTotalEnergy(gimg,simg,mus,vars,i,j,rL,beta);
            if (e2 - e1) <= 0
                simg(i,j) = rL;
            elseif ( LogU(i,j) <= (e1 - e2)/T)
                simg(i,j) = rL;
            end
        end
    end
    T = T*C; k = k + 1;
    [mus, sigs] = mipregionstats(gimg(2:end-1,2:end-1),...
        simg(2:end-1,2:end-1),numRegions);
    vars = (sigs + 0.01).^2;
    simgV(:,:,k) = simg;
end
simg = simg(2:end-1,2:end-1);

function rL = randomLabel(M,currentlabel,numRegions);
indx = ceil((numRegions-1).*rand(1,1));
rL = M(currentlabel,indx);