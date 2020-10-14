% Matlab Script: ksw_method.m
%
% This Matlab scipt computes an optimal threshold value using
% the concept of Shannon's entropy and then using the optimal 
% value binarizes an image.
% The binarized image is displayed along with the original 
% image, its gray level histogram, and the plot of the 
% objective function, TotalEnt.
%
% To run this scipt, you have to input the name of an 
% image such as rice.tif or tire.tif. 
%
% This script runs only for tif or gif images. 
clear all
clc
NBINS = 256;
%
% Read the user supplied image file
%
IMAGE = input('Please enter the name of the tif image:  ', 's');
I = imread(IMAGE);
I3 = double(I);
numgray = NBINS;
I2 = I;
%
% Function mipentropy_th.m is used here
%
[graylevel, nco, h] = mipentropy_th(I3, NBINS);
threshold = graylevel/numgray;
BW2 = im2bw(I2, threshold);
%
disp('      ')
fprintf('The optimal threshold value is %3.0f \n',  graylevel)
disp('      ')
%
% Display the original, binarized images and other
% information relevent to this thresholding method.
subplot(2,2,1), imshow(I2) 
title('original image') 
subplot(2,2,2), plot(ii,h),
title('gray level histogram') 
axis('square');
subplot(2,2,3), imshow(BW2);  
title('thresholded image') 
subplot(2,2,4), plot(ii,0.5*nco)
title('normalized \psi (s) function'); 
axis('square');
%
% To print the figure into a file type from the command 
% window print myfigure.ps.  The figure will be save in 
% postscript format in a file called "myfigure.ps"
%
print myfigure.ps

