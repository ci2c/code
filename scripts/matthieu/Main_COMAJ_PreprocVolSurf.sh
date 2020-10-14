#!/bin/bash

INPUT_DIR=$1
FILE_PATH=$2
SUBJECTS_DIR=$3

# Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

# Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh


# # =====================================================================================
# #         Launch PET_COMAJ_PreprocVolSurf_native.sh : Cross or Longitudinal
# # =====================================================================================

## Preprocess all time points PET data cross-sectionally
# while read LINE
# do
# 	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
# 	NbTP=$(echo ${LINE} | awk '{print $2}')
# 	for i in `seq 1 ${NbTP}`;
# 	do
# 		j=$[$i+2]
# 		TP=$(echo ${LINE} | cut -d" " -f$j)
# 		SUBJECT_ID=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
# 		if [ $TP != M0 ]
# 		then
# 			if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} ]
# 			then
# 				mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID}
# 			fi
# 			qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N PetX_${SUBJECT_ID}_Seg8l0 PET_COMAJ_PreprocVolSurf_native.sh  -idPet ${INPUT_DIR} -sd ${SUBJECTS_DIR} -subjMri ${SUBJECT_ID} -scanner "GE" -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -oldSeg
# 			sleep 1
# 		fi
# 	done
# done < ${FILE_PATH}/Long_COMAJ

# if [ -s ${FILE_PATH}/subjects_CSF_long_ter ]
# then
# 	while read SUBJECT_ID
# 	do
# 		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} ]
# 		then
# 			mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID}
# 		fi
# 		# ## Launch PET preprocessing
# 		# qbatch -q M32_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N PetX_${SUBJECT_ID}_Seg8l0 PET_COMAJ_PreprocVolSurf.sh \
#     # -idPet ${INPUT_DIR} -sd ${SUBJECTS_DIR} -subjMri ${SUBJECT_ID} -scanner "Siemens" -DoInit -DoReg -ApplyReg -DoPVC -DoMeanRoi -DoIN -DoMask -DoSBA -oldSeg
# 		## Launch PET rbrainmask correction of GMROI
# 		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N bmask_${SUBJECT_ID}_Pet PET_COMAJ_PreprocVolSurf_brainmask.sh ${SUBJECTS_DIR} ${SUBJECT_ID}
# 		sleep 1
# 	done < ${FILE_PATH}/subjects_CSF_long
# fi

## Preprocess all time points PET data from cross to longitudinal
while read LINE
do
	SUBJ_ID=$(echo ${LINE} | awk '{print $1}')
	NbTP=$(echo ${LINE} | awk '{print $2}')
	for i in `seq 1 ${NbTP}`
	do
		j=$[$i+2]
		TP=$(echo ${LINE} | cut -d" " -f$j)
		id_cross=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -v -E "long.${SUBJ_ID}$")
		id_long=$(ls ${SUBJECTS_DIR} | grep -E "^${SUBJ_ID}_${TP}" | grep -E "long.${SUBJ_ID}$")
		if [ ! -d /NAS/tupac/protocoles/COMAJ/log/${id_long} ]
		then
			mkdir /NAS/tupac/protocoles/COMAJ/log/${id_long}
		fi
		qbatch -q three_job_q -oe /NAS/tupac/protocoles/COMAJ/log/${id_long} -N C2L_${id_long}_Pet PET_COMAJ_PreprocVolSurf_Long.sh ${SUBJECTS_DIR} ${id_cross} ${id_long} ${SUBJ_ID}
		sleep 1
	done
done < ${FILE_PATH}/Long_COMAJ_base_ter

# # =====================================================================================
# #         Perform surface second level statistical analysis (PALM)
# # =====================================================================================

# SUBJECTS_DIR=${FS_DIR}
#
# WD=/NAS/tupac/matthieu/SubCort_Analysis/PALM_AMN_LANG_VISU_EXE
WD=/NAS/tupac/matthieu/LME/PALM_X
#

