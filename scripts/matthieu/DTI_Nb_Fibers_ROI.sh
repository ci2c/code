#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: DTI_Nb_Fibers_ROI.sh -roi <NameRoi> -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -roi		: Name of the ROI used for Connectum"
	echo "  -subjid		: Subject ID"
	echo "	-base		: Dti number"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Nb_Fibers_ROI.sh -roi <NameRoi> -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
ROI=$1
SUBJ_ID=$2
BASE=$3
OUTPUT_DIR=$4
lmax=$5
Nfiber=$6

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/${ROI}_Color.tck ]
then
	matlab -nodisplay <<EOF
	NbFibres = getVolConnectMatrix('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/r${ROI}b_${BASE}_LAS.nii', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}', '${ROI}');
	
	fid = fopen('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.txt', 'a');
	fprintf(fid, '${ROI} : %d fibres\n', NbFibres);
	fclose(fid);
	
	% tmp = [${ROI}, num2str(NbFibres)];
	% xlswrite('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.xls',tmp);
EOF
# 	echo "${ROI} : ${NbFibres} fibres" >> ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.txt
fi