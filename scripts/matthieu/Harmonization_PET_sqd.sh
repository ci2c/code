#!/bin/bash

OUTDIR=/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses

DIR=$1
RECON=$2
SUBJECT_ID=$3
fwhmsurf=$4

# #### 1. Compute SSD between native surface PET reconstructions ####
# 
# for hemi in lh rh
# do
# 	# No PVC and intensity normalization
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.sqd.mgh ${DIR}/pet_std/${RECON}/surf/${hemi}.PET.lps.BS7.gn.mgh \
# 	sqd ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.mgh 
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.gn.ssd.${SUBJECT_ID}.txt ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.sqd.mgh sum
# 
# 	# PVC and intensity normalization
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.sqd.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.mgh \
# 	sqd ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.mgh 
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.MGRousset.gn.ssd.${SUBJECT_ID}.txt ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.sqd.mgh sum
# done

#### 2. Compute SSD between fsaverage surface PET reconstructions ####

# for hemi in lh rh
# do
# 	# No PVC and intensity normalization
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sqd.mgh ${DIR}/pet_std/${RECON}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.mgh \
# 	sqd ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.mgh 
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.gn.fsaverage.ssd.${SUBJECT_ID}.txt ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sqd.mgh sum	
# 
# 	# PVC and intensity normalization
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sqd.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.mgh \
# 	sqd ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.mgh 
# 	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}.MGRousset.gn.fsaverage.ssd.${SUBJECT_ID}.txt ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sqd.mgh sum
# done

#### 3. Compute SQD between fsaverage surface PET reconstructions at fwhmsurf = 10 ####
for hemi in lh rh
do
	# No PVC and intensity normalization
	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.gn.fsaverage.sm${fwhmsurf}.sqd.mgh ${DIR}/pet_std/${RECON}/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh \
	sqd ${DIR}/pet_std/OT_i2s21_g2/surf/${hemi}.PET.lps.BS7.gn.fsaverage.sm${fwhmsurf}.mgh 	

	# PVC and intensity normalization
	mris_calc -o ${DIR}/pet_std/SSD/${hemi}.PET.${RECON}-OT_i2s21_g2.MGRousset.gn.fsaverage.sm${fwhmsurf}.sqd.mgh ${DIR}/pet_std/${RECON}/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh \
	sqd ${DIR}/pet_std/OT_i2s21_g2/pvelab_Seg8_l0/surf/${hemi}.PET.BS7.lps.MGRousset.gn.fsaverage.sm${fwhmsurf}.mgh 
done