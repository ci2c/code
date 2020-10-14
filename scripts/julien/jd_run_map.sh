#!/bin/bash
	
mnc2nii -nii T2map.mnc
mnc2nii -nii T2.mnc

mri_convert --out_orientation RAS T2.nii T2_n.nii
mri_convert --out_orientation RAS T2map.nii T2map_n.nii
fslorient -forceradiological T2_n.nii
fslorient -forceradiological T2map_n.nii
mri_convert --out_orientation RAS T1_ref.mnc T1_ref.nii
ANTS 3 -m MI[T1_ref.nii,T2_n.nii,1,32] -o T2toT1 -i 0 --rigid-affine true
WarpImageMultiTransform 3 T2_n.nii T2_cor.nii  T2toT1Affine.txt -R T1_ref.nii
WarpImageMultiTransform 3 T2map_n.nii T2map_cor.nii  T2toT1Affine.txt -R T1_ref.nii
mri_convert --out_orientation RAS T2_cor.nii T2_cor.mnc
mri_convert --out_orientation RAS T2map_cor.nii T2map_cor.mnc
