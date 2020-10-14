#!/bin/bash
	
if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
	echo ""
	echo "	-id		: Input directory containing the raw data"
	echo "	-fs		: Path to FS output directory"
	echo "	-o		: output folder"	
	echo "	-f  		: Path of the file subjects.txt"
	echo ""
	echo "Usage:  Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
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
		echo "Usage: Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
		echo ""
		echo "	-id		: Input directory containing the raw data"
		echo "	-fs		: Path to FS output directory"
		echo "	-o		: output folder"	
		echo "	-f  		: Path of the file subjects.txt"
		echo ""		
		echo "Usage:  Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
		echo ""
		exit 1
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
	-o)
		index=$[$index+1]
		eval asldir=\${$index}
		echo "output folder : ${asldir}"
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
		echo ""
		echo "Usage: Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
		echo ""
		echo "	-id		: Input directory containing the raw data"
		echo "	-fs		: Path to FS output directory"
		echo "	-o		: output folder"	
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_ASL_GPMOnSurface.sh -id <InputDir> -fs <SubjDir> -o <path> -f <SubjectsPath>"
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

if [ -z ${asldir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi

## Apply ASL Epilepsy Processing
if [ -s ${FILE_PATH}/subjects.txt ]
then
	while read subject  
	do 
		qbatch -N GPMS_${subject} -q long.q -oe ~/Logdir ASL_GeneratePerfusionMapOnSurface.sh -sd ${FS_DIR}  -subj ${subject}  -i ${INPUT_DIR}/${subject}/Nifti  -o ${asldir} 
		sleep 1
	done < ${FILE_PATH}/subjects.txt
fi

# JOBS=`qstat | grep ASL_ | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "ASL_ pas encore fini"
# sleep 30
# JOBS=`qstat | grep ASL_ | wc -l`
# done

