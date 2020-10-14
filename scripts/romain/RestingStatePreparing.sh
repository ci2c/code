#!/bin/bash
SEQ=`pwd`

FILE_PATH=$1
FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
DATA_PATH="/NAS/dumbo/protocoles/IRMf_memoire/data"

echo "${FILE_PATH}/IRMf_cohorte.txt"
if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
echo "pendant"
	while read SUBJECT_ID
	do
		echo ${SUBJECT_ID}
		mkdir ${DATA_PATH}/${SUBJECT_ID}/resting_state
		mkdir ${DATA_PATH}/${SUBJECT_ID}/dti
		mkdir ${DATA_PATH}/${SUBJECT_ID}/T1
		
		mkdir ${FS_PATH}/${SUBJECT_ID}_enc/resting_state
		
		echo "find /home/RECPAR -maxdepth 1 -mtime 0 -iname "${SUBJECT_ID}*""
		SEQ=`find /home/RECPAR -maxdepth 1 -mtime 0 -iname "${SUBJECT_ID}*"`
		echo ${SEQ}
		mv ${SEQ} ${DATA_PATH}/${SUBJECT_ID}/resting_state/
		mv ${SEQ} ${DATA_PATH}/${SUBJECT_ID}/T1/
		mv ${SEQ} ${DATA_PATH}/${SUBJECT_ID}/dti/
		dcm2nii -x n ${DATA_PATH}/${SUBJECT_ID}/resting_state/
		dcm2nii ${DATA_PATH}/${SUBJECT_ID}/T1/
		done < ${FILE_PATH}/IRMf_cohorte.txt
		
		SUBJECT_ID=david
		qbatch -q fs_q -oe /home/romain/Logdir -N fs_${SUBJECT_ID}enc_RV recon-all -all -sd /NAS/dumbo/protocoles/IRMf_memoire/FS5.3 -subjid ${SUBJECT_ID}_enc -nuintensitycor-3T -i /NAS/dumbo/protocoles/IRMf_memoire/data/${SUBJECT_ID}/T1_enc.nii.gz
fi
echo "apres"
