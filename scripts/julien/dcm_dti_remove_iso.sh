#!/bin/bash

#### require
#
#  dcmdump

export LC_CTYPE=C
export LANG=C

### VAR

input=$1
output=$2

timestamp=$(date +%s)
temp_folder=/tmp/${timestamp}/
#temp_folder=${output}
dcm_list=${temp_folder}res1.log
thread=10



###################################



# creating output folder
output2=${output}/$(basename ${input})_without_ISO/
mkdir -p ${output2}
# creating temp folder for multithreading support
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

 
	  
 	  current_diffusion_direction=\$(dcmdump -M +P \"2001,1004\" \${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
 	  current_parameter=\$(dcmdump -M +P \"2005,1412\" \${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
 	  
 	 
 	  
 	  if [ \"\${current_diffusion_direction}\" == \"I\" ] && [ \"\${current_parameter}\" == \"2\" ];then
 	   
 	    echo \"\${dcm}\" >> \${temp_folder}avancement.log
 	  else
 	    cp \${dcm} ${output2}
 	  fi

printf \"\\r Find \$(wc -l \${temp_folder}avancement.log | cut -d ' ' -f 1) ISO \"

done < \${dcm_list}
">>${temp_folder}thread_job.sh

## ------------------  end thread ------------------------------------------------------

printf "Searching files ... "
find ${input} -type f -iname "*" > ${dcm_list}
potential_dcm=$(wc -l < ${dcm_list})
printf "Find ${potential_dcm} potential dicom file(s)\n"


max_file_number=$((${thread}-1))
thread_lenght=${#max_file_number}
split -d --suffix-length=${thread_lenght} --number=l/${thread} ${dcm_list} ${temp_folder}split_res1_



	for i in $(seq -f "%0${thread_lenght}g" 0 ${max_file_number})
	do

		${temp_folder}thread_job.sh ${temp_folder} split_res1_${i} ${output} ${i} &

	done
	
	wait



# for dcm in $(find ${input} -type f -iname '*')
# 	do
# 	  #echo ${dcm} 
# 	 let i++
# 	 info_dicom=$(dcmdump -M +P "2001,1004" +P "2005,1412" ${dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
# 	  
# 	  current_diffusion_direction=$(echo "${info_dicom}" | sed -n 1p)
# 	  current_parameter=$(echo "${info_dicom}" | sed -n 2p)
# 	  
# 	  #echo "${current_diffusion_direction} |  ${current_parameter} "
# 	  
# 	  if [ "${current_diffusion_direction}" == "I" ] && [ "${current_parameter}" == "2" ];then
# 	    let j++
# 	    printf "\rFinding $j ISO "
# 	  else
# 	    cp ${dcm} ${output2}
# 	  fi
# 	  
# 	done

rm -rf ${temp_folder}
echo ""
echo "Finished"