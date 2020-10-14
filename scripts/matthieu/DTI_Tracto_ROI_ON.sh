#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_Tracto_ROI_ON.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers> -field <StrengthField>"
	echo ""
	echo "  -roi		: Name of the ROI used for tractography"
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo "  -field          : Strength of magnetic field (1000 or 2000)"
	echo ""
	echo "Usage: DTI_Tracto_ROI_ON.sh -roi <NameRoi> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers> -StrengthField <StrengthField>"
	echo ""
	exit 1
fi

## I/O management
ROI=$1
SUBJ_ID=$2
DTI=$3
lmax=$4
Nfiber=$5
StrenghtField=$6
# CutOff=$6
# Exclusion_ROI=$7

if [ ! -e ${DTI}/lmax${lmax}/r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck ]
then
	# Stream locally to avoid RAM filling
	rm -f /tmp/${SUBJ_ID}_b${StrenghtField}_r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck
	streamtrack SD_PROB ${DTI}/CSD${lmax}.mif -seed ${DTI}/r${ROI}_3DT1_dti.mif -mask ${DTI}/rm3DT1_brain_mask_dti.mif /tmp/${SUBJ_ID}_b${StrenghtField}_r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck -num ${Nfiber}

	cp -f /tmp/${SUBJ_ID}_b${StrenghtField}_r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck ${DTI}/lmax${lmax}/r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck
	rm -f /tmp/${SUBJ_ID}_b${StrenghtField}_r${ROI}_3DT1_dti_${lmax}_${Nfiber}.tck
fi
