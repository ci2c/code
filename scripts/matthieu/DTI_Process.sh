#!/bin/bash
	
if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_Process.sh INPUT_DIR FS_DIR SUBJ_ID OUTPUT_DIR Lin"
	echo ""
	echo "  INPUT_DIR	: Input directory containing the rec/par files"
	echo "  FS_DIR		: Path to FS output directory"
	echo "  SUBJ_ID		: Subjects ID"
	echo "  OUTPUT_DIR	: Path to FSL output directory"
	echo ""
	echo "Optional argument :"
	echo "  Lin 		: Apply linear registration instead of nonlinear registration"
	echo ""
	echo "Usage: DTI_Process.sh INPUT_DIR FS_DIR SUBJ_ID OUTPUT_DIR Lin"
	echo ""
	exit 1
fi

Lin=0

## I/O management
INPUT_DIR=$1
FS_DIR=$2
SUBJ_ID=$3
OUTPUT_DIR=$4

# ## Creation of bvec & bval files from REC/PAR
# DTI_PAR=$(ls ${INPUT_DIR}/${SUBJ_ID}/*dti32*.par)
# cd ${INPUT_DIR}/${SUBJ_ID}
# par2bval.sh ${DTI_PAR}
# 
# ## Copy of bvec & bval files and dti32 nifti to output directory
# mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}
# cp ${INPUT_DIR}/${SUBJ_ID}/*dti32*.bvec ${INPUT_DIR}/${SUBJ_ID}/*dti32*.bval ${INPUT_DIR}/${SUBJ_ID}/*dti32*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}
# gunzip ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.nii.gz

####################
# Step #1 :Creation of output directories and moves source files
####################

if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps -a ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig ]
then
	mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/dti/{steps,orig}
	mv -t ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.bvec ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.bval ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.nii
fi

# 	DIR=${fs}/${Subject}
# 	cd ${DIR}/dti
	
#####################
# Step #2 : Run eddy correct
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/eddy-correct.touch ]
then
	eddy_correct ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/*dti32*.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii 0
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/eddy-correct.touch
fi
	
#####################
# Step #3 : Correct bvecs
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/rotate_bvecs.touch ]
then
	rotate_bvecs ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.ecclog ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/*dti32*.bvec
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/rotate_bvecs.touch
fi
	
#####################
# Step #4 : Prepare for bedpostx
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/BET.touch ]
then
	bet ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr_brain.nii -F -f 0.25 -g 0 -m
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/BET.touch
fi
	
if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX ]
then
	mkdir ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX
fi

# cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/data.nii.gz
# cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr_brain_mask.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/nodif_brain_mask.nii.gz
# cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/*dti32*.bval ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/bvals
# cp ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/*dti32*.bvec ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/bvecs
 	
#####################
# Step #5 : Run dtifit
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/dtifit.touch ]
then
	dtifit --data=${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii.gz --out=${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr --mask=${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr_brain_mask.nii.gz --bvecs=${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/bvecs --bvals=${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX/bvals
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/dtifit.touch
fi
	
#####################
# Step #6 : Non-linear fitting of T1 on DTI B0
#####################

# if [ -f ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ]
# then
# 	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/T1.mgz ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/t1_ras.nii --out_orientation RAS
# 	if [ ${Lin} -eq 0 ]
# 	then
# 		if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/nlfit_t1_to_b0.touch ]
# 		then
# 			NlFit_t1_to_b0.sh -source ${OUTPUT_DIR}/${SUBJ_ID}/dti/orig/t1_ras.nii -target ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii.gz -o ${OUTPUT_DIR}/${SUBJ_ID}/dti/nl_fit/ -newsegment
# 			touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/nlfit_t1_to_b0.touch
# 		fi
# 	else
# 		if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/lfit_t1_to_b0.touch ]
# 		then
# 			LinFit_t1_to_b0.sh -source ${DIR}/dti/orig/t1_ras.nii -target ${OUTPUT_DIR}/${SUBJ_ID}/dti/data_corr.nii.gz -o ${OUTPUT_DIR}/${SUBJ_ID}/dti/lin_fit/ -newsegment
# 			touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/lfit_t1_to_b0.touch
# 		fi
# 	fi
# fi
	
#####################
# Step #6 : Run bedpostx
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/bedpostx.touch ]
then
	bedpostx ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX -n 2 -w 1 -b 1000
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/bedpostx.touch
fi

#####################
# Step #6 : Run probtrackx
#####################

if [ ! -f ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/probtrackx.touch ]
then
	probtrackx --mode=simple --seedref=${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX.bedpostX/nodif_brain_mask -o probtrackx -x ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX.bedpostX/fdt_coordinates.txt -l -c 0.2 -S 2000 --steplength=0.5 -P 5000 --forcedir --opd -s ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX.bedpostX/merged -m ${OUTPUT_DIR}/${SUBJ_ID}/dti/DataBPX.bedpostX/nodif_brain_mask --dir=${OUTPUT_DIR}/${SUBJ_ID}/dti/probtrackx
	touch ${OUTPUT_DIR}/${SUBJ_ID}/dti/steps/probtrackx.touch
fi