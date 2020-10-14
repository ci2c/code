#!/bin/bash

FILE_PATH=$1
cpt=1
if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID  
	do
	IOpath="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/${SUBJECT_ID}_enc";
	echo 	"qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N RV_${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/run_normalizeFMRI.sh ${IOpath}"
	qbatch -q three_job_q -oe /NAS/dumbo/romain/log -N RV_${SUBJECT_ID}_RV /home/romain/SVN/scripts/romain/run_normalizeFMRI.sh ${IOpath} ${cpt}
	cpt=`expr ${cpt} + 1`
	sleep 5
	done < ${FILE_PATH}/IRMf_cohorte.txt
fi
