function oimg = mipgray2multilevel(img,th);
% GRAY2MULTILEVEL   Thresholding images
%
%   OIMG = GRAY2MULTILEVEL(IMG,TH)
%
%   This function creates a multilevel image given multiple 
%   thresholds IMG has to be a gray-level image, TH is a vector 
%   of thresholds OIMG  is output the multilevel image. Regions 
%   are numbered from 1 (TH(i) <= IMG < TH(i+1)) to length(TH)+1
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical and Biological Image Processing Toolbox

oimg = zeros(size(img));
oimg(img < th(1) ) = 1;
numThresholds      = length(th);

if (numThresholds > 1)
    for i = 1:numThresholds - 1
        oimg(img >= th(i) & img < th(i+1)) = i + 1;
    end
    oimg(img >= th(numThresholds)) = i + 2;
else
    oimg(img >= th(1)) = 2;
end