# DescriptionDir=/NAS/tupac/matthieu/SubCort_Analysis/Description_files/Corr_VISU_EXE_FluenceP
DescriptionDir=/NAS/tupac/matthieu/LME/PALM_X/Description_files
#
# CD=TYPvsLANGvsVISUvsEXEvsNC_fwhm10_i10000_TFCE_defaults
Design=Design_palm_TYPvsLANGvsVISUvsEXE.csv
# -accel tail -n 500 -nouncorrected
# index=1

# InputDir=/NAS/tupac/matthieu/DARTEL/DIS/DARTEL
# InputSubjectsFile=/NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/subjects_TYPvsATYP.txt

## Subcortical analysis ##

# # Normalize c1 images onto MNI space ("Preserve Amount" : VBM)
# if [ -s ${InputSubjectsFile} ]
# then
# 	matlab -nodisplay <<EOF
#
# 	%% Load Matlab Path: Matlab 14 and SPM12 version
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
#
# 	DARTEL_NormalizeMNI_VBM('${InputDir}', '${InputSubjectsFile}');
# EOF
# fi
#
# # Smooth normalized c1 data with SubCortical mask #
# WD=/NAS/tupac/matthieu
# if [ -s /NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/subjects_TYPvsATYP.txt ]
# then
# 	while read subject
# 	do
# 		for fwhmvol in 10
# 		do
# 			Sigma=`echo "$fwhmvol / ( 2 * ( sqrt ( 2 * l ( 2 ) ) ) )" | bc -l`
# 			fslmaths ${InputDir}/mwc1.T1.npet.${subject}.nii -mas ${WD}/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -kernel gauss ${Sigma} -fmean ${InputDir}/sm${fwhmvol}mwc1.T1.npet.${subject}.nodil.nii.gz
# 			gunzip ${InputDir}/sm${fwhmvol}mwc1.T1.npet.${subject}.nodil.nii.gz
# 		done
# 	done < /NAS/tupac/matthieu/SubCort_Analysis/Description_files/TYPvsLANGvsVISUvsEXE/DARTEL_4Cov_MGRousset_SubCortMask/subjects_TYPvsATYP.txt
# fi

# # Merge PET and VBM data normalized on MNI152 #
# fslmerge -t ${DescriptionDir}/SubCortical_CorrPosFluenceP_MNI152 $(cat ${DescriptionDir}/glim.MGRousset.gn.fwhm10.txt)
# fslmerge -t ${DescriptionDir}/SubCortical_CorrPosFluenceP_MNI152_VBM $(cat ${DescriptionDir}/glim.vbm.fwhm10.txt)

# # PET TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod & F-contrast #
# qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_F palm -i ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_sm10.nii \
# -n 5000  \
# -m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T \
# -d ${WD}/${CD}/${Design} \
# -t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# -f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# -fonly -twotail \
# -logp -o ${WD}/${CD}/palm_F
# sleep 1
#
# # PET TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod & post-hoc T-contrasts #
# for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# do
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group} palm -i ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_sm10.nii \
# 	-n 5000 \
# 	-m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T \
# 	-d ${WD}/${CD}/${Design} \
# 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/${CD}/palm_${group}
# 	sleep 1
# done

# # PET TYPvsLANGvsVISUvsEXE + VBM as EV + TFCE : default parameters for pmethod & F-contrast #
# qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_F_VBMCov palm -i ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_sm10.nii \
# -n 5000  \
# -m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T \
# -evperdat ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_VBM_sm10.nii 5 1 \
# -d ${WD}/${CD}/${Design} \
# -t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# -f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# -fonly -twotail \
# -logp -o ${WD}/${CD}/palm_F
# sleep 1

# # PET TYPvsLANGvsVISUvsEXE + VBM as EV + TFCE : default parameters for pmethod & post-hoc T-contrasts #
# for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# do
# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_VBMCov palm -i ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_sm10.nii \
# 	-n 5000 \
# 	-m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T \
# 	-evperdat ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_VBM_sm10.nii 5 1 \
# 	-d ${WD}/${CD}/${Design} \
# 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/${CD}/palm_${group}
# 	sleep 1
# done

