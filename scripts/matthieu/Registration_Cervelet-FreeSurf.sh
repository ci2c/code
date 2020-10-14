#!/bin/bash

SUBJECTS_DIR=$1
SUBJECT_ID=$2

## Cervelet-FreeSurf : Register T1 between subjects (non-linear) + apply registration to .label files ##

# # # Rigid registration
# # flirt -dof 6 -in ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/T1_las.nii.gz -ref ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/T1_las.nii.gz -omat ${SUBJECTS_DIR}/${SUBJECT_ID}/RigidReg/T1bt2T1.mat -out ${SUBJECTS_DIR}/${SUBJECT_ID}/RigidReg/T1bt2T1.nii.gz
# # tkregister2 --mov ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/T1_las.nii.gz --targ ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/T1_las.nii.gz --fsl ${SUBJECTS_DIR}/${SUBJECT_ID}/RigidReg/T1bt2T1.mat --noedit --reg ${SUBJECTS_DIR}/${SUBJECT_ID}/RigidReg/T1bt2T1.dat
# # 
# # for label in AV MCP_l MCP_r SCP_l SCP_r
# # do 
# # 	mri_label2label --srclabel ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/label/${label}.label --srcsubject BEAULIEUX^THOMAS_2013-04-29 \
# # 	  --trglabel ${label}_reg.label --trgsubject ${SUBJECT_ID} \
# # 	  --regmethod volume \
# # 	  --reg ${SUBJECTS_DIR}/${SUBJECT_ID}/RigidReg/T1bt2T1.dat
# # done
# 
# # # Non-linear registration with FSL
# # bet my_structural my_betted_structural
# # flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in my_betted_structural -omat my_affine_transf.mat
# # fnirt --in=my_structural --aff=my_affine_transf.mat --cout=my_nonlinear_transf --config=T1_2_MNI152_2mm
# # applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=my_structural --warp=my_nonlinear_transf --out=my_warped_structural

# # Convert labels to volumes
# for label in AV MCP_l MCP_r SCP_l SCP_r
# do 
# 	mri_label2vol --label ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/label/${label}.label --temp ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/T1_las.nii.gz --identity --o ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/${label}.nii.gz
# done

# # Non-linear registration with ANTs
# if [ ! -d ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration ]
# then
# 	mkdir ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration
# else
# 	rm -f ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/*
# fi
# antsRegistrationSyNQuick.sh -d 3 -f ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/T1_las.nii.gz -m ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/T1_las.nii.gz -o ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/T1bt2T1_ -t s

# Apply non-linear registration to ROIs and convert to labels
for label in AV MCP_l MCP_r SCP_l SCP_r
do 
	${ANTSPATH}/antsApplyTransforms -d 3 \
		-i ${SUBJECTS_DIR}/BEAULIEUX^THOMAS_2013-04-29/mri/${label}.nii.gz \
		-r ${SUBJECTS_DIR}/${SUBJECT_ID}/mri/T1_las.nii.gz \
		-o ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/${label}_reg.nii.gz \
		-n NearestNeighbor \
		-t ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/T1bt2T1_1Warp.nii.gz \
		-t ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/T1bt2T1_0GenericAffine.mat

	mri_cor2label --i ${SUBJECTS_DIR}/${SUBJECT_ID}/T1_registration/${label}_reg.nii.gz --id 1 --l ${SUBJECTS_DIR}/${SUBJECT_ID}/label/${label}_reg.label
done


