#!/bin/bash

INPUT_DIR=$1
SUBJECTS_DIR=$2
SUBJ_ID=$3

# Prepare Dti DICOM files

if [ ! -d ${SUBJECTS_DIR}/${SUBJ_ID}/dti ]
then
	mkdir -p ${SUBJECTS_DIR}/${SUBJ_ID}/dti
else
	rm -rf ${SUBJECTS_DIR}/${SUBJ_ID}/dti/*
fi

DtiNii=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTI64*.nii*)
if [ -n "${DtiNii}" ]
then
	if [[ ${DtiNii} == ${INPUT_DIR}/${SUBJ_ID}/*DTI64*.nii ]]
	then
		gzip ${DtiNii}
		DtiNii=${DtiNii}.gz
	fi

	base=`basename ${DtiNii}`
	base=${base%.nii.gz}
	fbval=${INPUT_DIR}/${SUBJ_ID}/${base}.bval
	fbvec=${INPUT_DIR}/${SUBJ_ID}/${base}.bvec
	NbCol=$(cat ${fbval} | wc -w)

	if [ ${NbCol} -eq 65 ]
	then				
		# Copy files from input to output /dti directory
		cp -t ${SUBJECTS_DIR}/${SUBJ_ID}/dti ${fbval} ${fbvec} ${DtiNii}
		mv ${SUBJECTS_DIR}/${SUBJ_ID}/dti/${base}.nii.gz ${SUBJECTS_DIR}/${SUBJ_ID}/dti/dti.nii.gz
		mv ${SUBJECTS_DIR}/${SUBJ_ID}/dti/${base}.bval ${SUBJECTS_DIR}/${SUBJ_ID}/dti/dti.bval
		mv ${SUBJECTS_DIR}/${SUBJ_ID}/dti/${base}.bvec ${SUBJECTS_DIR}/${SUBJ_ID}/dti/dti.bvec
		
		# Zip and copy dticorrection file
		DtiCorr=$(ls ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii*)
		if [ -n "${DtiCorr}" ]
		then
			if [ $(ls -1 ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii | wc -l) -gt 0 ]
			then
				gzip ${INPUT_DIR}/${SUBJ_ID}/*DTICORR*.nii
				DtiCorr=${DtiCorr}.gz
			fi 
			cp -t ${SUBJECTS_DIR}/${SUBJ_ID}/dti ${DtiCorr}			
			mv ${SUBJECTS_DIR}/${SUBJ_ID}/dti/*DTICORR*.nii.gz ${SUBJECTS_DIR}/${SUBJ_ID}/dti/dti_back.nii.gz
		else
			echo "Le fichier ${SUBJ_ID}/DTICORR.nii n'existe pas"
		fi	
	else
		echo "Le nombre de colonnes dans le fichier bval est <> 65"
	fi
else
	echo "Le fichier ${SUBJ_ID}/DTI64.nii n'existe pas"
fi