# # Correlations between all subjects and neuropsycho score #
# for group in CorrPosFluenceP
# do
# # 	## PET TYP_ATYP + TFCE : default parameters for pmethod ##
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${group}_tfce palm -i ${DescriptionDir}/SubCortical_TYPvsLANGvsVISUvsEXE_MNI152_sm10.nii \
# # 	-n 5000 \
# # 	-m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm_${group}
# # 	sleep 1
#
# 	## PET TYP_ATYP + VBM as EV + TFCE : default parameters for pmethod ##
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${group}_tfce
# 	palm -i ${DescriptionDir}/SubCortical_CorrPosFluenceP_MNI152.nii \
# 	-n 5000 \
# 	-m /NAS/tupac/matthieu/DARTEL/Mask_GM/Subcortical_mask_TPM_SPM12.nii -T \
# 	-evperdat ${DescriptionDir}/SubCortical_CorrPosFluenceP_MNI152_VBM.nii 3 1 \
# 	-d ${WD}/${CD}/${Design} \
# 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/${CD}/palm_${group}
# 	sleep 1
# done

# # TYPvsLANGvsVISUvsEXE : Analysis of subcortical volumes #
# asegstats2table --subjects $(cat ${DescriptionDir}/subjects_TYPvsATYP.txt) --meas volume --tablefile=${WD}/asegstats.txt

## Cortical analysis ##

# # Cluster extent multiple comparisons correction #
# # for clus_thresh in 1.6449 2.3263 2.5758 3.0902 3.2905 3.7190
# for clus_thresh in 1.6449 2.3263 2.5758 3.0902
# do
#
# # 	# With Average area correction
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${index}_lh palm -i ${WD}/lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh -s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -Cstat extent -C ${clus_thresh} -pmethodp none -pmethodr none \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/Contrasts_palm_TYPvsATYP.csv \
# # 	-save1-p -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/palm.th${index}.lh
# #
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${index}_rh palm -i ${WD}/rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh -s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -Cstat extent -C ${clus_thresh} -pmethodp none -pmethodr none \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/Contrasts_palm_TYPvsATYP.csv \
# # 	-save1-p -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000/palm.th${index}.rh
#
# # 	# Without Average area correction
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${index}_noArea_lh palm -i ${WD}/lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh -s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	-n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -Cstat extent -C ${clus_thresh} -pmethodp none -pmethodr none \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/Contrasts_palm_TYPvsATYP.csv \
# # 	-save1-p -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/palm.th${index}.lh
# #
# # 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_${index}_noArea_rh palm -i ${WD}/rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh -s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	-n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -Cstat extent -C ${clus_thresh} -pmethodp none -pmethodr none \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/Contrasts_palm_TYPvsATYP.csv \
# # 	-save1-p -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_DD_i10000_noAreaSurf/palm.th${index}.rh
#
# 	index=$[$index+1]
# done

