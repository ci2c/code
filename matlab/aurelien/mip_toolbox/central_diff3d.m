% function dimg = central_diff3d(img,direction)
% Calculates the central-difference for the given direction
% inputs:
% img : input image
% direction:
% can be any of the horizontal,vertical and diagonal directions
% denoted by the symbols 'dx','dy', 'dz',
% output:
% dimg :difference image
% Example: 
% This example computes the central difference in x direction
% dimg = difference_function(img,'dx');

function dimg = central_diff3d(img,direction)

[row,col,zdim]=size(img);

dimg = img;

switch (direction)   
case 'dx',
   dimg(:,2:col-1,:) = img(:,3:col,:)-img(:,1:col-2,:);
case 'dy',
   dimg(2:row-1,:,:) = img(3:row,:,:)-img(1:row-2,:,:);
case 'dz',
   dimg (:,:,2:zdim-1) = img(:,:,3:zdim)-img(:,:,1:zdim-2);
otherwise, disp('Direction is unknown'); dimg = 0;
end;