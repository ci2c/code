#! /bin/bash

FILE_PATH=/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages
WORK_DIR=/home/matthieu/NAS/matthieu/fMRI_Emotions/Visages

## Looping on subjects qbatch movement correction fMRI images
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		index=1
		while read subject  
		do   
			MvtRun1=$(ls ${WORK_DIR}/${subject}/spm/RawEPI/rp_epi_0002.txt)
# 			MvtRun2=$(ls ${WORK_DIR}/${subject}/spm/RawEPI/run2/rp_aepi_0002.txt)
			if [ -n ${MvtRun1} ]
			then 
				/usr/local/matlab11/bin/matlab -nodisplay <<EOF
			      	fid = fopen('${WORK_DIR}/ControlMvtVis.txt', 'a');

			      	T1=load('${MvtRun1}');
% 				T2=load('${MvtRun2}');
				T1=T1(:,1:3);
%				T2=T2(:,1:3);
			      	T1=(T1>=1);
%				T2=(T2>=1);
				Res1=sum(T1(:));
%				Res2=sum(T2(:));
			      
			      	fprintf(fid, '${subject} \t run1 : %d\n',Res1);
			      	fclose(fid);
EOF
			else
				echo "Le fichier de mouvement d'un run du sujet ${subject} est vide" >> ${WORK_DIR}/LogEmotions
			fi
			index=$[$index+1]
		done < ${FILE_PATH}/subjects.txt
	else
		echo "Le fichier subjects.txt est vide" >> ${WORK_DIR}/LogEmotions
		exit 1	
	fi	
else
echo "Le fichier subjects.txt n'existe pas" >> ${WORK_DIR}/LogEmotions
exit 1
fi
