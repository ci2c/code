#!/bin/bash
FILE_PATH=$1
FS_PATH="/NAS/tupac/protocoles/healthy_volunteers/FS53"
DATA_PATH="/NAS/tupac/protocoles/healthy_volunteers/data"

if [ -s ${FILE_PATH}/cohorte.txt ]
then	
	while read SUBJECT_ID
	do
	#qbatch -q one_job_q -oe /NAS/dumbo/romain/log -N RV_${SUBJECT_ID} /home/romain/SVN/scripts/romain/HRSC.sh ${FS_PATH} ${SUBJECT_ID} ${DATA_PATH}
echo ${SUBJECT_ID}
#.mat
find /NAS/tupac/protocoles/healthy_volunteers/FS53/${SUBJECT_ID}/dti/ -iname "Connectome*" | wc -l

#Connectome.mat 1
#find /NAS/tupac/protocoles/healthy_volunteers/FS53/${SUBJECT_ID}/dti/ -iname "Connectome.mat" -size +50 |wc -l

#8
#find /NAS/tupac/protocoles/healthy_volunteers/FS53/${SUBJECT_ID}/connectome/ -iname "*rsl*" |wc -l

#4
#find /NAS/tupac/protocoles/healthy_volunteers/FS53/${SUBJECT_ID}/connectome/ -iname "*Connectome_Struc_*" |wc -l


		sleep 5
	done < ${FILE_PATH}/cohorte.txt
fi
