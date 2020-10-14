#!/bin/bash

SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53

DIR=$1
RECON=$2
Sigma=$3
fwhmvol=$4
fwhmsurf=$5

#### 1. Compute subtractions between native voxel-wise PET reconstructions ####

# Without (PVC and intensity normalization)
# fslmaths ${DIR}/pet_std/${RECON}/BS7_PET.lps.nii.gz -sub ${DIR}/pet_std/OT_i2s21_g2/BS7_PET.lps.nii.gz -mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz \
# ${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2
#
# # PVC and no intensity normalization
# fslmaths ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.nii.gz -sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.nii.gz \
# -mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz ${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2.MGRousset

# No PVC and intensity normalization
fslmaths ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.nii.gz -mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz -kernel gauss ${Sigma} \
-fmean ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.sm${fwhmvol}
fslmaths ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.sm${fwhmvol} -sub ${DIR}/pet_std/OT_i2s21_g2/PET.lps.BS7.gn.sm${fwhmvol} \
${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2.sm${fwhmvol}.gn

fslmaths ${DIR}/pet_std/${RECON}/PET.lps.BS7.gn.nii.gz -sub ${DIR}/pet_std/OT_i2s21_g2/PET.lps.BS7.gn.nii.gz -mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz \
${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2.gn

# PVC and intensity normalization
fslmaths ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.nii.gz -mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz -kernel gauss ${Sigma} \
-fmean ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.sm${fwhmvol}
fslmaths ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.sm${fwhmvol} -sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.sm${fwhmvol} \
${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2.MGRousset.sm${fwhmvol}.gn

fslmaths ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.nii.gz -sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/PET.BS7.lps.MGRousset.gn.nii.gz \
-mas ${DIR}/pet_std/${RECON}/rbrainmask.npet.nii.gz ${DIR}/pet_std/native/PET.${RECON}-OT_i2s21_g2.MGRousset.gn

#### 2. Compute subtractions between native surface PET reconstructions ####

# No PVC and intensity normalization
mris_calc -o ${DIR}/pet_std/native/lh.PET.${RECON}-OT_i2s21_g2.gn.mgh ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.gn.mgh sub ${DIR}/pet_std/OT_i2s21_g2/surf/lh.PET.lps.BS7.gn.mgh
mris_calc -o ${DIR}/pet_std/native/rh.PET.${RECON}-OT_i2s21_g2.gn.mgh ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.gn.mgh sub ${DIR}/pet_std/OT_i2s21_g2/surf/rh.PET.lps.BS7.gn.mgh

# PVC and intensity normalization
mris_calc -o ${DIR}/pet_std/native/lh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.mgh \
${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.mgh sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.mgh
mris_calc -o ${DIR}/pet_std/native/rh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.mgh \
${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.mgh sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.mgh

#### 3. Compute subtractions between fsaverage surface PET reconstructions ####

No PVC and intensity normalization
mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
--o ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
--o ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
mris_calc -o ${DIR}/pet_std/common/lh.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sm${fwhmsurf}.mgh ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/surf/lh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh
mris_calc -o ${DIR}/pet_std/common/rh.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sm${fwhmsurf}.mgh ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/surf/rh.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh	 	

mris_calc -o ${DIR}/pet_std/common/lh.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.mgh ${DIR}/pet_std/${RECON}/surf/lh.PET.lps.BS7.gn.fsaverage.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/surf/lh.PET.lps.BS7.gn.fsaverage.mgh
mris_calc -o ${DIR}/pet_std/common/rh.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.mgh ${DIR}/pet_std/${RECON}/surf/rh.PET.lps.BS7.gn.fsaverage.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/surf/rh.PET.lps.BS7.gn.fsaverage.mgh

PVC and intensity normalization
mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
--o ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh --fwhm ${fwhmsurf} \
--o ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh --cortex
mris_calc -o ${DIR}/pet_std/common/lh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh
mris_calc -o ${DIR}/pet_std/common/rh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh

mris_calc -o ${DIR}/pet_std/common/lh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/lh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh
mris_calc -o ${DIR}/pet_std/common/rh.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh \
sub ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/rh.PET.BS7.lps.MGRousset.gn.fsaverage.mgh