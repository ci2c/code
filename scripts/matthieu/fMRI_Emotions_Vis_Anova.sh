#!/bin/bash

subjFile=/home/notorious/NAS/matthieu/fMRI_Emotions/Visages/subjlist.txt
indir=/home/notorious/NAS/matthieu/fMRI_Emotions/Visages

for subj in `cat ${subjFile}`
do
	
	echo "${subj}"
	mri_convert ${indir}/${subj}/spm/FirstLevel/con_0001.img ${indir}/${subj}/spm/con_0001.nii
	mri_convert ${indir}/${subj}/spm/FirstLevel/con_0002.img ${indir}/${subj}/spm/con_0002.nii
	mri_convert ${indir}/${subj}/spm/FirstLevel/con_0003.img ${indir}/${subj}/spm/con_0003.nii

done

3drefit -deoblique anova_result+orig.HEAD
3drefit -xorigin cen -yorigin cen -zorigin cen anova_result+orig.HEAD
mri_convert -it afni -ot nii anova_result+orig.BRIK anova_res.nii

3dFDR


