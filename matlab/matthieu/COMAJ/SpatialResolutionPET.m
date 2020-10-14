clear all; close all;

mri = MRIread('/NAS/tupac/protocoles/COMAJ/FS53/207138_M0_2014-10-22/pet/PET_resolution/PET.lps.BS7.gn.res.noresample.nii.gz');

% Binarise two voxels
value1=mri.vol(19,16,16);
value2=mri.vol(19,18,20);

vox1=find(mri.vol==value1);
vox2=find(mri.vol==value2);

matrix= zeros(size(mri.vol));
matrix([vox1 vox2])=1;

mri_out=mri;
mri_out.vol=matrix;
MRIwrite(mri_out,'/NAS/tupac/protocoles/COMAJ/FS53/207138_M0_2014-10-22/pet/PET_resolution/PET.lps.BS7.gn.res.noresample.bin.nii.gz','double');
