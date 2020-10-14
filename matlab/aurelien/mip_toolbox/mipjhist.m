function h2d = mipjhist(im1,im2,mn1,mn2,mx1,mx2,b1,b2)
% MIPJHIST     Histogram of joint distribution
%
%   CM = MIPIMJHIST(X,IM1,IM2,MN1,MN2,MX1,MX2,B1,B2)
%
% This fucntion computes the 2-dimensional histogram of two arrays IM1 and IM2.
% H2D(i,j) is the density of th value i in IM1, and value j in IM2.
% MN1 and MN2 are desired minimums for the histogram. Defaults are image
% minimums. Similarly, MX1 and MX2 are desired maximums. Defaults are image
% maximums. B1 and B2 are bin sizes for IM1 and IM2 respecively. Defaults are 1
%
%   See also MIPIMHIST

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

%Find extents of arrays
MX1 = max(im1(:)); 
MX2 = max(im2(:));
MI1 = min(im1(:));
MI2 = min(im2(:));

if nargin < 8, b1=1; end
if nargin < 7, b2=1; end
if nargin < 6, mx2=MX2; end
if nargin < 5, mx1=MX1; end
if nargin < 4, mn2=MI1; end;
if nargin < 3, mn1=MI2; end;

m1 = floor((mx1-mn1)/b1)+1; % Get # of bins for each
m2 = floor((mx2-mn2)/b2)+1;
if (m1 <=0 | m2<=0), disp('Illegal bin size'); end;
if ((mn1==0 & mn2==0) & (b1==1 & b2==1) & (mx1<= m1 & mx2<=m2)& (mn1>=0 & mn2>=0))
   h = m1 * im2 + im1;
elseif (b1==1 & b2==1)
   h = m1*((im2 < mx2) - mn2 > 0)+ ((im1 < mx1) - mn1 > 0);
else
   h = m1*(((im2 < mx2) - mn2 > 0)/b2) + (((im1 < mx1) - mn1 > 0)/b1)
end;
h = h+1; % to handle the intensity level zero h(1) = p(0), probability of zero;
h1d = hist(double(h(:)),1:m1*m2); %Get the 1D histogram
% reform the histogram to produce 2D histogram
h2d = reshape(h1d,m1,m2);
% h2d = h2d';
% h2d = h2d/sum(sum(h2d));