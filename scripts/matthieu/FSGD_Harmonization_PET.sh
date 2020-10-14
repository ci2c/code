#!/bin/bash

WD=$1
RECON=$2
fwhmsurf=$3
PVC=$4
hemi=$5
FILE_PATH=$6

# ## Paired t-test ##
# 
# mri_glmfit \
# --glmdir ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.paired-diff \
# --y ${FILE_PATH}/${hemi}.all.subjects.fwhm${fwhmsurf}.PET.${PVC}.gn.fsaverage.${RECON}-OT_i2s21_g2.mgh \
# --fsgd ${FILE_PATH}/../paired-diff-noAge.fsgd \
# --C ${FILE_PATH}/../SourcevsTarget.mtx \
# --C ${FILE_PATH}/../TargetvsSource.mtx \
# --surf fsaverage ${hemi} \
# --cortex
# 
# cp ${FILE_PATH}/${hemi}.all.subjects.fwhm${fwhmsurf}.PET.${PVC}.gn.fsaverage.${RECON}-OT_i2s21_g2.mgh ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.paired-diff
# 
# for clus_thresh in 1.3 2 2.3 3 3.3 4
# do 
# 	 mri_glmfit-sim \
# 	--glmdir ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.paired-diff \
# 	--cache ${clus_thresh} pos \
# 	--cwp  0.05 \
# 	--2spaces
# done

## Two-sample t-test ##

mri_glmfit \
  --glmdir ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.g2v0 \
  --y ${FILE_PATH}/${hemi}.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhmsurf}.${RECON}.mgh \
  --fsgd ${FILE_PATH}/g2v0.fsgd \
  --C ${FILE_PATH}/SourcevsTarget.mtx \
  --C ${FILE_PATH}/TargetvsSource.mtx \
  --surf fsaverage ${hemi} \
  --cortex
  
cp ${FILE_PATH}/${hemi}.all.subjects.PET.${PVC}.gn.fsaverage.sm${fwhmsurf}.${RECON}.mgh ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.g2v0

for clus_thresh in 1.3 2 2.3 3 3.3 4
do 
	 mri_glmfit-sim \
	--glmdir ${WD}/${RECON}_fwhm${fwhmsurf}_${PVC}/${hemi}.g2v0 \
	--cache ${clus_thresh} pos \
	--cwp  0.05 \
	--2spaces
done