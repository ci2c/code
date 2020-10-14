#!/bin/bash
	
if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: PrepProcess_TRACULA.sh InputDir SubjId OutpuDir"
	echo ""
	echo "  InputDir         : Input directory containing the rec/par files"
	echo "  SubjId           : Id of the subject treated"
	echo "  OutpuDir         : Output directory containing the bvec & bval files and DTI32.nii"
	echo ""
	echo "Usage: PrepProcess_TRACULA.sh InputDir SubjId OutpuDir"
	echo ""
	exit 1
fi

## I/O management
INPUT_DIR=$1
SUBJ_ID=$2
OUTPUT_DIR=$3

## Creation of bvec & bval files from REC/PAR
DTI_PAR=$(ls ${INPUT_DIR}/${SUBJ_ID}/*dti32*.par)
cd ${INPUT_DIR}/${SUBJ_ID}
par2bval_transpose.sh ${DTI_PAR}

## Copy of bvec & bval files and dti32 nifti to output directory
mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}
cp ${INPUT_DIR}/${SUBJ_ID}/*dti32*.bvec ${INPUT_DIR}/${SUBJ_ID}/*dti32*.bval ${INPUT_DIR}/${SUBJ_ID}/*dti32*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}
gunzip ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.nii.gz

## Removal of the last mean DTI frame from input .nii file and merge into DTI32.nii
# fslsplit ${OUTPUT_DIR}/${SUBJ_ID}/*dti32*.nii ${OUTPUT_DIR}/${SUBJ_ID}/vol
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/vol0033*.gz
# fslmerge -a ${OUTPUT_DIR}/${SUBJ_ID}/DTI32.nii ${OUTPUT_DIR}/${SUBJ_ID}/vol00*.gz
# rm -f ${OUTPUT_DIR}/${SUBJ_ID}/vol00*
# gunzip ${OUTPUT_DIR}/${SUBJ_ID}/DTI32.nii.gz

## Pre-processing
trac-all -prep -c ${OUTPUT_DIR}/dmrirc.example

## Ball-and-stick model fit
trac-all -bedp -c ${OUTPUT_DIR}/dmrirc.example

## Reconstructing white-matter pathways
trac-all -path -c ${OUTPUT_DIR}/dmrirc.example
