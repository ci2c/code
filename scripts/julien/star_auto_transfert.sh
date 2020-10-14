#!/bin/bash

# assur eque le NAS soit monter
#mount -a
#sleep 30

#date_temp=`date '+%Y_%m_%d'`
#mydate=`date '+%Y%m%d'`

date_temp=$1
mydate=$(date -d "$1" +%Y%m%d)
year=$(date -d "$1" +%Y)

destination="/NAS/DICOMDB/${year}/"
star_dicom_folder="/home/star/storage_space/Local/local_2/"

mkdir -p ${destination}

#if [ ssh star@star "[ -d /home/star/storage_space/Local/local_2/20141030/]" ]; then
if [[ `ssh star@star test -d ${star_dicom_folder}${mydate} && echo exists` ]]
then

ssh star@star "mkdir -p ${star_dicom_folder}${date_temp}"
ssh star@star "/home/star/bin/dcm_star_sort.sh -i ${star_dicom_folder}${mydate}/ -o ${star_dicom_folder}${date_temp}/ -c y"
scp -r star@star:${star_dicom_folder}${date_temp}/ ${destination}


# Vérification des archives transférées (supp sur etiam si ok) et ajout à la database



cd ${destination}${date_temp}/

for patient in $(ls -d *)
	do
	echo "
-------------- Analyse de ${patient}"

		cd ${destination}${date_temp}/${patient}/

		

		for study in $(ls -d *)
		do

		/usr/bin/php -f /var/www/imvdb/dcm_manager/log2db.php ${destination}${date_temp}/${patient}/${study}/

			printf  "${study} \n"			
			cd ${destination}${date_temp}/${patient}/${study}/
			for archive in $(find -name "*.checksum")
			do

			test_archive=$(md5sum -c ${archive} | sed 's/.*\(..\)$/\1/')			
			sequence_basename=$(echo ${archive} | cut -d "/" -f2 | cut -d "." -f1)
			echo "${sequence_basename} : integrity ${test_archive}"

			if  [ "${test_archive}" == "OK" ]
			then
				printf "   |_ Removing from STAR \n"
				ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.tar.bz2"
				ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${archive}"
				ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.log"
				/usr/bin/php -f /var/www/imvdb/dcm_manager/serie2db.php ${destination}${date_temp}/${patient}/${study}/ ${sequence_basename}
				

			else
				printf "   |_ Archive corrupt ... trying to re-copy \n"
				rm ${destination}${date_temp}/${patient}/${study}/${archive}
				rm ${destination}${date_temp}/${patient}/${study}/${sequence_basename}.tar.bz2
				scp star@star:${star_dicom_folder}${date_temp}/${patient}/${study}/${archive} ${destination}${date_temp}/${patient}/${study}/
				scp star@star:${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.tar.bz2 ${destination}${date_temp}/${patient}/${study}/
				printf "   |_ Verify the new archive :"
				test_archive=$(md5sum -c ${archive} | sed 's/.*\(..\)$/\1/')
				printf "${test_archive} \n"
				if  [ "${test_archive}" == "OK" ]
				then
					printf "   |_ Removing from STAR \n"
					ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.tar.bz2"
					ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${archive}"
					ssh star@star "rm ${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.log"
				else
					printf "   |_ Error with archive ${sequence_basename}.tar.bz2 : writte to the log file \n"
					echo "md5 check integrity failed on : ${star_dicom_folder}${date_temp}/${patient}/${study}/${sequence_basename}.tar.bz2" >> ${destination}${date_temp}/${patient}/${study}/error.log
				fi
				
				
			fi
			
			# si toute les archives sont supprimées car bien transférées, alors on supprime le tiroir de l'examen 
			test_exam=$(ssh star@star "ls ${star_dicom_folder}${date_temp}/${patient}/${study}/ | wc -l" )	
			if [ ${test_exam} == 3 ]	# il doit rester dans le tiroir de l'examen : error.log, patient.log, study.log
			then
				printf "${patient} : ${study} fully uploaded  \n"
				ssh star@star "rm -rf ${star_dicom_folder}${date_temp}/${patient}/${study}/"
			fi
			done # archive			
			
	# si toute les examens sont supprimés alors on supprime le tiroir du patient
	test_patient=$(ssh star@star "ls ${star_dicom_folder}${date_temp}/${patient}/ | wc -l" )	
	if [ ${test_patient} == 0 ]
	then
		printf "${patient} fully done  \n"
		ssh star@star "rm -rf ${star_dicom_folder}${date_temp}/${patient}/"
	fi	
	done #study

 


done  # patient

else

echo "pas d'image a cette date : ${star_dicom_folder}${mydate}"
fi

