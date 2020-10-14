function Volumes = getROIVolumes(labels, Connectome)
% usage: Volumes = getROIVolumes(labels, Connectome)
%
% Returns ROI volumes
%
% Inputs :
%   labels     : path to the label image .nii
%   Connectome : Connectome structure
%
% Output :
%   Volumes    : vector of ROI volumes
%
% Pierre Besson, June 2012

V = spm_vol(labels);
[Y, XYZ] = spm_read_vols(V);
Y = round(Y);

voxel_volume = abs(det(V.mat(1:3,1:3)));
nROI = length(Connectome.region);
Volumes = zeros(nROI, 1);

for i = 1 : nROI
    vol = sum(Y(:) == Connectome.region(i).label);
    Volumes(i) = voxel_volume * vol;
end