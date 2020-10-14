#! /bin/bash

FILE_PATH=/home/matthieu/Desktop/Aude
WORK_DIR=/home/matthieu/Desktop/AudeProc

## Looping on subjects qbatch automatic registration of PET/MRI images on MRI Template
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		index=1
		while read subject  
		do   
			MeanPet=$(ls ${WORK_DIR}/${subject}/TEP/mean*pet*.nii)
			if [ -n ${MeanPet} ]
			then 
			      /usr/local/matlab11/bin/matlab -nodisplay <<EOF
			      fid = fopen('DynPet.txt', 'a');

			      nii=load_nii('${MeanPet}');
			      DynPet=nii.hdr.dime.glmax-nii.hdr.dime.glmin;
			      
			      fprintf(fid, 'sujet %d : %d\n',$index,DynPet);
			      fclose(fid);
EOF
			else
				echo "Le fichier Mean Pet du sujet ${subject} est vide" >> ${WORK_DIR}/LogRats
			fi
			index=$[$index+1]
		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${WORK_DIR}/LogRats
		exit 1	
	fi	
else
echo "Le fichier subjects.txt n'existe pas" >> ${WORK_DIR}/LogRats
exit 1
fi