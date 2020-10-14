#!/bin/bash

FILE_PATH=$1
FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"
cpt=1

if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID 
	do
		echo "ROMAIN mri_convert"
		DIR=${FS_PATH}/${SUBJECT_ID}_enc
		mri_convert ${DIR}/mri/T1.mgz ${DIR}/mri/t1_ras.nii --out_orientation RAS

echo "ROMAIN surf = surf_to_ras_nii('${DIR}/surf/lh.white', '${DIR}/mri/t1_ras.nii');"
matlab -nodisplay <<EOF
surf = surf_to_ras_nii('${DIR}/surf/lh.white', '${DIR}/mri/t1_ras.nii');
SurfStatWriteSurf('${DIR}/surf/lh.white.ras', surf, 'b');
surf = surf_to_ras_nii('${DIR}/surf/rh.white', '${DIR}/mri/t1_ras.nii');
SurfStatWriteSurf('${DIR}/surf/rh.white.ras', surf, 'b');
EOF
	done < ${FILE_PATH}/IRMf_cohorte.txt
fi
