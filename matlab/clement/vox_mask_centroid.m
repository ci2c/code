function [x,y,z]=vox_mask_centroid(niiFile)

% This function compute the barycenter of a voxel mask in MNI space
% Usage  : centr_coord=vox_mask_centroid(niiFile)
%
% Input  : nii voxel mask in MNI coordinates
%
% Output : Coordinates of the barycenter
%
% Clément Bournonville - Ci2C - CHU Lille - 02/2016


% Load Image
vol=spm_vol(niiFile);
img=spm_read_vols(vol);

ID=find(img > 0);

siz=size(img);
sx=siz(1);
sy=siz(2);
sz=siz(3);

% Write coordinates


for i=1:length(ID)
    
    [x,y,z]=coord1Dto3D(ID(i),sx,sy,sz);
    tmp=[x,y,z];
    
    coord=[tmp(1) tmp(2) tmp(3) ones(size(tmp,1),1)]*(vol.mat)';
    real_mat(i,:)=round(coord(1:3));
    
end

% Compute centroid
[X,Y] = size(real_mat);
if X == 1
    cent_real = real_mat;
else
    cent_real=round(mean(real_mat));
    x=cent_real(1);
    y=cent_real(2);
    z=cent_real(3);
end

