function [h,cbin] = mipimhist(x,nbins) 
% MIPIMHIST   Histogram computation
%
%   [H,CBIN] = MIPIMHIST(X,NBINS)
%
%   This function computes the histogram for the image given in X. 
%   NBINS (default is 64) represents the number of bins. 
%   It returns the histogram H and the bin centers CBIN.
%
%   See also MIPCMEAN MIPCVAR

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if nargin < 2
    nbins = 64;
end

[h,cbin] = hist(double(x(:)), nbins); 
h = h/sum(h); 
