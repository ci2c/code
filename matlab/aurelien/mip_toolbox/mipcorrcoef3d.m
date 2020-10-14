function ccf= mipcorrcoef3d(img,h)
% MIPCORRCOEF3D  Correlation coefficient in 3D
%
%   CCF = MIPCORRCOEF3D(IMG,H)
%
%   This function computes the correlation coefficient in 3D
%   given the input image IMG and the kernel h
%
%   See also 

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

[hr,hc,hz] = size(h);
ksize      = hr*hc*hz;
h1         = ones(hr,hc,hz);
th         = h(:);
th         = th-mean(th);
hh         = sum(sum(th.*th));
avgimg     = imfilter(img,h1/ksize);
imgsq      = img.*img;
imgsq      = imfilter(imgsq,h1);
imgsq      = imgsq-ksize*avgimg;
cor        = imfilter(img,h);
cor        = cor - ksize*avgimg*mean(th);
ccf        = cor./sqrt(imgsq*hh);