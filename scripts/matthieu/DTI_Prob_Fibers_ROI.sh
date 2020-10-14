#!/bin/bash

if [ $# -lt 5 ]
then
	echo ""
	echo "Usage: DTI_Prob_Fibers_ROI.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -roi		: Name of the ROI used for tractography"
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Prob_Fibers_ROI.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
ROI=$1
SUBJ_ID=$2
OUTPUT_DIR=$3
lmax=$4
Nfiber=$5

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti/Prob_${ROI}_CC.nii.gz ]
then
	matlab -nodisplay <<EOF
	getCCConnectMatrix('${OUTPUT_DIR}/${SUBJ_ID}/dti/rCorpsCalleux_maskb_dti.nii','${OUTPUT_DIR}/${SUBJ_ID}/dti/${ROI}_${lmax}_${Nfiber}.tck','${OUTPUT_DIR}/${SUBJ_ID}/dti','${ROI}','${OUTPUT_DIR}/${SUBJ_ID}/dti/dti_finalcor_FA.nii');
EOF
fi