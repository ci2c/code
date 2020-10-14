#!/bin/bash

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

# Assign input values of arguments
FS_DIR=$1
SUBJ_ID=$2
# Prefix="TEM_"
# FWHM=6
# GRP=G3

# ## Extract binary masks of left and right hyppocampus
# mri_extract_label ${FS_DIR}/${SUBJ_ID}/mri/aseg.mgz 17 ${FS_DIR}/../ShapeAnalysis/Left_hyppocampus/${Prefix}${SUBJ_ID}_lh.nii.gz
# mri_extract_label ${FS_DIR}/${SUBJ_ID}/mri/aseg.mgz 53 ${FS_DIR}/../ShapeAnalysis/Right_hyppocampus/${Prefix}${SUBJ_ID}_rh.nii.gz

## Assign new value of SUBJECTS_DIR and run -qcache recon step
SUBJECTS_DIR=${FS_DIR}

rm -f ${SUBJECTS_DIR}/${SUBJ_ID}/surf/?h.thickness.fsaverage.mgh ${SUBJECTS_DIR}/${SUBJ_ID}/surf/?h.thickness.fwhm*.fsaverage.mgh

recon-all -qcache -sd ${SUBJECTS_DIR} -s ${SUBJ_ID} -no-isrunning

## Smooth cortical thickness on surface
# mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${FS_DIR}/${SUBJ_ID}/surf/lh.thickness.fsaverage.mgh --fwhm ${FWHM} --o ${FS_DIR}/${SUBJ_ID}/surf/lh.thickness.fwhm${FWHM}.fsaverage.mgh
# mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${FS_DIR}/${SUBJ_ID}/surf/rh.thickness.fsaverage.mgh --fwhm ${FWHM} --o ${FS_DIR}/${SUBJ_ID}/surf/rh.thickness.fwhm${FWHM}.fsaverage.mgh
# 
# echo -e "${FS_DIR}/${SUBJ_ID}/surf/lh.thickness.fwhm${FWHM}.fsaverage.mgh\t${FS_DIR}/${SUBJ_ID}/surf/rh.thickness.fwhm${FWHM}.fsaverage.mgh\t${GRP}" >> ${FS_DIR}/glim_fwhm${FWHM}_${GRP}_Thickness.txt


# matlab -nodisplay <<EOF
# 	cd ${HOME}
# 	p = pathdef;
# 	addpath(p);
# 	cat_fibers(2500000,10000,'${FS_DIR}/${SUBJ_ID}/dti','whole_brain_6_2500000');
# EOF

# cd ${FS_DIR}/${SUBJ_ID}/dti
# rm -rf $(ls -l | grep Dec | awk '{print $9}')