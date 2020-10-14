#!/bin/bash

fwhmvol=$1
InputDir=$2
subject=$3
PVC=$4
Recon=$5

Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
if [ “${PVC}” == “noPVC” ]
then
	fslmaths ${InputDir}/PET/${PVC}/${Recon}/wPET.gn.${subject}.nii -mas ${InputDir}/Template/MNI152_T1_brain_mask.nii -kernel gauss ${Sigma} \
	-fmean ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.gn.${subject}.nii.gz
	gunzip ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.gn.${subject}.nii.gz
elif [ “${PVC}” == “PVC” ]
then
	fslmaths ${InputDir}/PET/${PVC}/${Recon}/wPET.MGRousset.gn.${subject}.nii -mas ${InputDir}/Template/Mask_GM_MNI.nii -kernel gauss ${Sigma} \
	-fmean ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.MGRousset.gn.${subject}.nii.gz
	gunzip ${InputDir}/PET/${PVC}/${Recon}/sm${fwhmvol}.wPET.MGRousset.gn.${subject}.nii.gz
fi