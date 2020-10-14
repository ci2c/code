#!/bin/bash

if [ $# -lt 5 ]
then
	echo ""
	echo "Usage: DTI_Nb_Fibers_ROIs.sh -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "	-base		: Dti number"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Nb_Fibers_ROIs.sh -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
SUBJ_ID=$1
BASE=$2
OUTPUT_DIR=$3
lmax=$4
Nfiber=$5

# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${BASE}.txt ]
# then
	matlab -nodisplay <<EOF
	getMultiVolConnectMatrix('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}', '${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/ROIs.txt', '${BASE}');
EOF
# fi