#!/bin/bash

output=$1
dcm=$2
tmp_file=$3
my_tty=$4
	
	#info_dicom=$(dcmdump -M +P "0020,0011" +P "0008,0020" +P "0010,0010" +P "0008,1030" +P "0008,103e" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/' | sed 's:[ /(),.;*#]:_:g')
	info_dicom=$(dcmdump -M +P "0020,0011" +P "0008,0020" +P "0010,0010" +P "0008,1030" +P "0008,103e" ${dcm})
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
	
	#current_serie_number=$(echo "${info_dicom}" | sed -n 1p)
	#StudyDate=$(echo "${info_dicom}" | sed -n 2p)
	#PatientsName=$(echo "${info_dicom}" | sed -n 3p)
	#StudyDescription=$(echo "${info_dicom}" | sed -n 4p)
	#current_serie_description=$(echo "${info_dicom}" | sed -n 5p)

	mkdir -p ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/${current_serie_number}_${current_serie_description}/
	sudo chmod 777 ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/
	sudo chmod 777 ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/${current_serie_number}_${current_serie_description}/
	mv ${dcm} ${output}/${PatientsName}_${StudyDescription}_${StudyDate}/${current_serie_number}_${current_serie_description}/


echo "$2" >> ${tmp_file}
printf "\r$(wc -l ${tmp_file} | cut -d ' ' -f 1)               " > $my_tty
