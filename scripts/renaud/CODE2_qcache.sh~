#!/bin/bash

SUBJECTS_DIR=/home/renaud/NAS/Louise/sophie/CODE2/FS50
#subjFile=/home/renaud/NAS/Louise/sophie/CODE2/subjects/subjectList.txt
subjFile=/home/renaud/NAS/Louise/sophie/CODE2/FS50/subjectsBis.txt

for SUBJ in `ls -1 ${SUBJECTS_DIR}`
do 

	if [ ! -f ${SUBJECTS_DIR}/${SUBJ}/surf/lh.thickness.fwhm25.fsaverage.mgh ]
	then
		echo "${SUBJ}"
		qbatch -q fs_q -oe /home/renaud/log/ -N qcache_${SUBJ} recon-all -qcache -sd ${SUBJECTS_DIR} -s ${SUBJ} -nuintensitycor-3T -no-isrunning
		sleep 5
	fi

done
