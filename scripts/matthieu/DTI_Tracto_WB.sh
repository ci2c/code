#!/bin/bash

if [ $# -lt 5 ]
then
	echo ""
	echo "Usage: DTI_Tracto_WB.sh -base <NameDti> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -base		: Name of the patient dti"
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_Tracto_WB.sh -base <NameDti> -subjid <SubjId> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
base=$1
SUBJ_ID=$2
OUTPUT_DIR=$3
lmax=$4
Nfiber=$5

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.tck ]
then
	# Stream locally to avoid RAM filling
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}_${base}.tck
	streamtrack SD_PROB ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/CSD${lmax}_${base}.mif -seed ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif -mask ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/rwm_mask_${base}.mif /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}_${base}.tck -num ${Nfiber}
	
	cp -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}_${base}.tck ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.tck
	rm -f /tmp/${SUBJ_ID}_whole_brain_${lmax}_${Nfiber}_${base}.tck
fi

# if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}_part000001.tck ]
# then
# 	# Cut the fiber file into small matlab files
# 	matlab -nodisplay <<EOF
# 	split_fibers('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto', 'whole_brain_${lmax}_${Nfiber}_${base}');
# EOF
# fi

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.vtk ]
then
	matlab -nodisplay <<EOF
	tracts = f_readFiber_tck('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.tck');
	tract_out = color_tracts(tracts);
	save_tract_vtk(tract_out,'${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${base}.vtk');
EOF
fi