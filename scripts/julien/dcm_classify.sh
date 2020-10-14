#!/bin/bash

### Require
#
#  dcm_classify_func.sh
#  dcmdump
#
#######################################
dcmdump_path="";
timestamp=$(date +%s)
temp_folder=/tmp/${timestamp}/
dcm_list=/tmp/${timestamp}/res1.log
my_tty="/dev/$(ps ax | grep $$ | awk '{ print $2 }' | sed -n 1p)"
#######################################
export LC_CTYPE=C
export LANG=C



if [ $# -lt 2 ]
then
echo "Usage:  dcm_classify.sh  -i <input folder> -o <output folder> [-th <thread number>] [-f <string>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output folder"
echo "  -th      : number of thread (default 1)"
echo "  -f       : file filter (default is *, sample : MR*, IM* ...)"
echo "  -cache   : make a copy/cache folder before analyse"
echo "               - accept a full valid path (-cache /full/valid/path/"
echo "               - cdrom as arg for special dumping cd rom files (-cache cdrom)"
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
echo "Usage:  dcm_classify.sh  -i <input folder> -o <output folder> [-th <thread number>] [-f <string>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output folder"
echo "  -th      : number of thread (default 1)"
echo "  -f       : file filter (default is *, sample : MR*, IM* ...)"
echo "  -cache   : make a copy/cache folder before analyse"
echo "               - accept a full valid path (-cache /full/valid/path/"
echo "               - cdrom as arg for special dumping cd rom files (-cache cdrom)"
echo ""
echo "Author: Dumont Julien"
echo ""
exit 1
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
-o)
index=$[$index+1]
eval output=\${$index}

if [ ! -d ${output} ]
then
	echo "${output} is not a directory"	
	exit 1
fi
;;
-f)
index=$[$index+1]
eval filter=\${$index}
;;
-cache)
index=$[$index+1]
eval cache=\${$index}
;;
-th)
index=$[$index+1]
eval thread=\${$index}
;;
-*)
eval infile=\${$index}
echo "
${infile} : unknown option
"
echo "Usage:  dcm_classify.sh  -i <input folder> -o <output folder> [-th <thread number>] [-f <string>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output folder"
echo "  -th      : number of thread (default 1)"
echo "  -f       : file filter (default is *, sample : MR*, IM* ...)"
echo "  -cache   : make a copy/cache folder before analyse"
echo "               - accept a full valid path (-cache /full/valid/path/"
echo "               - cdrom as arg for special dumping cd rom files (-cache cdrom)"
echo ""
echo "Author: Dumont Julien"
echo ""
exit 1
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

if [ -z ${output} ]
then
echo "-o argument mandatory"
exit 1
fi

if [ -z ${filter} ]
then
	filter="*"
fi
if [ -z ${thread} ]
then
	thread=1
fi

echo -e "\e[31m
         ██████╗  ██████╗███╗   ███╗
         ██╔══██╗██╔════╝████╗ ████║ █████╗
         ██║  ██║██║     ██╔████╔██║██╔═══╝     
         ██║  ██║██║     ██║╚██╔╝██║██║     
         ██████╔╝╚██████╗██║ ╚═╝ ██║╚█████╗
         ╚═════╝  ╚═════╝╚═╝     ╚═╝ ╚════╝
=================== DCM classify =====================\e[0m"



if [ ! -z ${cache} ]
then

	echo -e "\e[32mCreating a file cache ... \e[0m"


  if [ ${cache} == "cdrom" ]
  then

	my_inputcdrom=$(echo ${input} | cut -d '/' -f5- )
	
	mkdir -p /tmp/cache_${timestamp}
	dd if=/dev/sr0 of=/tmp/cdimg_${timestamp}.iso
	sudo mount -o ro /tmp/cdimg_${timestamp}.iso /tmp/cache_${timestamp}
	input=/tmp/cache_${timestamp}/${my_inputcdrom}
  else
	if [ ! -d ${cache} ]
	then
		echo "${cache} is not a directory"	
		exit 1
	fi

	mkdir -p ${cache}/cache_${timestamp}
	find ${input} -depth -print | cpio -pamVd ${cache}/cache_${timestamp}
	input=${cache}/cache_${timestamp}/

  fi
fi



echo -e "\e[32minput folder  : \e[0m${input}"
echo -e "\e[32moutput folder : \e[0m${output}"
echo -e "\e[32mtemp folder   : \e[0m${temp_folder}"
echo -e "\e[32mfile filter   : \e[0m${filter}"
echo -e "\e[32mthread        : \e[0m${thread}"
echo -e "\e[31m======================================================\e[0m"

mkdir -p ${temp_folder}
touch ${temp_folder}avancement.log
printf "Searching files ... "
find ${input} -type f -iname "${filter}" | sed '/.*JPG/d' | sed '/.*IFO/d' | sed '/.*CDM/d' | sed '/.*TXT/d'| sed '/.*IFF/d' > ${dcm_list}
potential_dcm=$(wc -l < ${dcm_list})
printf "Find ${potential_dcm} potential dicom file(s)\n"


max_file_number=$((${thread}-1))
thread_lenght=${#max_file_number}
split -d --suffix-length=${thread_lenght} --number=l/${thread} ${dcm_list} ${temp_folder}split_res1_



	for i in $(seq -f "%0${thread_lenght}g" 0 ${max_file_number})
	do

		dcm_classify_func.sh ${temp_folder} split_res1_${i} ${output} ${my_tty} ${i} &
		#echo "thread pid : $!"
		#xterm -T "thread ${i}" -e
	done
	
	wait


printf "\n"


rm -rf ${temp_folder}
if [ ! -z ${cache} ]
then


  if [ ${cache} == "cdrom" ]
  then

	sudo umount /tmp/cache_${timestamp}
	rm -rf /tmp/cache_${timestamp}
	rm -rf /tmp/cdimg_${timestamp}.iso
  else

	sudo rm -rf ${cache}/cache_${timestamp}


  fi
fi
