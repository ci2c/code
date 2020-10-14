#!/bin/bash

WD=/NAS/dumbo/protocoles/LEMP/FS5.3/LONG_analysis
Subj=Araujo_Jarmela_Manuel

# cd ${WD}/${Subj}
# tbss_1_preproc *.nii.gz

# # # ANTS affine registration estimation
# ANTS 3 -m MI[${WD}/${Subj}/FA/dti_finalcor_FA_3_FA.nii.gz,${WD}/${Subj}/FA/dti_finalcor_FA_1_FA.nii.gz,1,32] -o ${WD}/${Subj}/FA/AT1toT3 -i 0 --rigid-affine true
# 		
# # Then reslice ROIs to DTI space
# WarpImageMultiTransform 3 ${WD}/${Subj}/FA/dti_finalcor_FA_1_FA.nii.gz ${WD}/${Subj}/FA/Adti_finalcor_FA_1_to_3.nii.gz ${WD}/${Subj}/FA/AT1toT3Affine.txt -R ${WD}/${Subj}/FA/dti_finalcor_FA_3_FA.nii.gz

# antsRegistrationSyNQuick.sh -d 3 -f ${WD}/${Subj}/FA/dti_finalcor_FA_3_FA.nii.gz -m ${WD}/${Subj}/FA/dti_finalcor_FA_1_FA.nii.gz -o ${WD}/${Subj}/FA/srT1toT3 -t sr

# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${WD}/${Subj}/non_FA/dti_finalcor_MD_2.nii.gz \
# 	-r ${WD}/${Subj}/non_FA/dti_finalcor_MD_3.nii.gz \
# 	-o ${WD}/${Subj}/non_FA/srT2toT3_MD.nii.gz \
# 	-n Linear \
# 	-t ${WD}/${Subj}/FA/srT2toT31Warp.nii.gz \
# 	-t ${WD}/${Subj}/FA/srT2toT30GenericAffine.mat
# 	
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${WD}/${Subj}/non_FA/dti_finalcor_L1_2.nii.gz \
# 	-r ${WD}/${Subj}/non_FA/dti_finalcor_L1_3.nii.gz \
# 	-o ${WD}/${Subj}/non_FA/srT2toT3_L1.nii.gz \
# 	-n Linear \
# 	-t ${WD}/${Subj}/FA/srT2toT31Warp.nii.gz \
# 	-t ${WD}/${Subj}/FA/srT2toT30GenericAffine.mat
# 
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${WD}/${Subj}/non_FA/dti_finalcor_L2_2.nii.gz \
# 	-r ${WD}/${Subj}/non_FA/dti_finalcor_L2_3.nii.gz \
# 	-o ${WD}/${Subj}/non_FA/srT2toT3_L2.nii.gz \
# 	-n Linear \
# 	-t ${WD}/${Subj}/FA/srT2toT31Warp.nii.gz \
# 	-t ${WD}/${Subj}/FA/srT2toT30GenericAffine.mat
# 	
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-i ${WD}/${Subj}/non_FA/dti_finalcor_L3_2.nii.gz \
# 	-r ${WD}/${Subj}/non_FA/dti_finalcor_L3_3.nii.gz \
# 	-o ${WD}/${Subj}/non_FA/srT2toT3_L3.nii.gz \
# 	-n Linear \
# 	-t ${WD}/${Subj}/FA/srT2toT31Warp.nii.gz \
# 	-t ${WD}/${Subj}/FA/srT2toT30GenericAffine.mat
	
# # Warp V1 map
# ${ANTSPATH}/antsApplyTransforms -d 3 \
# 	-e 1 \
# 	-i ${WD}/${Subj}/non_FA/dti_finalcor_V1_2.nii.gz \
# 	-r ${WD}/${Subj}/non_FA/dti_finalcor_V1_3.nii.gz \
# 	-o ${WD}/${Subj}/non_FA/srT2toT3_V1.nii.gz \
# 	-n Linear \
# 	-t ${WD}/${Subj}/FA/srT2toT31Warp.nii.gz \
# 	-t ${WD}/${Subj}/FA/srT2toT30GenericAffine.mat