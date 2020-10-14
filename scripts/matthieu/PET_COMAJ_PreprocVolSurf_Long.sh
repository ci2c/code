#!/bin/bash

SUBJECTS_DIR=$1
echo "SUBJECTS_DIR: $SUBJECTS_DIR"
SUBJECT_ID=$2
echo "SUBJECT_ID: $SUBJECT_ID"
SUBJECT_ID_LONG=$3
echo "SUBJECT_ID_LONG: $SUBJECT_ID_LONG"
SUBJ_ID=$4
echo "SUBJ_ID: $SUBJ_ID"

DoInit=1
DoConcatenate=1
DoSBA=1
pvedir=pvelab_Seg8_l0

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

# ========================================================================================================================================
#                                                        INITIALIZATION
# ========================================================================================================================================

if [ $DoInit -eq 1 ]
then
	if [ -d ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet ]
	then
	    rm -rf ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/*
	else
	    mkdir ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet
	fi

	if [ -d ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir} ]
	then
	    rm -rf ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/*
	else
	    mkdir ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}
	fi

	mri_convert ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/mri/T1.mgz ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/T1.lia.nii.gz
fi

# ========================================================================================================================================
#                                  Combine rigid transforms : Pet2T1 + T1cross2T1long
# ========================================================================================================================================

if [ $DoConcatenate -eq 1 ] && [ ! -s ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/rPET.lia.BS7.nii.gz ]
then

	mri_concatenate_lta ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/Pet2T1.BS7.register.dof6.lta ${SUBJECTS_DIR}/${SUBJ_ID}/mri/transforms/${SUBJECT_ID}_to_${SUBJ_ID}.lta \
	${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.lta

	mri_vol2vol --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.nii.gz --targ ${SUBJECTS_DIR}/${SUBJ_ID}/mri/norm_template.mgz --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/rPET.lia.BS7.nii.gz \
	--lta ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.lta --no-save-reg

	#### lta_convert with FS6_b ####

	export FREESURFER_HOME=${Soft_dir}/freesurfer6_b/
	export FSFAST_HOME=${Soft_dir}/freesurfer6_b/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer6_b/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

	lta_convert --inlta ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.lta --outreg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.dat

	export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
	export FSFAST_HOME=${Soft_dir}/freesurfer5.3/fsfast
	export MNI_DIR=${Soft_dir}/freesurfer5.3/mni
	. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

	####

	cat ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.dat | sed "/subject-unknown/s/subject-unknown/${SUBJECT_ID_LONG}/g" > ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat
	mri_vol2vol --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.nii.gz --targ ${SUBJECTS_DIR}/${SUBJ_ID}/mri/norm_template.mgz --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/rPET.lia.BS7.reg.nii.gz \
	--reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat --no-save-reg
fi

# ========================================================================================================================================
#                                  Resample PET data onto native and common surfaces
# ========================================================================================================================================

if [ $DoSBA -eq 1 ] && [ ! -f ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.MGCS.gn.fsaverage.sm18.mgh ]
then
	if [ -d ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf ]
	then
	    rm -rf ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/*
	else
	    mkdir ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf
	fi

	if [ -d ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf ]
	then
	    rm -rf ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/*
	else
	    mkdir ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf
	fi

	## Resample brain mask onto native surface
	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
	--trgsubject ${SUBJECT_ID_LONG} --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.nii --noreshape --cortex \
	--surfreg sphere.reg

	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
	--trgsubject ${SUBJECT_ID_LONG} --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.nii --noreshape --cortex \
	--surfreg sphere.reg

	## Resample brain mask onto fs_average surface
	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
	--trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex \
	--surfreg sphere.reg
	mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/BS7_PET.lps.brain_mask.dil1.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
	--trgsubject fsaverage --interp nearest --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii --noreshape --cortex \
	--surfreg sphere.reg

# 	for type_norm in npons ncereb gn
	for type_norm in ncereb gn
	do
		## Resample onto native surface
		# lh
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/PET.lps.BS7.${type_norm}.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
		--trgsubject ${SUBJECT_ID_LONG} --interp trilin --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.mgh --noreshape \
		--cortex --surfreg sphere.reg

		# rh
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/PET.lps.BS7.${type_norm}.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
		--trgsubject ${SUBJECT_ID_LONG} --interp trilin --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.mgh --noreshape \
		--cortex --surfreg sphere.reg

		# smooth
		for fwhmsurf in 0 3 6 8 9 10 12 15 18
		do
	# 		mri_surf2surf --hemi lh --s ${SUBJECT_ID_LONG} --fwhm ${fwhmsurf} --label-trg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET_brain_mask.label --sval ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET_${type_norm}.mgh --tval ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET_${type_norm}.sm${fwhmsurf}.mgh
			mris_fwhm --s ${SUBJECT_ID_LONG} --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.mgh --fwhm ${fwhmsurf} \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.sm${fwhmsurf}.mgh \
			--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.nii

			mris_fwhm --s ${SUBJECT_ID_LONG} --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.mgh --fwhm ${fwhmsurf} \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.sm${fwhmsurf}.mgh \
			--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.nii
		done

		## Resample onto fsaverage
		# lh
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/PET.lps.BS7.${type_norm}.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
		--trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.mgh --noreshape \
		--cortex --surfreg sphere.reg

		# rh
		mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/PET.lps.BS7.${type_norm}.nii.gz --reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat \
		--trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.mgh --noreshape \
		--cortex --surfreg sphere.reg

		# smooth
		for fwhmsurf in 0 3 6 8 9 10 12 15 18
		do
			mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.${type_norm}.fsaverage.sm${fwhmsurf}.mgh \
			--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii

			mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.mgh --fwhm ${fwhmsurf} \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.${type_norm}.fsaverage.sm${fwhmsurf}.mgh \
			--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
		done

		for type_pvc in MGRousset MGCS
		do
			## Resample onto native surface
			# lh
			mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz \
			--reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat --trgsubject ${SUBJECT_ID_LONG} --interp trilin --projfrac 0.5 --hemi lh \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz \
			--reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat --trgsubject ${SUBJECT_ID_LONG} --interp trilin --projfrac 0.5 --hemi rh \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 3 6 8 9 10 12 15 18
			do
				mris_fwhm --s ${SUBJECT_ID_LONG} --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh \
				--fwhm ${fwhmsurf} --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh \
				--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.nii

				mris_fwhm --s ${SUBJECT_ID_LONG} --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.mgh \
				--fwhm ${fwhmsurf} --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.sm${fwhmsurf}.mgh \
				--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.nii
			done

			## Resample onto fsaverage
			# lh
			mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz \
			--reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# rh
			mri_vol2surf --mov ${SUBJECTS_DIR}/${SUBJECT_ID}/pet/${pvedir}/PET.BS7.lps.${type_pvc}.${type_norm}.nii.gz \
			--reg ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/Pet2T1.long.register.dof6.m.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh \
			--o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh --noreshape --cortex --surfreg sphere.reg

			# smooth
			for fwhmsurf in 0 3 6 8 9 10 12 15 18
			do
				mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh \
				--fwhm ${fwhmsurf} --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/lh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh \
				--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/lh.PET.lps.BS7.brain_mask.fsaverage.nii

				mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.mgh \
				--fwhm ${fwhmsurf} --o ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/${pvedir}/surf/rh.PET.BS7.lps.${type_pvc}.${type_norm}.fsaverage.sm${fwhmsurf}.mgh \
				--mask ${SUBJECTS_DIR}/${SUBJECT_ID_LONG}/pet/surf/rh.PET.lps.BS7.brain_mask.fsaverage.nii
			done
		done
	done
fi
