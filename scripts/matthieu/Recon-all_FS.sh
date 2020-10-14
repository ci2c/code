#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
	echo ""
	echo "  -sd 	: Path to FS output directory"
	echo "  -i	: Path to input directory containing 3DT1.nii"
	echo "  -v	: Version of FS used"
	echo ""
	echo "  Options :"
	echo "  -ad     : Added input directory containing 3DT1.nii"
	echo "	-all 	: Treat all patients contained in input dir"
	echo "	-f  	: Path of the file subjects.txt"
	echo ""
	echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
	echo ""
	exit 1
fi

index=1
ADD_INPUT_DIR=""

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
		echo ""
		echo "  -sd 	: Path to FS output directory"
		echo "  -i	: Path to input directory containing 3DT1.nii"
		echo "  -v	: Version of FS used"
		echo ""
		echo "  Options :"
		echo "  -ad     : Added input directory containing 3DT1.nii"
		echo "	-all 	: Treat all patients contained in input dir"
		echo "	-f  	: Path of the file subjects.txt"
		echo ""
		echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "FS output directory : ${SUBJECTS_DIR}"
		;;
	-i)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Path to input directory containing 3DT1.nii : ${INPUT_DIR}"
		;;
	-v)
		index=$[$index+1]
		eval FS_VERSION=\${$index}
		echo "Version of FS used : ${FS_VERSION}"
		;;
	-ad)
		index=$[$index+1]
		eval ADD_INPUT_DIR=\${$index}
		echo "Added input directory containing 3DT1.nii : ${ADD_INPUT_DIR}"
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
		echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
		echo ""
		echo "  -sd 	: Path to FS output directory"
		echo "  -i	: Path to input directory containing 3DT1.nii"
		echo "  -v	: Version of FS used"
		echo ""
		echo "  Options :"
		echo "  -ad     : Added input directory containing 3DT1.nii"
		echo "	-all 	: Treat all patients contained in input dir"
		echo "	-f  	: Path of the file subjects.txt"
		echo ""
		echo "Usage: Recon-all_FS.sh -sd <SubjDir> -i <InputDir> -v <FSVersion> [ -ad <AddedDir> -f <SubjectsPath> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
elif [ -z ${INPUT_DIR} ]
then
	 echo "-i argument mandatory"
	 exit 1
elif [ -z ${FS_VERSION} ]
then
	 echo "-v argument mandatory"
	 exit 1
fi

## Apply Recon-all
if [ -s ${FILE_PATH}/subjects_CSF_long_ter ]
then
	while read SUBJECT_ID
	do
		mkdir /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID}
		qbatch -q fs_q -oe /NAS/tupac/protocoles/COMAJ/log/${SUBJECT_ID} -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/${ADD_INPUT_DIR} -v ${FS_VERSION}
		sleep 1
	done < ${FILE_PATH}/subjects_CSF_long_ter
# else
# 	for SUBJECT_ID in $(ls ${INPUT_DIR})
# 	do
# 	# 	qbatch -q short.q -oe ~/Logdir -N fs_${SUBJECT_ID}
# 		qbatch -q fs_q -oe ~/Logdir -N fs_${SUBJECT_ID} Recon-all.sh -sd ${SUBJECTS_DIR} -subjid ${SUBJECT_ID} -i ${INPUT_DIR}/${SUBJECT_ID}/${ADD_INPUT_DIR} -v ${FS_VERSION}
# 		sleep 2
# 	done
fi
