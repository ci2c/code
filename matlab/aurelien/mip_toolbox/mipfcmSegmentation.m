function bw = mipfcmSegmentation(img,nRegions)
% MIPFCMSEGMENTATION Image segmentation by fuzzy c-means
% clustering
%
%   BW = MIPFCMSEGMENTATION(IMG,NREGIONS)
%
%   This function will segment the image using fuzzy c-means
%   clustering
%
%   See also MIPKMEANSSEGMENTATION

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 23/11/08
%   Medical Image Processing Toolbox

H = single(img(:));
% options = [m interations error number of iteration];
options = [2 100 1e-5 0];
[center, U, obj_fcn] = fcm(H,nRegions,options);
maxU = max(U);
index = zeros(nRegions, length(H));
for i=1:nRegions
    tmpindx = find(U(i,:) == maxU);
    H(tmpindx) = i;
end
[r,c] = size(img);
bw = reshape(H,r,c);