# # Correlations between all subjects and neuropsycho score #
#
# for group in CorrPosPhTau CorrNegPhTau
# do
# # 	## PET TYP_ATYP + TFCE : default parameters for pmethod ##
# # 	qbatch -q three_job_q -oe ${WD}/Logdir -N palm_${group}_pearson_tfce_lh palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.lh
# # 	sleep 1
# #
# # 	qbatch -q three_job_q -oe ${WD}/Logdir -N palm_${group}_pearson_tfce_rh palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.rh
# # 	sleep 1
#
# 	## PET TYP_ATYP + CT as EV + TFCE : default parameters for pmethod ##
# 	qbatch -q M32_q -oe ${WD}/Logdir -N palm_${group}_tfce_lh palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 	-evperdat ${DescriptionDir}/lh.all.subjects.fsaverage.sm10.mgh 3 1 \
# 	-d ${WD}/${CD}/${Design} \
# 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/${CD}/palm.${group}.lh
# 	sleep 1
#
# 	qbatch -q M32_q -oe ${WD}/Logdir -N palm_${group}_tfce_rh palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 	-evperdat ${DescriptionDir}/rh.all.subjects.fsaverage.sm10.mgh 3 1 \
# 	-d ${WD}/${CD}/${Design} \
# 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/${CD}/palm.${group}.rh
# 	sleep 1
#
# # 	## CT TYP_ATYP + TFCE : default parameters for pmethod ##
# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CT_${group}_tfce_lh palm -i ${DescriptionDir}/lh.all.subjects.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.lh
# # 	sleep 1
# #
# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CT_${group}_tfce_rh palm -i ${DescriptionDir}/rh.all.subjects.fsaverage.sm10.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D -pearson \
# # 	-d ${WD}/${CD}/${Design} \
# # 	-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/${CD}/palm.${group}.rh
# # 	sleep 1
# done

# # Comparisons between TYP and ATYP groups #
# for group in TYPvsATYP ATYPvsTYP
# # for group in ATYPvsTYP
# do
# 	## PET TYPvsATYP + TFCE : default parameters for pmethod ##
# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_lh_1Cov palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/palm.${group}.lh
# 	sleep 1
#
# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_rh_1Cov palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_APOE4_i5000_TFCE_defaults/palm.${group}.rh
# 	sleep 1

# 	## CT TYPvsATYP + TFCE : default parameters for pmethod ##
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CT_tfce_${group}_lh palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.CT.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 	-d ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/palm.${group}.lh
# 	sleep 1
#
# 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CT_tfce_${group}_rh palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.CT.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 	-d ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_i5000_TFCE_defaults/palm.${group}.rh
# 	sleep 1
#
# # 	## PET TYPvsATYP + TFCE : default parameters for pmethod and ee+ise ##
# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_ee_ise_lh palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D -ee -ise \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/palm.${group}.lh
# # 	sleep 1
# #
# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_ee_ise_rh palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D -ee -ise \
# # 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/Design_palm_TYPvsATYP.csv \
# # 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/Contrasts_palm_${group}.csv \
# # 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_ee_ise/palm.${group}.rh
# # 	sleep 1
#
# # # 	## PET TYPvsATYP + Cluster Extent : default parameters for pmethod ##
# # # 	for clus_thresh in 1.6449 2.3263 2.5758 3.0902
# # 	for clus_thresh in 1.6449 2.3263 3.0902
# # 	do
# # 		qbatch -q two_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CE_${group}_${index}_lh palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -Cstat extent -C ${clus_thresh} \
# # 		-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/Design_palm_TYPvsATYP.csv \
# # 		-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/palm.${group}.th${index}.lh
# #
# # 		qbatch -q two_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_CE_${group}_${index}_rh palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -Cstat extent -C ${clus_thresh} \
# # 		-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/Design_palm_TYPvsATYP.csv \
# # 		-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_ClusterExtent/palm.${group}.th${index}.rh
# #
# # 		index=$[$index+1]
# # 	done
# # 	index=1

# 	## PET TYPvsATYP + CT as EV + TFCE : default parameters for pmethod ##
# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_ct_lh palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# 	-evperdat ${DescriptionDir}/lh.all.subjects.fwhm10.CT.mgh 7 1 \
# 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/palm.${group}.lh
# 	sleep 1
#
# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_${group}_ct_rh palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.PET.MGRousset.gn.mgh \
# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# 	-evperdat ${DescriptionDir}/rh.all.subjects.fwhm10.CT.mgh 7 1 \
# 	-d ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/Design_palm_TYPvsATYP.csv \
# 	-t ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/Contrasts_palm_${group}.csv \
# 	-logp -o ${WD}/TYPvsATYP_fwhm10_gn_MGRousset_4Cov_i5000_TFCE_defaults_CT_Cov/palm.${group}.rh
# 	sleep 1
#
# done

