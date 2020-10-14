#!/bin/bash
	
if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
	echo ""
	echo "  -id		: Input directory containing the rec/par files"
	echo "  -od		: Path to FSL/MRtrix output directory"
	echo ""
	echo "Options :"
	echo "	-all 		: Treat all patients contained in input dir"
	echo "	-f  		: Path of the file subjects.txt"
	echo "Usage:  Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
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
		echo "Usage: Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage:  Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
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
		echo "Usage: Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
		echo ""
		echo "  -id		: Input directory containing the rec/par files"
		echo "  -od		: Path to FSL/MRtrix output directory"
		echo ""
		echo "Options :"
		echo "	-all 		: Treat all patients contained in input dir"
		echo "	-f  		: Path of the file subjects.txt"
		echo "Usage:  Main_LST_Alexcis2.sh -id <InputDir> -od <Outputdir> [ -f <SubjectsPath> ]"
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

## Apply Normalize and Binarize Semi-Automatic lesion segmentation on Alexcis subjects
if [ -e ${FILE_PATH}/subjects.txt ]
then
	if [ -s ${FILE_PATH}/subjects.txt ]
	then	
		while read subject  
		do 
			qbatch -N LST_AP2_${subject} -q one_job_q -oe ~/Logdir LST_Alexcis2.sh -subjid ${subject} -od ${OUTPUT_DIR}
			sleep 1
		done < ${FILE_PATH}/subjects.txt
	fi
else
	for subject in $(ls ${INPUT_DIR})  
	do   
		qbatch -N LST_AP2_${subject} -q one_job_q -oe ~/Logdir LST_Alexcis2.sh -subjid ${subject} -od ${OUTPUT_DIR}
		sleep 1
	done
fi

## Wait for end of LST_AP2 jobs
JOBS=`qstat | grep LST_AP2 | wc -l`
while [ ${JOBS} -ge 1 ]
do
echo "LST_AP2 pas encore fini"
sleep 30
JOBS=`qstat | grep LST_AP2 | wc -l`
done

## Compute total lesion volume on each normalized subject
while read SUBJ_ID  
do 
	echo "${OUTPUT_DIR}/${SUBJ_ID}/LST/b_010_wmb_010_lesion_lbm0_030_rmT2FLAIR.nii" >> ${OUTPUT_DIR}/b_010_wmb_010_lesion_lbm0_030.txt
done < ${FILE_PATH}/subjects.txt

if [ ! -e ${OUTPUT_DIR}/tlv_all.csv ]
then
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
		
	% Open the text file containing paths of the "b_010_wmb_010_lesion_lbm0_030_rmT2FLAIR.nii" images
	fid = fopen('${OUTPUT_DIR}/b_010_wmb_010_lesion_lbm0_030.txt', 'r');
	T = textscan(fid,'%s','delimiter','\n');
	fclose(fid);

	% Creation of the Cell of Dicom Files
	NbNiiFiles = size(T{1},1);
	CellNF = cell(NbNiiFiles,1);
	for k= 1 : NbNiiFiles 
	    CellNF{k,1} =T{1}{k};
	end
		
	matlabbatch{end+1}.spm.tools.LST.lesvolume.data_plm_thresh = CellNF;
	matlabbatch{end}.spm.tools.LST.lesvolume.adiof = 1;
		
	spm_jobman('run',matlabbatch);
EOF
fi

while read SUBJ_ID  
do 
	gzip ${OUTPUT_DIR}/${SUBJ_ID}/LST/*.nii
done < ${FILE_PATH}/subjects.txt