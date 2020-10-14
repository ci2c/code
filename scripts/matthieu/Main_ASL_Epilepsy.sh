#!/bin/bash
	
if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
	echo ""
	echo "  -id		: Input directory containing the raw data"
	echo "  -fs		: Path to FS output directory"
	echo ""
	echo "Options :"
	echo "	-all 		: Treat all patients contained in input dir"
	echo "	-f  		: Path of the file subjects.txt"
	echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the raw data"
		echo "  -fs		: Path to FS output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		exit 1
		;;
	-all)
		echo "all patients in are treated"
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Output directory : ${INPUT_DIR}"
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Output directory : ${FS_DIR}"
		;;
	-f) 
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "path of the file subjects.txt : ${FILE_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the raw data"
		echo "  -fs		: Path to FS output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage: Main_ASL_Epilepsy.sh -id <InputDir> -fs <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi

if [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
fi

## Apply ASL Epilepsy Processing
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		while read subject  
		do 
			qbatch -N ASL_${subject}_Ey -q fs_q -oe ~/Logdir ASL_EpilepsyProcess.sh -id ${INPUT_DIR} -sd ${FS_DIR} -subj ${subject} 
			sleep 1
		done < ${FILE_PATH}/subjects.txt
	fi
else
	for subject in $(ls ${INPUT_DIR})  
	do   
		qbatch -N ASL_${subject}_Ey -q split_q -oe ~/Logdir ASL_EpilepsyProcess.sh -id ${INPUT_DIR} -sd ${FS_DIR} -subj ${subject}
		sleep 1
	done
fi

# JOBS=`qstat | grep ASL_ | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "ASL_ pas encore fini"
# sleep 30
# JOBS=`qstat | grep ASL_ | wc -l`
# done