# # Comparisons between TYP, LANG, VISU and EXE groups #
# #
# # # for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # # for group in NCvsTYP NCvsATYP NCvsLANG NCvsVISU NCvsEXE TYPvsNC ATYPvsNC LANGvsNC VISUvsNC EXEvsNC
# # for group in TYPvsATYP ATYPvsTYP TYPvsEXE EXEvsTYP
# # # # # # for group in Cl1vsCl2 Cl2vsCl1 Cl1vsCl3 Cl3vsCl1 Cl2vsCl3 Cl3vsCl2
# # # for group in CorrPos_VAT2
# # # # # for group in F
# # do
# # # 	for TP in A0 A1 A2 A3
# # 	for TP in A1 A2 A3
# # 	do
# # 		CD=TYPvsLANGvsVISUvsEXE_${TP}_fwhm15_CT_i10000_TFCE
# #
# # # 		## PET TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod ##
# # # 		qbatch -q three_job_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_tfce_PET_lh_${group}_${TP}_i10000 palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.PET.MGRousset.gn.${TP}.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # # 		sleep 1
# # #
# # # 		qbatch -q three_job_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_tfce_PET_rh_${group}_${TP}_i10000 palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.PET.MGRousset.gn.${TP}.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # # 		sleep 1
# # 	#
# # 	# # 	## PET TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod & F-contrast ##
# # 	# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_PET_lh_F palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	# # 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	# # 	-d ${WD}/${CD}/${Design} \
# # 	# # 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# # 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# # 	-fonly -twotail \
# # 	# # 	-logp -o ${WD}/${CD}/palm.F.lh
# # 	# # 	sleep 1
# # 	# #
# # 	# # 	qbatch -q three_job_q -oe /NAS/tupac/matthieu/Logdir -N palm_tfce_PET_rh_F palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	# # 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	# # 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	# # 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	# # 	-d ${WD}/${CD}/${Design} \
# # 	# # 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# # 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# # 	-fonly -twotail \
# # 	# # 	-logp -o ${WD}/${CD}/palm.F.rh
# # 	# # 	sleep 1
# # 	#
# # 	# 	## CT TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod & F-contrast ##
# # 	# 	qbatch -q two_job_q@qotsa -oe /NAS/tupac/matthieu/Logdir -N palm_CT_tfce_lh_F palm -i ${DescriptionDir}/lh.all.subjects.CT.fsaverage.sm10.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.lh
# # 	# 	sleep 1
# # 	#
# # 	# 	qbatch -q two_job_q@bellamy -oe /NAS/tupac/matthieu/Logdir -N palm_CT_tfce_rh_F palm -i ${DescriptionDir}/rh.all.subjects.CT.fsaverage.sm10.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.rh
# # 	# 	sleep 1
# #
# # 		## CT TYPvsLANGvsVISUvsEXE + TFCE : default parameters for pmethod ##
# # 		qbatch -q three_job_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_CT_fwhm15_lh_${group}_${TP}_i10000 palm -i ${DescriptionDir}/lh.all.subjects.fwhm15.CT.${TP}.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # 		sleep 1
# #
# # 		qbatch -q three_job_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_CT_fwhm15_rh_${group}_${TP}_i10000 palm -i ${DescriptionDir}/rh.all.subjects.fwhm15.CT.${TP}.mgh \
# # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 		-d ${WD}/${CD}/${Design} \
# # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # 		sleep 1

