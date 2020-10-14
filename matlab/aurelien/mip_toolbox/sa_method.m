% Matlab Script: sa_method.m
%
% This Matlab scipt computes an optimal threshold value using
% the concept of Tsallis entropy and then using the optimal value
% binarizes an image. This script uses the functions sahoo_thresh 
% and brink_thresh. The thresholded images are displayed along 
% with the original image, and its gray level histogram.
%
% To run this scipt, you have to input the name of an 
% monochrome image such as  saturn.tif or sahoo.jpg.
%
% You need to input the alpha value used in the computation of 
% Tsallis entropy. The alpha value should be a positive real number 
% and it should not be equal to one.

%
% Read the user supplied image file
%
IMAGE = input('Please enter the name of the gray-valued image:','s');
[I] = imread(IMAGE);
%
% Read the number of gray levels in the input image
%
numgray = 256;
% numgray = input('Enter the number of gray levels in this image:');
%
% Read the user supplied q-value for Tsallis entropy
%
alpha = input('Enter a positive q-value that is not equal to one:  ');
%
% Store the input image in I2 for later use
%
I2 = I(:,:,1);
IR = I(:,:,1);
IR = double(IR);
graylevel1 = sahoo_thresh(IR, alpha, numgray);
threshold1 = graylevel1/numgray;
BW1 = im2bw(I2, threshold1);
%
graylevel2 = brink_thresh(IR, numgray);
threshold2 = graylevel2/numgray;
BW2 = im2bw(I2, threshold2);
%
disp('      ')
fprintf('The optimal threshold value with Sahoo-Arora method is %3.0f \n',...
    graylevel1)
disp('      ')
%
disp('      ')
fprintf('The optimal threshold value with Abutaleb-Brink method is %3.0f \n',...
    graylevel2)
disp('      ')
%
%  Display the original, binarized images and other
%  information relevent to this thresholding method.
%
figure
subplot(2,2,1), imshow(I2); title('original image')
subplot(2,2,2), imhist(I2), title('gray level histogram'); axis('square');
subplot(2,2,3), imshow(BW1); title(sprintf('thresholded at t*(%3.1f) = %3.0f',...
    alpha, graylevel1)) 
subplot(2,2,4), imshow(BW2); title(sprintf('thresholded at t*(1.0) = %3.0f',...
    graylevel2)) 
% To print the figure into a file type from the command 
% window print myfigure.ps. The figure will be save in postscript 
% format in a file called "myfigure.ps"
%
print my_sa_figure.ps

