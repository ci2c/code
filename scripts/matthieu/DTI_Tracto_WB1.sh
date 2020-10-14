#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: DTI_Tracto_WB1.sh -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Tracto_WB1.sh -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
SUBJ_ID=$1
OUTPUT_DIR=$2
lmax=$3
Nfiber=$4

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.tck ]
then
	# Stream locally to avoid RAM filling
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck
	streamtrack SD_PROB ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}.mif -seed ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_dti.mif /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck -num ${Nfiber}
	
	cp -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.tck
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}.tck
fi

# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_part000001.tck ]
# then
# 	# Cut the fiber file into small matlab files
# 	matlab -nodisplay <<EOF
# 	split_fibers('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto', 'whole_brain_${lmax}_${Nfiber}');
# EOF
# fi

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.vtk ]
then
	matlab -nodisplay <<EOF
	tracts = f_readFiber_tck('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.tck');
	tract_out = color_tracts(tracts);
	save_tract_vtk(tract_out,'${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}.vtk');
EOF
fi