#!/bin/bash


#######################################
nas_folder=/NAS/DICOMDB/
bash_folder="/var/www/html/imvdb/pipeline/bash/"
#######################################
export LC_CTYPE=C
export LANG=C

. ${bash_folder}/pipeline_db_functions.sh


echo -e "\e[31m
██████╗  ██████╗███╗   ███╗    ██████╗     ██████╗ ██████╗ 
██╔══██╗██╔════╝████╗ ████║    ╚════██╗    ██╔══██╗██╔══██╗
██║  ██║██║     ██╔████╔██║     █████╔╝    ██║  ██║██████╔╝
██║  ██║██║     ██║╚██╔╝██║    ██╔═══╝     ██║  ██║██╔══██╗
██████╔╝╚██████╗██║ ╚═╝ ██║    ███████╗    ██████╔╝██████╔╝
╚═════╝  ╚═════╝╚═╝     ╚═╝    ╚══════╝    ╚═════╝ ╚═════╝ 
========================== DCM 2 DB =======================\e[0m"


if [ $# -lt 1 ]
then
echo "Usage:  dcm2db.sh  -i <input folder> [-o <path>] [-classth <int>] [-archth <int>]"
echo "                   [-bzth <int>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output temp folder (default /tmp)"
echo "  -classth : number of thread for dcm_classify (default 4)"
echo "  -archth  : number of thread for dcm_archive (default 4)"
echo "  -bzth    : number of cpu for lbzip2 (default 4)"
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
echo "Usage:  dcm2db.sh  -i <input folder> [-o <path>] [-classth <int>] [-archth <int>]"
echo "                   [-bzth <int>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output temp folder"
echo "  -classth : number of thread for dcm_classify (default 4)"
echo "  -archth  : number of thread for dcm_archive (default 4)"
echo "  -bzth    : number of cpu for lbzip2 (default 4)"
echo "  -cache   : make a copy/cache folder before analyse"
echo "               - accept a full valid path (-cache /full/valid/path/"
echo "               - cdrom as arg for special dumping cd rom files (-cache cdrom)"
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
-o)
index=$[$index+1]
eval output=\${$index}

if [ ! -d ${output} ]
then
	echo "${output} is not a directory"	
	exit 1
fi
;;
-bzth)
index=$[$index+1]
eval bzth=\${$index}
;;
-cache)
index=$[$index+1]
eval cache=\${$index}
;;
-classth)
index=$[$index+1]
eval classth=\${$index}
;;
-archth)
index=$[$index+1]
eval archth=\${$index}
;;
-*)
eval infile=\${$index}
echo "${infile} : unknown option
"
echo "Usage:  dcm2db.sh  -i <input folder> [-o <path>] [-classth <int>] [-archth <int>]"
echo "                   [-bzth <int>] [-cache <path|cdrom>]"
echo "  -i       : input folder"
echo "  -o       : output temp folder"
echo "  -classth : number of thread for dcm_classify (default 4)"
echo "  -archth  : number of thread for dcm_archive (default 4)"
echo "  -bzth    : number of cpu for lbzip2 (default 4)"
echo "  -cache   : make a copy/cache folder before analyse"
echo "               - accept a full valid path (-cache /full/valid/path/"
echo "               - cdrom as arg for special dumping cd rom files (-cache cdrom)"
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

if [ -z ${output} ]
then
	timestamp=$(date +%s)
	output=/tmp/dcm2db_${timestamp}/
	mkdir -p ${output}
	
fi

if [ -z ${classth} ]
then
	classth=4
fi
if [ -z ${archth} ]
then
	archth=4
fi
if [ -z ${bzth} ]
then
	bzth=4
fi
if [ ! -z ${cache} ]
then

	cache="-cache ${cache}"

else
	cache=""
fi


echo -e "\e[32minput folder     : \e[0m${input}"
echo -e "\e[32moutput folder    : \e[0m${output}"
echo -e "\e[32mclassify thread  : \e[0m${classth}"
echo -e "\e[32mArchiving thread : \e[0m${archth}"
echo -e "\e[32mlbzip2 thread    : \e[0m${bzth}"
echo -e "\e[31m======================================================\e[0m"


dcm_classify.sh -i ${input} -o ${output} -th ${classth} ${cache}
dcm_archive.sh -i ${output} -th ${archth} -bzth ${bzth}


for pat_st_date in $(ls -d ${output}/*)
do



		study_date=$(cat ${pat_st_date}/study.log | sed -n 2p)
		year=$(date -d "${study_date}" +%Y)
		study_date2=$(date -d "${study_date}" +%Y-%m-%d)
		patient=$(cat ${pat_st_date}/folder.log | sed -n 1p)
		study=$(cat ${pat_st_date}/folder.log | sed -n 2p)	
		

		mkdir -p ${nas_folder}${year}/${study_date2}/${patient}/${study}/
		cp ${pat_st_date}/study.log ${nas_folder}${year}/${study_date2}/${patient}/${study}/
		cp ${pat_st_date}/patient.log ${nas_folder}${year}/${study_date2}/${patient}/${study}/
		

		/usr/bin/php -f /var/www/html/imvdb/dcm_manager/log2db.php ${nas_folder}${year}/${study_date2}/${patient}/${study}/

		cd ${pat_st_date}
		for archive in $(find -name "*.checksum")
		do

			test_archive=$(md5sum -c ${archive} | sed 's/.*\(..\)$/\1/')
			sequence_basename=$(echo ${archive} | cut -d "/" -f2 | cut -d "." -f1)
			echo "${sequence_basename} : integrity ${test_archive}"

			if  [ "${test_archive}" == "OK" ]
			then

				
				serie_number=$(cat ${pat_st_date}/${sequence_basename}.log | sed -n 3p)
				id_study=$(cat  ${nas_folder}${year}/${study_date2}/${patient}/${study}/study_db.log | sed -n 2p)
				serie_in_db=$(serie_in_db ${id_study} ${serie_number})

				if [ ${serie_in_db} -eq 0 ]
				then
					cp ${pat_st_date}/${sequence_basename}.* ${nas_folder}${year}/${study_date2}/${patient}/${study}/
					/usr/bin/php -f /var/www/html/imvdb/dcm_manager/serie2db.php ${nas_folder}${year}/${study_date2}/${patient}/${study}/ ${sequence_basename}
				else
					echo "  |_ Sequence already added"					
				fi

			else
				echo "achive corrupted : add manually"

			fi
			
			
		done # archive	
rm -rf ${pat_st_date}
done




