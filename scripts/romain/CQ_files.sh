#!/bin/bash
#Permet de créer un tableaux de presence des fichiers

FILE_PATH=$1
FS_PATH="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3"
HEADLINES="NOM	dti/Connectome.mat	Connectome_Accumbens-area Connectome_Amygdala Connectome_Hippocampus Connectome_Pallidum Connectome_Putamen Connectome_Thalamus-Proper Connectome_Caudate Connectome_rsl.mat Connectome_rsl_Accumbens-area Connectome_rsl_Amygdala Connectome_rsl_Hippocampus Connectome_rsl_Pallidum Connectome_rsl_Putamen Connectome_rsl_Thalamus-Proper Connectome_rsl_Caudate	resting_state/Connectome.mat"
echo -e ${HEADLINES}
if [ -s ${FILE_PATH}/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID
	do
	
	res="${SUBJECT_ID}"
	
	varA=$(find ${FS_PATH}/${SUBJECT_ID}_enc/dti/ -iname "Connectome.mat" | wc -l);
	res+=$'\t'${varA}

	for STRUC in Accumbens-area Amygdala Hippocampus Pallidum Putamen Thalamus-Proper Caudate
	do
		varA=$(find ${FS_PATH}/${SUBJECT_ID}_enc/dti/ -iname "Connectome_${STRUC}.mat" | wc -l);
		res+="	${varA}"
	done
	
	varA=$(find ${FS_PATH}/${SUBJECT_ID}_enc/connectome/ -iname "Connectome_rsl.mat" | wc -l);
	res+="	${varA}"
	
	for STRUC in Accumbens-area Amygdala Hippocampus Pallidum Putamen Thalamus-Proper Caudate
	do
		varA=$(find ${FS_PATH}/${SUBJECT_ID}_enc/connectome/ -iname "Connectome_rsl_${STRUC}.mat" | wc -l);
		res+="	${varA}"
	done
	
	varA=$(find ${FS_PATH}/${SUBJECT_ID}_enc/resting_state/ -iname "Connectome.mat" | wc -l)
	res+="	${varA}"
	
	echo -e ${res}
	
	done < ${FILE_PATH}/IRMf_cohorte.txt
fi
