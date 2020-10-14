function [t1,t2] = mipbcviterative(x,nbins)
% MIPBCV     Threshold computation based on between-class variance for
%            trimodal images
%
%   [T1,T2] = MIPBCVITERATIVE(X,NBINS)
%
%   This function will compute the thresholds based on the between-class 
%   variance for the image given in X. NBINS represents the number of bins. 
%   The default value for NBINS is 64. It returns thresholds T1 and T2.
%
%   See also MIPBCV MIPKURITA

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

warning off all

if nargin == 1
    nbins = 64;
end

[h,cbin] = mipimhist(x,nbins); 
% find the indices for max&min gray levels 
max_indx = max(find(h));
min_indx = min(find(h)); 
hstep = median(diff(cbin));
kmax = max_indx - min_indx;
t1 = fix(min_indx + kmax/3.0);
t2 = fix(min_indx + kmax*2.0/3.0);
pe1 = 0;
pe2 = 0;
FLAG = 1;
min_indx = fix(min_indx);
while (FLAG)
   e1 = (mipcmean(h, min_indx,t1) + mipcmean(h,t1 + 1,t2))/2.0 - t1;
   e2 = (mipcmean(h,t1 + 1,t2) + mipcmean(h,t2 + 1, max_indx))/2.0 - t2;
   if pe1 == e1 & pe2 == e2
      FLAG = 0;
   end;
   pe1 = e1;
   pe2 = e2;
   t1 = t1 + fix(e1);
   t2 = t2 + fix(e2);
end;

t1 = cbin(t1);
t2 = cbin(t2);
