#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
	echo ""
	echo "  -f  		: Path of the file subjects.txt "
	echo "  -od		: Output directory "	
	echo ""
	echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
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
		echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
		echo ""
		echo "  -f  		: Path of the file subjects.txt "
		echo "  -od		: Output directory "	
		echo ""
		echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
		echo ""
		exit 1
		;;
	-f)
		index=$[$index+1]
		eval FILE_PATH=\${$index}
		echo "Path of the file subjects.txt : ${FILE_PATH}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Output directory : ${OUTPUT_DIR}"
		;;	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
		echo ""
		echo "  -f  		: Path of the file subjects.txt "
		echo "  -od		: Output directory "	
		echo ""
		echo "Usage:  Main_MotorCortex_Mouse.sh -f <SubjectsPath> -od <outputdir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - September, 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${FILE_PATH} ]
then
	 echo "-f argument mandatory"
	 exit 1
fi
if [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

if [ -s ${FILE_PATH}/subjects.txt ]
then
	while read SUBJ_ID  
	do 
		qbatch -N MC_${SUBJ_ID} -q M32_q -oe ~/Logdir MotorCortexQuantification_Mouse.sh -subj ${SUBJ_ID} \
		-od ${OUTPUT_DIR}
		sleep 1

	done < ${FILE_PATH}/subjects.txt
fi