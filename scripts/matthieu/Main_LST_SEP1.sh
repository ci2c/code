#!/bin/bash
	
if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
	echo ""
	echo "  -id		: Input directory containing the rec/par or nii files"
	echo "  -fs		: Path to FS output directory"
	echo "	-f  		: Path of the file subjects.txt"
	echo ""
	echo "Usage:  Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
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
		echo "Usage: Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par or nii files"
		echo "  -fs		: Path to FS output directory"
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory : ${INPUT_DIR}"
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "FS directory : ${FS_DIR}"
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
		echo "Usage: Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par or nii files"
		echo "  -fs		: Path to FS output directory"
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_LST_SEP1.sh -id <InputDir> -fs  <SubjDir> -f <SubjectsPath>"
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

if [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

## Apply PVE-label estimation and lesion segmentation on SEP subjects
if [ -s ${FILE_PATH}/subjects.txt ]
then	
	while read subject  
	do 
		qbatch -N LST_SEP1_${subject} -q three_job_q -oe ~/Logdir LST_SEP_1.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR}
		sleep 1
	done < ${FILE_PATH}/subjects.txt
fi