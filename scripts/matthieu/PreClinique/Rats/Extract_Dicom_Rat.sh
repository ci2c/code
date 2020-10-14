#! /bin/bash

CURRENT_DIR=/home/matthieu/NAS/matthieu/PreClinique/Morvane-Tau

while read subject
do
	for tp in $(ls ${CURRENT_DIR}/${subject})
	do
		if [ -d ${CURRENT_DIR}/${subject}/${tp}/TEP/1.*/1.* -a $(ls -A ${CURRENT_DIR}/${subject}/${tp}/TEP/1.*/1.* | wc -c) -ne 0 ]
		then
			mv ${CURRENT_DIR}/${subject}/${tp}/TEP/1.*/1.*/* ${CURRENT_DIR}/${subject}/${tp}/TEP
			rm -R ${CURRENT_DIR}/${subject}/${tp}/TEP/*[!.dcm]
		fi
		if [ -d ${CURRENT_DIR}/${subject}/${tp}/IRM/V* -a $(ls -A ${CURRENT_DIR}/${subject}/${tp}/IRM/V* | wc -c) -ne 0 ]
		then
			mv ${CURRENT_DIR}/${subject}/${tp}/IRM/V*/* ${CURRENT_DIR}/${subject}/${tp}/IRM
			rm -R ${CURRENT_DIR}/${subject}/${tp}/IRM/V*
		fi
	done
done < ${CURRENT_DIR}/Subjects.txt