#!/bin/bash

if [ $# -lt 5 ]
then
	echo ""
	echo "Usage: DTI_HypoAno_hypothVSfsseg.sh -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "	-base		: Dti number"
	echo "  -od		: Path to output directory (processing results)"
	echo "  -lmax		: Maximum harmonic order"
	echo "  -Nfiber		: Number of fibers generated"
	echo ""
	echo "Usage: DTI_HypoAno_hypothVSfsseg.sh -subjid <SubjId> -base <DtiNumber> -od <OutputDir> -lmax <NbHarmonic> -Nfiber <NbFibers>"
	echo ""
	exit 1
fi

## I/O management
SUBJ_ID=$1
BASE=$2
OUTPUT_DIR=$3
lmax=$4
Nfiber=$5

# if [ ! -s ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}_part000150.tck ]
# then
# 	
# 	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}_part000*.tck
# 	
# 	Cut the fiber file into small matlab files
# 	matlab -nodisplay <<EOF
# 	% Load Matlab Path: Matlab 14 and SPM12 needed
# 	cd ${HOME}
# 	p = pathdef14_SPM12;
# 	addpath(p);
# 	
# 	split_fibers('${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}.tck', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto', 'whole_brain_${lmax}_${Nfiber}_${BASE}');
# EOF
# fi

if [ -s ${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto/whole_brain_${lmax}_${Nfiber}_${BASE}.tck ]
then
	matlab -nodisplay <<EOF
	% Load Matlab Path: Matlab 14 and SPM12 needed
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);
	
	getHypothConnectMatrix('${OUTPUT_DIR}/${SUBJ_ID}/ConnCortSubcort_${BASE}/rHypo_Ano_${BASE}_LAS.nii','${OUTPUT_DIR}/${SUBJ_ID}/ConnCortSubcort_${BASE}/raparc.a2009s+aseg_${BASE}_LAS.nii', '${OUTPUT_DIR}/${SUBJ_ID}/dti_tracto', '${OUTPUT_DIR}/Hypo_LOI.txt', '${OUTPUT_DIR}/aparc2009LOI_HypoAno.txt', '${OUTPUT_DIR}/${SUBJ_ID}/ConnCortSubcort_${BASE}', '${BASE}');
EOF
fi