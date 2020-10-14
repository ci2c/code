% This function computes an optimal threshold using the entropy-based criterion function
% FUNCTION [th,co,h] = mipentropy_th(x,nbins) 
%  outputs:
%   th : optimal threshold
%   co : criterion function
%    h : pdf of gray levels
%  inputs: 
%  	x:image
%   nbins: number of bins for the histogram
%  uses hist to calculate image histogram
function [th,co,h] = entropy_th(x,nbins)
%
warning off ;
% compute histogram, pdf
[h,cbin] = hist(x(:),nbins); h = h/sum(h); 
% find the indices for max&min gray levels 
max_indx = max(find(h));
min_indx = min(find(h));
% initilize variables
prob1 = 0;
ht = h;
% replace 0s with 1s in the histogram to avoid log(0) problem
% They will not affect the results as log(1)=0
ht(h==0) = 1;
% calculate total entropy
Htot = sum(h.*log(ht));
H1=0;
for i= min_indx:max_indx-1
    prob1 = prob1 + h(i);
    prob2 = 1-prob1;
    H1=H1+h(i)*log(ht(i));
    co(i) = log(prob1*prob2)-H1/prob1+(H1-Htot)/prob2;
end;
%
co = co/(-Htot);
co(isnan(co)) = 1;
co(max_indx) = 1;
[tm,threshold] = max(co);
th = cbin(threshold);
