#!/bin/bash

if [ $# -lt 7 ]
then
	echo ""
	echo "Usage: DTI_Nb_Fibers_Inter_ROI.sh -roi1 <NameRoi1> -roi2 <NameRoi2> -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -roi1		: Name of the ROI1 used for Connectum"
	echo "  -roi2		: Name of the ROI2 used for Connectum"	
	echo "  -subjid		: Subject ID"
	echo "	-base		: Dti number"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Nb_Fibers_Inter_ROI.sh -roi1 <NameRoi1> -roi2 <NameRoi2> -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
ROI1=$1
ROI2=$2
SUBJ_ID=$3
BASE=$4
OUTPUT_DIR=$5
lmax=$6
Nfiber=$7

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/${ROI1}_${ROI2}_Color.tck ]
then
	matlab -nodisplay <<EOF
	NbFibres = getInterConnectFib('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/${ROI1}_ConnectFib.mat', '${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/${ROI2}_ConnectFib.mat', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}', '${ROI1}_${ROI2}');
	
	fid = fopen('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.txt', 'a');
	fprintf(fid, '${ROI1}_${ROI2} : %d fibres\n', NbFibres);
	fclose(fid);
	
	% tmp = [${ROI1}_${ROI2}, num2str(NbFibres)];
	% xlswrite('${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.xls',tmp);	
EOF
# 	echo "${ROI1}_${ROI2} : ${NbFibres} fibres" >> ${OUTPUT_DIR}/${SUBJ_ID}/Connectum_${BASE}/NbFibres_${SUBJ_ID}_${BASE}.txt
fi