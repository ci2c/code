#!/bin/bash


#######################################
dcmdump_path="";
#######################################

temp_folder=$1
dcm_list=$1/$2
output=$3
my_tty=$4
thread_number=$5




while read dcm
do

test_dicom=$(dcmftest ${dcm} | cut -c1)
if [ "${test_dicom}" == "y" ]
then

	
	#info_dicom=$(dcmdump -M +P "0020,0011" +P "0008,0020" +P "0010,0010" +P "0008,1030" +P "0008,103e"  +P "0008,0018" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's#[ /(),.;*]#_#g')
	
	info_dicom=$(dcmdump -M +P "0020,0011" +P "0008,0020" +P "0010,0010" +P "0008,1030" +P "0008,103e"  +P "0008,0018" ${dcm})
	# certain contructeur mettent plusieurs fois le même tag, impossible de lire le résultat à une ligne fixe
	#(0010,0010) PN [X]               #   8, 1 PatientName
	#(0010,0010) PN [X]               #  24, 1 PatientName
	#(0010,0010) PN [X]               #  20, 1 PatientName
	#(0010,0010) PN [X]               #  44, 1 PatientName
	
	
	current_serie_number=$(echo "${info_dicom}" | grep "SeriesNumber" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	StudyDate=$(echo "${info_dicom}" | grep "StudyDate" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	PatientsName=$(echo "${info_dicom}" | grep "PatientName" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	StudyDescription=$(echo "${info_dicom}" | grep "StudyDescription" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	current_serie_description=$(echo "${info_dicom}" | grep "SeriesDescription" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	dcm_renamer=$(echo "${info_dicom}" | grep "SOPInstanceUID" | head -1 | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	
	#current_serie_number=$(echo "${info_dicom}" | sed -n 1p)
	#StudyDate=$(echo "${info_dicom}" | sed -n 2p)
	#PatientsName=$(echo "${info_dicom}" | sed -n 3p)
	#StudyDescription=$(echo "${info_dicom}" | sed -n 4p)
	#current_serie_description=$(echo "${info_dicom}" | sed -n 5p)
	#dcm_renamer=$(echo "${info_dicom}" | sed -n 6p)

	mkdir -p ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/${current_serie_number}_${current_serie_description}/
	cp ${dcm} ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/${current_serie_number}_${current_serie_description}/${dcm_renamer}.dcm

fi


calc="Thread ${thread_number} check is frame ${dcm}"


echo "${calc}" >> ${temp_folder}avancement.log

printf "\r$(wc -l ${temp_folder}avancement.log | cut -d ' ' -f 1)                    "
# > $my_tty
done < ${dcm_list}




