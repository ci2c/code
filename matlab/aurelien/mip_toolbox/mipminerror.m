function [th,cf,cbin] = mipminerror(x,nbins) 
% MIPMINERROR Threshold computation based on the minimization of a criterion
% function
%
%   [TH, CF, CBIN] = MIPMINERROR(X,NBINS)
%
%   This function will compute the threshold based on minimization of
%   Kullback information distance function. X is the input image or 
%   list of intensities. NBINS (default is 64) represents the number 
%   of bins. It returns threshold TH, the criterion function CF and CBIN is
%   the bin centers.
%
%   See also MIPBCV MIPBCV_ITERATIVE MIPKURITA

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

warning off MATLAB:divideByZero

if nargin < 2
    nbins = 64;
end
% compute histogram, pdf
[h,cbin] = mipimhist(x,nbins);
h = h/sum(h);
% find the indices for max&min gray levels
max_indx = max(find(h));
min_indx = min(find(h));
% initilize variables
prevProb1 = 0;
mean1     = 0;
cf        = zeros(1,nbins);
for i = min_indx:max_indx
    prob1 = prevProb1 + h(i);
    prob2 = 1 - prob1;
    mean1 = (prevProb1*mean1 + h(i)*i)/prob1;
    mean2 = mipcmean(h, i+1, max_indx);
    sd1   = sqrt(mipcvar(h, mean1, min_indx, i));
    sd2   = sqrt(mipcvar(h, mean2, i+1,max_indx));
    if prob1 == 0
        cf(i) = 0;
        mean1 = 0;
    elseif sd1 == 0 | sd2 == 0
    else
        cf(i) = prob1*log(sd1/prob1)+prob2*log(sd2/prob2);
    end
    prevProb1 = prob1;
end
[tm, thindx]  = min(cf);
th = cbin(thindx);