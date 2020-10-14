
#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
	echo ""
	echo "  -od	: output nifti file directory "
	echo ""
	echo "	-t	: path of the template file TemplateMouse.nii "
	echo ""
	echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
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
		echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "	-t	: path of the template file TemplateMouse.nii "
		echo ""
		echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output subjects directory : ${OUTPUT_DIR}"
		;;
	-t)
		index=$[$index+1]
		eval TEMP_PATH=\${$index}
		echo "path of the template file TemplateRat.nii : ${TEMP_PATH}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
		echo ""
		echo "  -od	: output nifti file directory "
		echo ""
		echo "	-t	: path of the template file TemplateMouse.nii "
		echo ""
		echo "Usage: Main_MS_SecondStep.sh -od <outputdir> -t <templatepath>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
elif [ -z ${TEMP_PATH} ]
then
	 echo "-t argument mandatory"
	 exit 1
fi

## Conversion of dicom files to Nifti, mean of Nifti PET files and copy of the right brain mouse template
for tp in $(ls ${OUTPUT_DIR})
do
# 	for subj in $(ls ${OUTPUT_DIR}/${tp})
	for subj in C4
	do
		qbatch -N ${subj}_${tp}_2 -q fs_q -oe ~/Logdir MouseStudy_SecondStep.sh -od ${OUTPUT_DIR}/${tp}/${subj} -t ${TEMP_PATH}
		sleep 2
	done
done