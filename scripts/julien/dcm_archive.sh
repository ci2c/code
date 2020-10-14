#!/bin/bash

### Require
#
#  dcm_archive_func.sh
#  dcmdump
#  archiving_tools.sh
#
#######################################
dcmdump_path="";
my_tty="/dev/$(ps ax | grep $$ | awk '{ print $2 }' | sed -n 1p)"
#######################################
export LC_CTYPE=C
export LANG=C



if [ $# -lt 1 ]
then
echo "Usage:  dcm_archive.sh  -i <input folder> [-th <int>] [-bzth <int>]"
echo "  -i       : input folder"
echo "  -th      : number of simultaneous tar job"
echo "  -bzth    : number of lbzip2 thread"
echo ""
echo "Author: Dumont Julien"
echo ""
exit 1
fi

index=1

while [ $index -le $# ]
do
eval arg=\${$index}
case "$arg" in
-h|-help)
echo "Usage:  dcm_archive.sh  -i <input folder> [-th <int>] [-bzth <int>]"
echo "  -i       : input folder"
echo "  -th      : number of simultaneous tar job"
echo "  -bzth    : number of lbzip2 thread"
echo ""
echo "Author: Dumont Julien"
echo ""
exit 1
;;
-i)
index=$[$index+1]
eval input=\${$index}
if [ ! -d ${input} ]
then
	echo "${input} is not a directory"	
	exit 1
fi
;;
-cache)
index=$[$index+1]
eval cache=\${$index}
;;
-th)
index=$[$index+1]
eval thread=\${$index}
;;
-bzth)
index=$[$index+1]
eval bzth=\${$index}
;;
-*)
eval infile=\${$index}
echo "
${infile} : unknown option
"
echo "Usage:  dcm_archive.sh  -i <input folder> [-th <int>] [-bzth <int>]"
echo "  -i       : input folder"
echo "  -th      : number of simultaneous tar job"
echo "  -bzth    : number of lbzip2 thread"
echo ""
echo "Author: Dumont Julien"
echo ""
exit 1
;;
esac
index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
echo "-i argument mandatory"
exit 1
fi


if [ -z ${thread} ]
then
	thread=1
fi

echo -e "\e[31m
=================== DCM archive =====================\e[0m"
echo -e "\e[32minput folder  : \e[0m${input}"
echo -e "\e[32mtar thread    : \e[0m${thread}"
echo -e "\e[32mlbzip2 thread : \e[0m${bzth}"
echo -e "\e[31m=====================================================\e[0m"


## pour chaque tiroir Patient_etude_date (arborescence de sortie de dcm_classify)


for pat_st_date in $(ls -d ${input}/*)
do

	if [ -d ${pat_st_date} ]
	then

	# Récupération des information dicom pour nouvelle
	first_dcm=$(find ${pat_st_date} -type f -iname "*dcm" | head -1)
	
	info_dicom=$(${dcmdump_path}dcmdump -M +P "0010,0040" +P "0010,0030" +P "0010,0020" +P "0010,0010" +P "0008,1030" +P "0008,0050" +P "0008,0030" +P "0008,0020" +P "0020,000d" ${first_dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')

	#StudyDate 0008,0020
	StudyDate=$(echo "${info_dicom}" | sed -n 8p | sed 's/ /_/g')
	#PatientsName 0010,0010
	PatientsName=$(echo "${info_dicom}" | sed -n 4p)
	patient_folder=$(echo ${PatientsName} | sed 's#[ /(),.;*]#_#g')
	#StudyDescription 0008,1030
	StudyDescription=$(echo "${info_dicom}" | sed -n 5p | sed 's#/#_#g')
	study_folder=$(echo ${StudyDescription} | sed 's#[ /(),.;*]#_#g')
	#StudyTime 0008,0030
	StudyTime=$(echo "${info_dicom}" | sed -n 7p)
	#PatientID 0010,0020
	PatientID=$(echo "${info_dicom}" | sed -n 3p)
	#AccessessionNumber 0008,0050
	AccessessionNumber=$(echo "${info_dicom}" | sed -n 6p)
	#PatientsBirthDate 0010,0030
	PatientsBirthDate=$(echo "${info_dicom}" | sed -n 2p)
	#PatientsSex 0010,0040 
	PatientsSex=$(echo "${info_dicom}" | sed -n 1p)
	#StudyInstanceUID 0020,000d
	StudyInstanceUID=$(echo "${info_dicom}" | sed -n 9p)
	
	#creation folder log
	touch ${pat_st_date}/folder.log
	
	echo ${patient_folder} > ${pat_st_date}/folder.log
	echo ${study_folder} >> ${pat_st_date}/folder.log

	# creation du patient.log et du study.log
	touch ${pat_st_date}/patient.log

	echo "${PatientsName}" > ${pat_st_date}/patient.log
	echo "${PatientID}" >> ${pat_st_date}/patient.log
	echo "${PatientsBirthDate}" >> ${pat_st_date}/patient.log
	echo "${PatientsSex}" >> ${pat_st_date}/patient.log

	#creation study log
	touch ${pat_st_date}/study.log
	
	echo "${StudyDescription}" > ${pat_st_date}/study.log
	echo "${StudyDate}" >> ${pat_st_date}/study.log
	echo "${StudyTime}" >> ${pat_st_date}/study.log
	echo "${AccessessionNumber}" >> ${pat_st_date}/study.log
	echo "${StudyInstanceUID}" >>  ${pat_st_date}/study.log


	
	## creation serie_name.log
	find ${pat_st_date}/* -type d > ${pat_st_date}/series_list.list
	
	max_file_number=$((${thread}-1))
	thread_lenght=${#max_file_number}
	split -d --suffix-length=${thread_lenght} --number=l/${thread} ${pat_st_date}/series_list.list ${pat_st_date}/split_serie_list_



	for i in $(seq -f "%0${thread_lenght}g" 0 ${max_file_number})
	do
		dcm_archive_func.sh ${pat_st_date}/ split_serie_list_${i} ${my_tty} ${i} ${bzth} &
		#xterm -T "thread ${i}" -e 
	done
	
	wait

	rm -rf ${pat_st_date}/split_serie_list_*



	fi

done


#checking archiving error : .error was creating by archiving_tools.sh
echo -e "\e[31m"
find ${input} -type f -iname "*.error" | xargs -I{}  cat "{}" 
echo -e "\e[0m"




