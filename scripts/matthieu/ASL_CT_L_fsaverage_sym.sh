#!/bin/bash

SUBJECTS_DIR=$1
SUBJECT_ID=$2

for FWHM in 5 10
do
	for var in cbf_s cbf_pvc_s
	do
		# Project cbf_s on white surface
	# 	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/cbf_s.nii.gz --projfrac 0.5 --interp nearest --surf white --regheader ${SUBJECT_ID} --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/lh.cbf_s.mgh
	# 	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/cbf_s.nii.gz --projfrac 0.5 --interp nearest --surf white --regheader ${SUBJECT_ID} --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/rh.cbf_s.mgh
		
		# Project cbf_pvc_s on white surface
	# 	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/${var}.nii.gz --projfrac 0.5 --interp trilin --surf white --regheader ${SUBJECT_ID} --hemi lh --trgsubject ${SUBJECT_ID} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/lh.${var}.mgh \
	# 	--noreshape --cortex --surfreg sphere.reg
	# 	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/${var}.nii.gz --projfrac 0.5 --interp trilin --surf white --regheader ${SUBJECT_ID} --hemi rh --trgsubject ${SUBJECT_ID} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/rh.${var}.mgh \
	# 	--noreshape --cortex --surfreg sphere.reg
		
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/${var}/native_space/perfusion_calib.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Perf2T1.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.${var}.mgh \
		--noreshape --cortex --surfreg sphere.reg
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/${var}/native_space/perfusion_calib.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Perf2T1.register.dof6.dat --trgsubject ${SUBJECT_ID} --interp trilin --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.${var}.mgh \
		--noreshape --cortex --surfreg sphere.reg

		# Register lh/rh cbf_pvc_s surface data on fsaverage_sym
	# 	mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi lh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi lh --trgsurfreg sphere.reg \
	# 	--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fsaverage_sym.${var}.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/lh.${var}.mgh --noreshape --no-cortex
	# 	mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi rh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi rh --trgsurfreg sphere.reg \
	# 	--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fsaverage_sym.${var}.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/Surface_Analyses/rh.${var}.mgh --noreshape --no-cortex
		
		mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi lh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi lh --trgsurfreg sphere.reg \
		--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fsaverage_sym.${var}.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.${var}.mgh --noreshape --no-cortex
		mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi rh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi rh --trgsurfreg sphere.reg \
		--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fsaverage_sym.${var}.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.${var}.mgh --noreshape --no-cortex

		# Register lh/rh thickness surface data on fsaverage_sym
	# 	mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi lh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi lh --trgsurfreg sphere.reg \
	# 	--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fsaverage_sym.thickness.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.thickness --sfmt curv --noreshape --no-cortex
	# 	mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi rh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi rh --trgsurfreg sphere.reg \
	# 	--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fsaverage_sym.thickness.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.thickness --sfmt curv --noreshape --no-cortex
		
		mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi lh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi lh --trgsurfreg sphere.reg \
		--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fsaverage_sym.thickness.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.thickness --sfmt curv --noreshape --no-cortex
		mri_surf2surf --srcsubject ${SUBJECT_ID} --srchemi rh --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trghemi rh --trgsurfreg sphere.reg \
		--tval ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fsaverage_sym.thickness.mgh --sval ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.thickness --sfmt curv --noreshape --no-cortex

		# Smooth lh/rh cbf_pvc_s surface data on fsaverage_sym
	# 	mris_fwhm --s fsaverage_sym --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fsaverage_sym.${var}.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fwhm${FWHM}.fsaverage_sym.${var}.mgh --cortex
	# 	mris_fwhm --s fsaverage_sym --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fsaverage_sym.${var}.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fwhm${FWHM}.fsaverage_sym.${var}.mgh --cortex
		
		mris_fwhm --s fsaverage_sym --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fsaverage_sym.${var}.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fwhm${FWHM}.fsaverage_sym.${var}.mgh --cortex
		mris_fwhm --s fsaverage_sym --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fsaverage_sym.${var}.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fwhm${FWHM}.fsaverage_sym.${var}.mgh --cortex

		# Smooth lh/rh thickness surface data on fsaverage_sym
	# 	mris_fwhm --s fsaverage_sym --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fsaverage_sym.thickness.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/lh.fwhm${FWHM}.fsaverage_sym.thickness.mgh --cortex
	# 	mris_fwhm --s fsaverage_sym --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fsaverage_sym.thickness.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/surf/rh.fwhm${FWHM}.fsaverage_sym.thickness.mgh --cortex

		mris_fwhm --s fsaverage_sym --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fsaverage_sym.thickness.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/lh.fwhm${FWHM}.fsaverage_sym.thickness.mgh --cortex
		mris_fwhm --s fsaverage_sym --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fsaverage_sym.thickness.mgh --fwhm ${FWHM} --o ${SUBJECTS_DIR}/${SUBJECT_ID}/asl/bbr/Surface_Analyses/rh.fwhm${FWHM}.fsaverage_sym.thickness.mgh --cortex
		
		# Compute lh/rh ${var} zscore data
		ComputeZscoreVol_fwhm_ASL.sh ${SUBJECTS_DIR} ${SUBJECT_ID} ${var} ${FWHM} "LTLE"
	done
done