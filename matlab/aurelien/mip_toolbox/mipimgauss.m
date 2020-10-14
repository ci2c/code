
function img = mipimgauss(dims, mean,variance,k)
% MIPIMGAUSS   Creates an image(1D,2D or 3D) with Gaussian noise
%
%   IMD = MIPIMGAUSS(DIMS,MEAN,VARIANCE)
%   
%   DIMS = [ROWS COLS ZDIM]
%   MEAN and VARIANCE are the mean and variance parameters
%   K = 1
%   IMG is the output image
%   See also 
%
%   Example:
%     img = mipimgauss([32,32],0,5,1);

%   Omer Demirkaya, Musa Asyali, Prasana Shaoo, ... 9/1/06
%   Medical Image Processing Toolbox
       
switch k
    case 1
        img = sqrt(variance).*randn(dims(1),1)+ mean;
    case 2
        img = sqrt(variance).*randn(dims(1),dims(2))+ mean;
    case 3
        img = sqrt(variance).*randn(dims(1),dims(2),dims(3))+ mean;
end


