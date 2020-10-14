#!/bin/bash
	
if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -fs		: Path to FS output directory"
	echo "  -od		: Path to FSL/MRtrix output directory"
	echo ""
	echo "Options :"
	echo "	-all 		: Treat all patients contained in input dir"
	echo "	-f  		: Path of the file subjects.txt"
	echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
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
		echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
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
		echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -fs		: Path to FS output directory"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage: Main_DTI_Alexcis.sh -id <InputDir> -od <Outputdir> -fs  <SubjDir> [ -f <SubjectsPath> ]"
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

# ## Apply Alexcis DTI Processing
# if [ -e ${FILE_PATH}/subjects.txt ]
# then
# 	if [ -s ${FILE_PATH}/subjects.txt ]
# 	then	
# 		while read subject  
# 		do 
# # 			qbatch -N DTI_HA_${subject} -q fs_q -oe ~/Logdir 
# 			qbatch -N DTI_AP_${subject} -q fs_q -oe ~/Logdir DTI_AlexcisProcess.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR} -od ${OUTPUT_DIR} 
# 			sleep 1
# 		done < ${FILE_PATH}/subjects.txt
# 	fi
# else
# 	for subject in $(ls ${INPUT_DIR})  
# 	do   
# 		qbatch -N DTI_AP_${subject} -q fs_q -oe ~/Logdir DTI_AlexcisProcess.sh -id ${INPUT_DIR} -subjid ${subject} -fs ${FS_DIR} -od ${OUTPUT_DIR}
# 		sleep 1
# 	done
# fi

# ## Wait for end of DTI_AP jobs
# JOBS=`qstat | grep DTI_AP | wc -l`
# while [ ${JOBS} -ge 1 ]
# do
# echo "DTI_AP pas encore fini"
# sleep 5
# JOBS=`qstat | grep DTI_AP | wc -l`
# done
# 
# ## Calcul of Jaccard index and Overlap Coefficient of normalized binary probability maps of fibers number
# matlab -nodisplay <<EOF
# Overlap('${INPUT_DIR}', 'subjectsT','${OUTPUT_DIR}');
# Overlap('${INPUT_DIR}', 'subjectsM','${OUTPUT_DIR}');
# Overlap('${INPUT_DIR}', 'subjects','${OUTPUT_DIR}');
# EOF

## Calcul mean of each ROI on normalized binary probability maps of fibers number
for NameRoi in precentral G_temp_sup_lateral G_postcentral S_calcarine
do
	find ${OUTPUT_DIR} -name "bwThresh_Prob_${NameRoi}*" > ${OUTPUT_DIR}/subj_tmp.txt
# 	cat ${OUTPUT_DIR}/subj_tmp.txt
	index=1
	for subj in `cat ${OUTPUT_DIR}/subj_tmp.txt`
	do
		if [ ${index} -eq 1 ]
		then
			echo "${subj}" >> ${OUTPUT_DIR}/tmp.txt
		else		      
			echo " -add ${subj}" >> ${OUTPUT_DIR}/tmp.txt
		fi
		index=$[${index}+1]
	done
# 	cat ${OUTPUT_DIR}/tmp.txt
	NbSubjects=$(cat ${OUTPUT_DIR}/subj_tmp.txt | wc -l)
	fslmaths $(cat ${OUTPUT_DIR}/tmp.txt) -div ${NbSubjects} -mul ${OUTPUT_DIR}/brCC_fsaverage_dil.nii ${OUTPUT_DIR}/map_mean_${NameRoi}.nii.gz -odt double
	rm -f ${OUTPUT_DIR}/tmp.txt
done