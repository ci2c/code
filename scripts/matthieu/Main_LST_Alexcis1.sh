#!/bin/bash
	
if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -fs		: Path to FS output directory"
	echo "  -od		: Path to FSL/MRtrix output directory"
	echo ""
	echo "Options :"
	echo "	-all 		: Treat all patients contained in input dir"
	echo "	-f  		: Path of the file subjects.txt"
	echo "Usage:  Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
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
		echo "Usage: Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage:  Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		exit 1
		;;
	-all)
		echo "all patients in are treated"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Output directory : ${OUTPUT_DIR}"
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
		echo "Usage: Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage:  Main_LST_Alexcis1.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
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

if [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

if [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
fi

## Apply Lesion Segmentation on Alexcis subjects
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		while read subject  
		do 
			qbatch -N LST_AP1_${subject} -q one_job_q -oe ~/Logdir LST_Alexcis1.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR} -od ${OUTPUT_DIR} 
			sleep 1
		done < ${FILE_PATH}/subjects.txt
	fi
else
	for subject in $(ls ${INPUT_DIR})  
	do   
		qbatch -N LST_AP1_${subject} -q one_job_q -oe ~/Logdir LST_Alexcis1.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR} -od ${OUTPUT_DIR}
		sleep 1
	done
fi

# ## Wait for end of LST_AP jobs
# JOBS=`qstat | grep LST_AP | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "LST_AP pas encore fini"
# sleep 30
# JOBS=`qstat | grep LST_AP | wc -l`
# done