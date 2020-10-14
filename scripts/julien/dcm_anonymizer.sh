#!/bin/bash

### Require
#
#  dcmodify
#  dcmftest
#  dicom tag list file (/home/julien/SVN/scripts/julien/dicom_tags.csv)
#
#######################################
dcmdump_path="";
timestamp=$(date +%s)
temp_folder=/tmp/${timestamp}/
dcm_list=/tmp/${timestamp}/res1.log
dicom_tags=/home/julien/SVN/scripts/julien/dicom_tags.csv
#######################################
export LC_CTYPE=C
export LANG=C








index=1
id_tag=0
name_tag=0
create_cmd_line=""
while [ $index -le $# ]
do
let id_tag++
let name_tag++
eval arg=\${$index}
case "$arg" in
-h|-help)
echo "Usage:  dcm_anonymizer.sh  -i <input folder> [-th <number of processus>]"
echo "                          [-dicom_tag_id <new value>] ex: -0010,0010 \"new_value\""
echo "                          [-dicom_tag_name <new value>] ex : -StudyDescription \"new_value\""
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
-th)
index=$[$index+1]
eval thread=\${$index}
;;
-*)
eval tag=\${$index}
index=$[$index+1]
eval value=\${$index}
#echo "
#${tag} : ${value}"


	find_tag=$(cat ${dicom_tags} | grep "${tag:1}" | sed -n 1p)
	nb_tag=$(cat ${dicom_tags} | grep "${tag:1}" | sed -n 1p | wc -l)

	if [ "${nb_tag}" -eq 1 ]
	then
		ano_tag_number[${id_tag}]=$(echo ${find_tag} | awk -F';' '{print $1}')
		ano_tag_value[${id_tag}]=${value}
		
		echo -e "\e[32m${ano_tag_number[${id_tag}]}     : \e[0m${ano_tag_value[${id_tag}]}"
		create_cmd_line="${create_cmd_line} -i \"(${ano_tag_number[${id_tag}]})=${ano_tag_value[${id_tag}]}\""
	fi
;;
esac
index=$[$index+1]
done

if [ -z ${thread} ]
then
	thread=1
fi




if [ $# -lt 2 ]
then
echo "Usage:  dcm_anonymizer.sh  -i <input folder> [-th <number of processus>]"
echo "                          [-dicom_tag_id <new value>] ex: -0010,0010 \"new_value\""
echo "                          [-dicom_tag_name <new value>] ex : -StudyDescription \"new_value\""
echo "Author: Dumont Julien"
echo ""
exit 1
fi



echo -e "\e[32minput folder  : \e[0m${input}"
echo -e "\e[32mtemp folder   : \e[0m${temp_folder}"
echo -e "\e[32mthread        : \e[0m${thread}"




mkdir -p ${temp_folder}
touch ${temp_folder}avancement.log
# ----------    create a thread  -------------------------
touch ${temp_folder}thread_job.sh
chmod +x ${temp_folder}thread_job.sh
echo "#!/bin/bash" > ${temp_folder}thread_job.sh
echo "temp_folder=\$1
dcm_list=\$1/\$2
thread_number=\$3" >> ${temp_folder}thread_job.sh
echo "
while read dcm
do

test_dicom=\$(dcmftest \${dcm} | cut -c1)
if [ \"\${test_dicom}\" == \"y\" ]
then
	dcmodify ${create_cmd_line} -nb \${dcm} 

fi


calc=\"Thread \${thread_number} compute his frame \${dcm}\"


echo \"\${calc}\" >> \${temp_folder}avancement.log

printf \"\\r\$(wc -l ${temp_folder}avancement.log | cut -d ' ' -f 1) \"

done < \${dcm_list}
">>${temp_folder}thread_job.sh

## ------------------  end thread ------------------------------------------------------


printf "Searching files ... "
find ${input} -type f -iname "*" | sed '/.*JPG/d' | sed '/.*IFO/d' | sed '/.*CDM/d' | sed '/.*TXT/d'| sed '/.*IFF/d' > ${dcm_list}
potential_dcm=$(wc -l < ${dcm_list})
printf "Find ${potential_dcm} potential dicom file(s)\n"


max_file_number=$((${thread}-1))
thread_lenght=${#max_file_number}
split -d --suffix-length=${thread_lenght} --number=l/${thread} ${dcm_list} ${temp_folder}split_res1_



	for i in $(seq -f "%0${thread_lenght}g" 0 ${max_file_number})
	do

		${temp_folder}thread_job.sh ${temp_folder} split_res1_${i} ${i} &

	done
	
	wait


printf "\n"

rm -rf ${temp_folder}




