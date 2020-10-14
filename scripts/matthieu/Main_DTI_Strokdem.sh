#!/bin/bash
	
if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: Main_DTI_Strokdem.sh INPUT_DIR OUTPUT_DIR"
	echo ""
	echo "  INPUT_DIR	: Input directory containing the rec/par files"
	echo "  FS_DIR		: Path to FS output directory"
	echo "  OUTPUT_DIR	: Path to FSL output directory"
	echo ""
	echo "Usage: Main_DTI_Strokdem.sh INPUT_DIR OUTPUT_DIR"
	echo ""
	exit 1
fi

## I/O management
INPUT_DIR=$1
OUTPUT_DIR=$2
FS_DIR=/home/fatmike/Protocoles_3T/Strokdem/FS5.1

for subject in $(ls ${INPUT_DIR})  
do   
# 	qbatch -N DTI_T1_${subject} -q fs_q -oe ~/Logdir T1_Strokdem.sh ${INPUT_DIR} ${subject} ${OUTPUT_DIR}
	qbatch -N DTI_Pre_${subject} -q M32_q -oe ~/Logdir DTI_StrokdemProcess.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR} -od ${OUTPUT_DIR}
	sleep 2
done