# # 	# 	# PET TYPvsLANGvsVISUvsEXE + CT as EV + TFCE : default parameters for pmethod & F-contrast ##
# # 	# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_PET_tfce_lh_F_ct palm -i ${DescriptionDir}/lh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 5000 \
# # 	# 	-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # 	# 	-evperdat ${DescriptionDir}/lh.all.subjects.CT.fsaverage.sm10.mgh 9 1 \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.lh
# # 	# 	sleep 1
# # 	#
# # 	# 	qbatch -q M32_q -oe /NAS/tupac/matthieu/Logdir -N palm_PET_tfce_rh_F_ct palm -i ${DescriptionDir}/rh.all.subjects.PET.MGRousset.gn.fsaverage.sm10.mgh \
# # 	# 	-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # 	# 	/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 5000 \
# # 	# 	-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # 	# 	-evperdat ${DescriptionDir}/rh.all.subjects.CT.fsaverage.sm10.mgh 9 1 \
# # 	# 	-d ${WD}/${CD}/${Design} \
# # 	# 	-t ${WD}/${CD}/Contrasts_palm_t_groups.csv \
# # 	# 	-f ${WD}/${CD}/Contrasts_palm_F_groups.csv \
# # 	# 	-fonly -twotail \
# # 	# 	-logp -o ${WD}/${CD}/palm.F.rh
# # 	# 	sleep 1
# # 	#
# # # 		# PET TYPvsLANGvsVISUvsEXE + CT as EV + TFCE : default parameters for pmethod ##
# # # 		qbatch -q M32_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_PET_i10000_lh_${group}_${TP}_ct palm -i ${DescriptionDir}/lh.all.subjects.fwhm10.PET.MGRousset.gn.${TP}.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/lh.mask.mgh -T -tfce2D \
# # # 		-evperdat ${DescriptionDir}/lh.all.subjects.fwhm10.CT.${TP}.mgh 5 1 \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # # 		-logp -o ${WD}/${CD}/palm.${group}.lh
# # # 		sleep 1
# # #
# # # 		qbatch -q M32_q -oe /NAS/tupac/matthieu/LME/PALM_X/Logdir -N palm_PET_i10000_rh_${group}_${TP}_ct palm -i ${DescriptionDir}/rh.all.subjects.fwhm10.PET.MGRousset.gn.${TP}.mgh \
# # # 		-s /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white \
# # # 		/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white.avg.area.mgh -n 10000 \
# # # 		-m /NAS/tupac/matthieu/Masks/rh.mask.mgh -T -tfce2D \
# # # 		-evperdat ${DescriptionDir}/rh.all.subjects.fwhm10.CT.${TP}.mgh 5 1 \
# # # 		-d ${WD}/${CD}/${Design} \
# # # 		-t ${WD}/${CD}/Contrasts_palm_${group}.csv \
# # # 		-logp -o ${WD}/${CD}/palm.${group}.rh
# # # 		sleep 1
# # 	done
# # done

