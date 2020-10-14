#!/bin/bash


#######################################
dcmdump_path="";

#######################################
export LC_CTYPE=C
export LANG=C

folder=$1
serie_list=$1/$2
my_tty=$3
thread_number=$4
bzth=$5


while read serie
do

first_dcm=$(find ${serie} -type f -iname "*dcm" | head -1)
info_dicom=$(${dcmdump_path}dcmdump -M +P "0020,0011" +P "0008,103e" +P "0008,0031" ${first_dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
#current_serie_number 0020,0011
current_serie_number=$(echo "${info_dicom}" | sed -n 1p | sed 's/ /_/g')
#SeriesDescription 0008,103e
SeriesDescription=$(echo "${info_dicom}" | sed -n 2p)
current_serie_description=$(echo "${SeriesDescription}" | sed 's#[ /(),.;*]#_#g' )
#SeriesTime 0008,0031
SeriesTime=$(echo "${info_dicom}" | sed -n 3p)
#nb dicom
nb=$(ls ${serie}/ | wc -l)
#serie_log
serie_log=${folder}/${current_serie_number}_${current_serie_description}.log


touch ${serie_log}
echo "${SeriesDescription}" > ${serie_log}
echo "${SeriesTime}" >> ${serie_log}
echo "${current_serie_number}" >> ${serie_log}
echo "${nb}" >> ${serie_log}

echo "Archiving ${serie} ..."
archiving_tool.sh -i ${serie} -comp lbzip2 -cpu ${bzth} -subfolder no > /dev/null 2>&1

done < ${serie_list}

