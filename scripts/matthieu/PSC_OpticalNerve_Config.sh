#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: PSC_OpticalNerve_Config.sh  -fs  <SubjDir>  -subj  <SubjName>"
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo " "
	echo ""
	echo "Usage: PSC_OpticalNerve_Config.sh  -fs  <SubjDir>  -subj  <SubjName>"
	exit 1
fi


#### Inputs ####
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PSC_OpticalNerve_Config.sh  -fs  <SubjDir>  -subj  <SubjName>"
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo " "
		echo ""
		echo "Usage: PSC_OpticalNerve_Config.sh  -fs  <SubjDir>  -subj  <SubjName>"
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


# Check inputs
DIR=${fs}/${subj}
if [ ! -e ${DIR} ]
then
	echo "Can not find ${DIR} directory"
	exit 1
fi

echo "mri_convert ${DIR}/mri/nu.mgz ${DIR}/mri/t1_native_ras.nii --out_orientation RAS"
mri_convert ${DIR}/mri/nu.mgz ${DIR}/mri/t1_native_ras.nii --out_orientation RAS

bet ${DIR}/mri/t1_native_ras.nii ${DIR}/label/3DT1_brain -n -m