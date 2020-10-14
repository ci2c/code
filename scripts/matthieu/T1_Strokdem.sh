#!/bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: T1_Strokdem.sh INPUT_DIR SUBJ_ID OUTPUT_DIR"
	echo ""
	echo "  INPUT_DIR	: Input directory containing the rec/par files"
	echo "  SUBJ_ID		: Subjects ID"
	echo "  OUTPUT_DIR	: Path to FSL output directory"
	echo ""
	echo "Usage: T1_Strokdem.sh INPUT_DIR SUBJ_ID OUTPUT_DIR"
	echo ""
	exit 1
fi

## I/O management
INPUT_DIR=$1
SUBJ_ID=$2
OUTPUT_DIR=$3

DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI15*.nii*)
if [ -z "${DtiNii}" ]
then
	# Creation of a temporary source directory
	if [ ! -d ${INPUT_DIR}/${SUBJ_ID}/T1 ]
	then
		mkdir ${INPUT_DIR}/${SUBJ_ID}/T1
	else
		rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/T1/*
	fi
	
	Search of 3dt1 rec/par files
	AnaMin=$(ls ${INPUT_DIR}/${SUBJ_ID}/*3dt1*.par)
	AnaMaj=$(ls ${INPUT_DIR}/${SUBJ_ID}/*3DT1*.PAR)

	if [ -n "${AnaMin}" ]
	then
		cp -t ${INPUT_DIR}/${SUBJ_ID}/T1 ${INPUT_DIR}/${SUBJ_ID}/*3dt1*.rec ${INPUT_DIR}/${SUBJ_ID}/*3dt1*.par
	elif [ -n "${AnaMaj}" ]
	then
		cp -t ${INPUT_DIR}/${SUBJ_ID}/T1 ${INPUT_DIR}/${SUBJ_ID}/*3DT1*.REC ${INPUT_DIR}/${SUBJ_ID}/*3DT1*.PAR
	fi

	# Calculus of T1 nii files from rec/par files
	if [ -n "${AnaMin}" ] || [ -n "${AnaMaj}" ]
	then
		if [ ! -d ${OUTPUT_DIR}/${SUBJ_ID}/T1 ]
		then
			mkdir -p ${OUTPUT_DIR}/${SUBJ_ID}/T1
		else 
			rm -rf ${OUTPUT_DIR}/${SUBJ_ID}/T1/*
		fi
		
		# Conversion from rec/par T1 to nii files
		dcm2nii -f Y -o ${OUTPUT_DIR}/${SUBJ_ID}/T1 ${INPUT_DIR}/${SUBJ_ID}/T1/* 
		
		if [ -n "${AnaMin}" ]
		then
			mv ${OUTPUT_DIR}/${SUBJ_ID}/T1/*3dt1*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/T1/T1.nii.gz

		elif [ -n "${AnaMaj}" ]
		then
			mv ${OUTPUT_DIR}/${SUBJ_ID}/T1/*3DT1*.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/T1/T1.nii.gz
		fi
	fi
	
	# Move back rec/par files from temp input directory to input dir, and delete temp directory
	rm -rf ${INPUT_DIR}/${SUBJ_ID}/T1
fi