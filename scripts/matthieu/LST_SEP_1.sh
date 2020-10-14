#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
	echo ""
	echo "  -id		: Input directory containing the rec/par or nii files"
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo ""
	echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
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
		echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par or nii files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo ""
		echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
		echo ""
		exit 1
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Path to FS output directory (equivalent to SUBJECTS_DIR) : ${FS_DIR}"
		;;
	-id)
		index=$[$index+1]
		eval INPUT_DIR=\${$index}
		echo "Input directory containing the rec/par files : ${INPUT_DIR}"
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject ID : ${SUBJ_ID}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -id		: Input directory containing the rec/par or nii files"
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo ""
		echo "Usage: LST_SEP_1.sh -id <InputDir> -subjid <SubjId> -fs <SubjDir>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
elif [ -z ${INPUT_DIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
elif [ -z ${SUBJ_ID} ]
then
	 echo "-subjid argument mandatory"
	 exit 1
fi

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

###############################
## Step 1. Prepare input data : T1 & FLAIR sequence
###############################

if [ ! -s ${FS_DIR}/${SUBJ_ID}/mri/aparc.a2009s+aseg.mgz ]
then
	echo "Freesurfer was not fully processed"
	echo "Script terminated"
	exit 1
fi

# Search of FLAIR rec/par or nifti files
T1=$(ls ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz)
Flair=$(ls ${INPUT_DIR}/${SUBJ_ID}/*t2flair*.par)
gunzip $(ls ${INPUT_DIR}/${SUBJ_ID}/*T2FLAIR*.nii.*)
NiiFlair=$(ls ${INPUT_DIR}/${SUBJ_ID}/*T2FLAIR*.nii)

if [ -n "${T1}" ] && [ -n "${Flair}" ]
then
	# Creation of source directory
	if [ ! -d ${FS_DIR}/${SUBJ_ID}/LST ]
	then
		mkdir -p ${FS_DIR}/${SUBJ_ID}/LST
	else
		rm -rf ${FS_DIR}/${SUBJ_ID}/LST/*
	fi
	
	# Move of T2 Flair rec/par in source directory
	cp -t ${FS_DIR}/${SUBJ_ID}/LST ${INPUT_DIR}/${SUBJ_ID}/*t2flair*.par ${INPUT_DIR}/${SUBJ_ID}/*t2flair*.rec
	
	# Convert to nifti and rename source files
	dcm2nii -o ${FS_DIR}/${SUBJ_ID}/LST ${FS_DIR}/${SUBJ_ID}/LST/*t2flair*.par
	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${FS_DIR}/${SUBJ_ID}/LST/T1_RAS.nii.gz --out_orientation LAS
	mv ${FS_DIR}/${SUBJ_ID}/LST/*T2FLAIR*.nii.gz ${FS_DIR}/${SUBJ_ID}/LST/T2FLAIR.nii.gz
	
	# Remove rec/par files from source directory
	rm -f ${FS_DIR}/${SUBJ_ID}/LST/*.par ${FS_DIR}/${SUBJ_ID}/LST/*.rec
	gunzip ${FS_DIR}/${SUBJ_ID}/LST/*.gz
	
elif [ -n "${T1}" ] && [ -n "${NiiFlair}" ]
then
	# Creation of source directory
	if [ ! -d ${FS_DIR}/${SUBJ_ID}/LST ]
	then
		mkdir -p ${FS_DIR}/${SUBJ_ID}/LST
	else
		rm -rf ${FS_DIR}/${SUBJ_ID}/LST/*
	fi
	
	# Move of T2 Flair in source directory
	cp -t ${FS_DIR}/${SUBJ_ID}/LST ${INPUT_DIR}/${SUBJ_ID}/*T2FLAIR*.nii
	
	# Convert to nifti and rename source files
	mri_convert ${FS_DIR}/${SUBJ_ID}/mri/nu.mgz ${FS_DIR}/${SUBJ_ID}/LST/T1_RAS.nii.gz --out_orientation RAS
	mv ${FS_DIR}/${SUBJ_ID}/LST/*T2FLAIR*.nii ${FS_DIR}/${SUBJ_ID}/LST/T2FLAIR.nii
	
	gunzip ${FS_DIR}/${SUBJ_ID}/LST/*.gz
	
else
	echo "Source 3DT1 or T2 FLAIR missing"
	exit 1
fi

###############################
## Step 2. PVE-label estimation and lesion segmentation
###############################

if [ ! -s ${FS_DIR}/${SUBJ_ID}/LST/p0T1_RAS.nii ]
then
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
	
	matlabbatch{end+1}.spm.tools.LST.lesiongrow.data_T1 = {'${FS_DIR}/${SUBJ_ID}/LST/T1_RAS.nii,1'};
	matlabbatch{end}.spm.tools.LST.lesiongrow.data_FLAIR = {'${FS_DIR}/${SUBJ_ID}/LST/T2FLAIR.nii,1'};
	matlabbatch{end}.spm.tools.LST.lesiongrow.segopts.initial = [0.1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
	matlabbatch{end}.spm.tools.LST.lesiongrow.segopts.belief = 0;
	matlabbatch{end}.spm.tools.LST.lesiongrow.segopts.mrf = 1;
	matlabbatch{end}.spm.tools.LST.lesiongrow.segopts.maxiter = 50;
	matlabbatch{end}.spm.tools.LST.lesiongrow.segopts.threshold = 0;
	matlabbatch{end}.spm.tools.LST.lesiongrow.output.lesions.prob = 1;
	matlabbatch{end}.spm.tools.LST.lesiongrow.output.lesions.binary = 1;
	matlabbatch{end}.spm.tools.LST.lesiongrow.output.lesions.normalized = 1;
	matlabbatch{end}.spm.tools.LST.lesiongrow.output.other = 1;

	spm_jobman('run',matlabbatch);
EOF
fi