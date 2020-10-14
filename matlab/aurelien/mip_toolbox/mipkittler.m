function [th,bcvf] = mipkurita(x,nbins) 
% MIPBCV     Threshold computation based on the joint density function
%
%   [TH,CF] = MIPKURITA(X,NBINS)
%
%   This function will compute the threshold based on cumulative dis 
%   image given in X. NBINS represents the number of bins. The default
%   value for NBINS is 64. It returns threshold TH, the maximum of the
%   criterion function CMAX and the criterion function CF.
%
%   See also MIPBCV MIPBCV_ITERATIVE MIPKITILLING

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

warning off all

% compute histogram, pdf
[h,cbin] = mipimhist(x,nbins); 
% find the indices for max&min gray levels 
max_indx = max(find(h));
min_indx = min(find(h));
% initilize variables
totalMean = mipcmean(h,min_indx,max_indx);
totalvar  = mipcvar(h,totalMean,min_indx,max_indx);
prevProb1 = 0;
mean1     = 0;
bcvf      = zeros(1,nbins);
for i = min_indx:max_indx
    prob1   = prevProb1 + h(i);
    prob2   = 1-prob1;
    mean1   = (prevProb1*mean1 + h(i)*i)/prob1;		
    mean2   = mipcmean(h,i+1,max_indx);
    t1      = mean1-mean2;
    bcvf(i) = log(totalvar-prob1*prob2*t1*t1)-prob1*log(prob1)+prob2*log(prob2);
    prevProb1 = prob1;
end;
bcvf = bcvf/totalvar;
bcvf(isnan(bcvf))  = 0;
bcvf(isinf(bcvf))  = 0;
[tm,threshold] = min(bcvf(1:end-1));
th = cbin(threshold);

