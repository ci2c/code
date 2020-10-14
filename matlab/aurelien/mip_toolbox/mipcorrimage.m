function [nImg,uImg] = mipcorrimage (ImSize,rho,sigma,muImg)
% MIPCORRIMAGE     Image with correlated pixels
%
%   [NIMG, UIMG] = MIPCORRIMAGE(IMSIZE,RHO,SIGMA,MUIMG)
%
%   This function generates images with spatially correlated pixels.
%   It regards an image as a discerete random field where each pixel is a
%   random variable. The pixels can be correlated or completely 
%   independent,white noise field.
%   Using UIMG one can generate images with such as Beta, gamma, Weibull, 
%   Poisson distribution by simply using inverse pdf function; for example 
%   PIMG = poissinv(UIMG)
%   Inputs:
%   IMSIZE:[row col]
%   RHO   :A number between 0 and 1.0 ( 0 no correlation and 1 maximum correlation
%   The covariance function is defined as covmatrix= sigma*rho.^(d) where d 
%   is the euclidean distance between pixels
%   SIGMA : sigma of the normal distribution
%   MUIMG : This is the mean image specifying the mean value for each pixel
%   Output: 
%   NIMG,UIMG: Output images
%   Example : [nImg,uImg] = mipcorrimage([32, 32],0.95,5,zeros(32,32));
%
%   See also MIPDISKIMAGE MIPSPHEREIMAGE MIPSIGMOIDIMAGE

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox

if prod(size(muImg)) ~= prod(ImSize)
    printf(1,'Mean image (muImg) has to have the same dimensions');
    return;
end;
[r,c]  = find(ones(ImSize));
d      = squareform(pdist([r c],'euclidean'));
muvec  = muImg(:);
covmat = sigma*rho.^(d/2);
nImg   = reshape(mvnrnd(muvec,covmat,1),ImSize);
uImg   = normcdf(nImg);
