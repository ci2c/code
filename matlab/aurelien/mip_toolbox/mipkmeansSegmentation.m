function [simg,thresholds] = mipkmeansSegmentation(img,nRegions)
% MIPKMEANSSEGMENTATION Image segmentation by kmeans
% clustering
%
%   [SIMG,THRESHOLDS] = MIPKMEANSSEGMENTATION(IMG,NREGIONS)
%
%   This function will segment the image using kmeans
%   clustering
%
%   See also MIPFCMSEGMENTATION

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 23/11/08
%   Medical Image Processing Toolbox

H = single(img(:));
[C_IDX C_CENTER] = kmeans(H,nRegions,'distance',...
    'sqEuclidean','Replicates', nRegions+1);
NID = (1:nRegions)';
CIDX = sortrows([C_CENTER,NID],1);
for i=1:nRegions-1;
    thresholds(i) = max(H(C_IDX==CIDX(i,2)));
end
[r,c] = size(img);
simg = reshape(C_IDX,r,c);

simg = mipgray2multilevel(img,thresholds);