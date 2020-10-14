function [th,bmax,cf,cbin] = mipbcv(x,nbins) 
% MIPBCV     Threshold computation based on between-class variance
%
%   [TH,BMAX,CF,CBIN] = MIPBCV(X,NBINS)
%
%   This function will compute the threshold based on the bcv's criterion 
%   for the image given in X. NBINS represents the number of bins. The 
%   default value for NBINS is 64. It returns threshold TH, the maximum 
%   of the criterion function CMAX and the criterion function CF.
%
%   See also MIPBCVITERATIVE, MIPKURITA MIPMINERROR

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

warning off all

if nargin == 1
    nbins = 64;
end

% compute histogram
[h,cbin] = mipimhist(x,nbins);
% find the indices for max&min gray levels 
max_indx = max(find(h));
min_indx = min(find(h));
% initilize variables
totalMean = mipcmean(h,1,max_indx);
prevProb1 = 0;
mean1     = 0;
cf = zeros(1,nbins);
for i = min_indx:max_indx
    prob1 = prevProb1 + h(i);
    prob2 = 1-prob1;
    mean1 = (prevProb1*mean1 + h(i)*i)/prob1;		
    mean2 = mipcmean(h,i+1,max_indx);
    t1    = mean1-mean2;
    cf(i) = prob1*prob2*t1*t1; 
    prevProb1 = prob1;
end;

totalvar= mipcvar(h,totalMean,min_indx,max_indx);

if totalvar > 0
    cf = cf/totalvar;
end;

[bmax,cmax_indx] = max(cf);
th               = cbin(cmax_indx);

