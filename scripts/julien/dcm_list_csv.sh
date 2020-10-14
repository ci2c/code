#!/bin/bash


export LC_CTYPE=C
export LANG=C


input=$1


cd ${input}	

touch /tmp/centre.csv
echo "Patient;Date;Modality;Study;Serie;nb fichier DICOM;source" >> /tmp/centre.csv

for patient in $(ls -d *)
do


	cd ${input}/${patient}/
	for date in $(ls -d *)
	do
	 cd ${input}/${patient}/${date}
		
		for modality in $(ls -d *)
		do
		 cd ${input}/${patient}/${date}/${modality}/
			for study in $(ls -d *)
			do
		 	 cd ${input}/${patient}/${date}/${modality}/${study}/
				for serie in $(ls -d *)
				do

					if [ -d ${serie} ]
			   		then
					source=`sed -n 1p ${input}/${patient}/${date}/${modality}/${study}/${serie}.log`
					nb=$(find  ${input}/${patient}/${date}/${modality}/${study}/${serie} -name "*" -type f | wc -l)	
					echo "Adding ... ${patient};${date};${modality};${study};${serie};${nb}"
					echo "${patient};${date};${modality};${study};${serie};${nb};${source}" >> /tmp/centre.csv
					fi
				done
			done
		done

	done		 


done

mv /tmp/centre.csv ${input}/