# # # =====================================================================================
# # #         Visualize stats results and make montages
# # # =====================================================================================
#
# # PALM_dir=/NAS/tupac/matthieu/LME/PALM_X
# # for TP in A0 A1 A2 A3
# # do
# # 	# PALM_dir=/NAS/tupac/matthieu/SubCort_Analysis/PALM_AMN_LANG_VISU_EXE
# # # 	cd ${PALM_dir}/TYPvsLANGvsVISUvsEXE_${TP}_fwhm15_CT_i10000_TFCE
# # 	cd ${PALM_dir}/TYPvsLANGvsVISUvsEXE_${TP}_fwhm10_MGR_gn_i10000_TFCE
# # # 	cd ${PALM_dir}/TYPvsLANGvsVISUvsEXE_${TP}_fwhm10_MGR_gn_i10000_TFCE_CT_Cov
# # 	for i in palm.*.?h_tfce_tstat_fwep.mgz ; do
# # 	# for i in palm.F.?h_tfce_fstat_fwep.mgz ; do
# # 	# for i in palm.*.?h_tfce_rstat_fwep.mgz ; do
# # 		base=${i%.mgz}
# # 		mri_convert $i ${base}.nii.gz
# # 	done
# # done
#
# # ## Threshold corrected p-maps at 90 mm2 (PET spatial resolution)
# # # # SUBJECTS_DIR=/NAS/tupac/matthieu/FS5.3
# # PALM_dir=/NAS/tupac/matthieu/LME/PALM_X
# PALM_dir=/NAS/tupac/matthieu/LME/PET_FS/TYPvsLANGvsVISUvsEXE/M0_M3
# SUBJECTS_DIR=/NAS/tupac/protocoles/COMAJ/FS53
# thmin_lh=0.02
# thmin_rh=0.02
# # for results in TYPvsLANGvsVISUvsEXE_A3_fwhm10_CT_i10000_TFCE
# # for results in TYPvsLANGvsVISUvsEXE_A3_fwhm10_MGR_gn_i10000_TFCE_CT_Cov
# for results in NoCov
# do
# #  	for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# #  	for group in TYPvsATYP ATYPvsTYP TYPvsEXE EXEvsTYP
#  	# for group in TYPvsATYP
#  	# for group in TYPvsEXE
#   for group in grp3
# 	do
# # 		thresh_lh=`fslstats ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# # 		thresh_bin_lh=`echo "${thresh_lh}>1.3" | bc`
# # 		thresh_rh=`fslstats ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.nii.gz -R | awk '{print $2}'`
# # 		thresh_bin_rh=`echo "${thresh_rh}>1.3" | bc`
# # 		if [ ${thresh_bin_lh} -eq 1 -o ${thresh_bin_rh} -eq 1 ]
# # 		then
# 			# mri_surfcluster --in ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.mgz --subject fsaverage --hemi lh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
# 			# --sum ${PALM_dir}/${results}/palm.${group}.lh.cluster.cs90.summary --ocn ${PALM_dir}/${results}/palm.${group}.lh.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/lh.${group}_tfce_tstat_fwep.cs90.mgh
# 			# mri_surfcluster --in ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.mgz --subject fsaverage --hemi rh --annot aparc.a2009s --thmin ${thmin_rh} --minarea 90 \
# 			# --sum ${PALM_dir}/${results}/palm.${group}.rh.cluster.cs90.summary --ocn ${PALM_dir}/${results}/palm.${group}.rh.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/rh.${group}_tfce_tstat_fwep.cs90.mgh
#
#       mri_surfcluster --in ${PALM_dir}/${results}/lh.sig.${group}.mgh --subject fsaverage --hemi lh --annot aparc.a2009s --thmin ${thmin_lh} --minarea 90 \
#       --sum ${PALM_dir}/${results}/lh.sig.${group}.cs90.summary --ocn ${PALM_dir}/${results}/lh.sig.${group}.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/lh.sig.${group}.cs90.mgh
#       mri_surfcluster --in ${PALM_dir}/${results}/rh.sig.${group}.mgh --subject fsaverage --hemi rh --annot aparc.a2009s --thmin ${thmin_rh} --minarea 90 \
#       --sum ${PALM_dir}/${results}/rh.sig.${group}.cs90.summary --ocn ${PALM_dir}/${results}/rh.sig.${group}.cluster_number.cs90.nii.gz --o ${PALM_dir}/${results}/rh.sig.${group}.cs90.mgh
# # 		fi
# 	done
# done
#
# # for results in TYPvsLANGvsVISUvsEXE_A3_fwhm10_CT_i10000_TFCE
# # for results in TYPvsLANGvsVISUvsEXE_A3_fwhm10_MGR_gn_i10000_TFCE_CT_Cov
# for results in NoCov
# # for results in ConjunctionAnalyses
# do
# # 	for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # 	for group in Cl1vsCl2 Cl2vsCl1 Cl1vsCl3 Cl3vsCl1 Cl2vsCl3 Cl3vsCl2
# # 	for group in VISUvsTYPconjVAT2
# # 	for group in LANGvsVISU VISUvsLANG EXEvsVISU
# 	# for group in TYPvsATYP
# 	# for group in TYPvsEXE
#   for group in grp3
# 	do
# # 		# T_tests
# # 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_tstat_fwep.mgz  \
# # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_tstat_fwep.mgz  -fminmax 1.3 3.7 -fmid 2.5  -output ${PALM_dir}/${results}/${group}.tiff -template -axial
#
# # 		# F_tests
# # 		Make_montage.sh  -fs  ${FS_DIR}  -subj  fsaverage  -surf white  -lhoverlay ${PALM_dir}/${results}/palm.${group}.lh_tfce_fstat_fwep.mgz  \
# # 		-rhoverlay ${PALM_dir}/${results}/palm.${group}.rh_tfce_fstat_fwep.mgz  -fminmax 1.3 3.7 -fmid 2.5  -output ${PALM_dir}/${results}/${group}.tiff -template -axial
# 	done
# done

