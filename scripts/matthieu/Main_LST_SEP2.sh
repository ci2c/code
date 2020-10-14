#!/bin/bash
	
if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -fs		: Path to FS output directory"
	echo "	-f  		: Path of the file subjects.txt"
	echo ""
	echo "Usage:  Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
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
		echo "Usage: Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
		echo ""
		exit 1
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "FS directory : ${FS_DIR}"
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory : ${INPUT_DIR}"
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
		echo ""enregistrement
		echo "Usage: Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "	-f  		: Path of the file subjects.txt"
		echo ""
		echo "Usage:  Main_LST_SEP2.sh -id <InputDir> -fs <SubjDir> -f <SubjectsPath>"
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

## Apply registration of the optic radiation mask from MNI to T1 subject space
if [ -s ${FILE_PATH}/subjects.txt ]
then
	while read subject  
	do 
		qbatch -N LST_SEP2_${subject} -q three_job_q -oe ~/Logdir LST_SEP_2.sh -subjid ${subject} -fs ${FS_DIR}
		sleep 1
	done < ${FILE_PATH}/subjects.txt
fi

## Wait for end of LST_SEP2 jobs
JOBS=`qstat | grep LST_SEP2 | wc -l`
while [ ${JOBS} -ge 1 ]
do
	echo "LST_SEP2 pas encore fini"
	sleep 30
	JOBS=`qstat | grep LST_SEP2 | wc -l`
done

## Compute total lesion volume and intersectional lesion volume with optic radiation on each  subject
# Compute the mean of intra-cranial volumes of all subjects
while read subject  
do 
	TIV=$(cat ${FS_DIR}/${subject}/stats/aseg.stats | grep EstimatedTotalIntraCranialVol | awk '{print $9}')
	TIV=${TIV%,}
	echo "${TIV}" >> ${FS_DIR}/TIV_subjects.txt
done < ${FILE_PATH}/subjects.txt

matlab -nodisplay <<EOF	
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	
	TIV = textread('${FS_DIR}/TIV_subjects.txt', '%f');
	mean_TIV = mean(TIV);
	save('${FS_DIR}/mean_TIV.mat','mean_TIV');
EOF

# Compute the total lesion volume and intersectional lesion volume
if [ -s ${FILE_PATH}/subjects.txt ]
then
	while read subject  
	do 
		qbatch -N LST_SEP3_${subject} -q three_job_q -oe ~/Logdir LST_SEP_3.sh -subjid ${subject} -fs ${FS_DIR}
		sleep 1
	done < ${FILE_PATH}/subjects.txt
fi
