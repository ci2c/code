#!/bin/bash

FS_DIR=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask

for subj in 580620CG_M6
do
space=`expr index "$subj" "_"`
subjid=${subj:0:( ${space}-1 )}


	if [ ! -e ${FS_DIR}/${subj}/mri/brain.nii ]; then
	mri_convert ${FS_DIR}/${subj}/mri/brain.mgz ${FS_DIR}/${subj}/mri/brain.nii
	fi

	if [ ! -d ${FS_DIR}/${subj}/rsfmri/ ]; then
		mkdir ${FS_DIR}/${subj}/rsfmri/
	fi

	FMRI_feat.sh -o ${FS_DIR}/${subj}/rsfmri -subj ${subj} -epi ${FS_DIR}/${subj}/rsfmri/20110112_113832FEEPI64x64restingstateSENSEs701a1007.nii.gz -TR 2.4 -rmframe 3 -fwhm 5 -brain_mask ${FS_DIR}/${subj}/mri/brain.nii -FS_dir ${FS_DIR}/${subj}/ -Prepro -useFix

	sleep 60
done