# # =====================================================================================
# #         Getting Cluster and Peak Information from PALM Output
# # =====================================================================================

# # PALM_dir=/NAS/tupac/matthieu/SubCort_Analysis/PALM_AMN_LANG_VISU_EXE
# # for results in DARTEL.MGRousset.gn.sm10.SubCortMask
# # do
# # 	for group in TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # # 	for group in F
# # 	do
# # # 		# F-stat
# # # 		fslmaths ${PALM_dir}/${results}/palm_${group}_tfce_fstat_fwep.nii -thr 1.3 -bin -mul ${PALM_dir}/${results}/palm_${group}_tfce_fstat.nii ${PALM_dir}/${results}/palm_${group}_thresh_fstat
# # # 		cluster --in=${PALM_dir}/${results}/palm_${group}_thresh_fstat --thresh=0.0001 --oindex=${PALM_dir}/${results}/palm_${group}_cluster_index --olmax=${PALM_dir}/${results}/palm_${group}_lmax.txt --osize=${PALM_dir}/${results}/palm_${group}_cluster_size --mm
# # 		# T-stat
# # 		fslmaths ${PALM_dir}/${results}/palm_${group}_tfce_tstat_fwep.nii -thr 1.3 -bin -mul ${PALM_dir}/${results}/palm_${group}_tfce_tstat.nii ${PALM_dir}/${results}/palm_${group}_thresh_tstat
# # 		cluster --in=${PALM_dir}/${results}/palm_${group}_thresh_tstat --thresh=0.0001 --oindex=${PALM_dir}/${results}/palm_${group}_cluster_index --olmax=${PALM_dir}/${results}/palm_${group}_lmax.txt --osize=${PALM_dir}/${results}/palm_${group}_cluster_size --mm
# # 	done
# # done
#
# # # Localize anatomical regions from MNI coordinates
# # for results in DARTEL.MGRousset.gn.sm10.SubCortMask
# # do
# # 	for group in F TYPvsATYP ATYPvsTYP TYPvsLANG LANGvsTYP TYPvsVISU VISUvsTYP TYPvsEXE EXEvsTYP LANGvsVISU VISUvsLANG LANGvsEXE EXEvsLANG VISUvsEXE EXEvsVISU
# # 	do
# # # 		sed '1d' ${PALM_dir}/${results}/palm_${group}_lmax.txt | cut -f 3,4,5 | sed -e 's/\t/,/g' > ${PALM_dir}/${results}/palm_${group}_lmax_CoordMNI.txt
# # 		while read Coord3D
# # 		do
# # 			atlasquery -a "Harvard-Oxford Subcortical Structural Atlas" -c ${Coord3D} >> ${PALM_dir}/${results}/palm_${group}_lmax_AnatLocSub.txt
# # 			sleep 1
# # 		done < ${PALM_dir}/${results}/palm_${group}_lmax_CoordMNI.txt
# # 		paste ${PALM_dir}/${results}/palm_${group}_lmax_CoordMNI.txt ${PALM_dir}/${results}/palm_${group}_lmax_AnatLocSub.txt > ${PALM_dir}/${results}/palm_${group}_lmax_resultsSub.txt
# # 	done
# # done
