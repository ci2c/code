function simg = miporthogonal(img,viewmode,sliceNum) 
% MIPORTHOGONAL   Extraction of an orthogonal slice
%
%   SIMG = MIPORTHOGONAL(IMG,VIEWMODE,SLICENUM)
%
%   This function extracts the orthogonal slice from a volume image
%   image given in X. NBINS represents the number of bins. The default
%   value for NBINS is 64. It returns histogram H, the bin centers CBIN
%   
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

switch viewmode
    case 1
        simg = img(:,:,sliceNum); % transverse slice
    case 2
        simg = squeeze(img(sliceNum,:,:))'; % coronal slice
    case 3
        simg = squeeze(img(:,sliceNum,:))'; % sagital slice 
    otherwise
end