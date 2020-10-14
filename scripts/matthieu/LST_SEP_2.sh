#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to the FS subjects directory"
	echo ""
	echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
	echo ""
	exit 1
fi

index=1

# Set default parameters


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to the FS subjects directory"
		echo ""
		echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		exit 1
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject ID : ${SUBJ_ID}"
		;;
	-fs)
		index=$[$index+1]
		eval FS_DIR=\${$index}
		echo "Path to output directory (processing results) : ${FS_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to the FS subjects directory"
		echo ""
		echo "Usage: LST_SEP_2.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJ_ID} ]
then
	 echo "-subjid argument mandatory"
	 exit 1
elif [ -z ${FS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
fi

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

#################################################################################
## Step 3. Registration of the optic radiation mask from MNI to T1 subject space
#################################################################################

if [ ! -s ${FS_DIR}/${SUBJ_ID}/LST/woptic_radiation_thr25_1mm.nii ]
then
	matlab -nodisplay <<EOF
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
		
	matlabbatch{end+1}.spm.tools.vbm8.tools.defs.field1 = {'${FS_DIR}/${SUBJ_ID}/LST/iy_T1_RAS.nii,1'};
	matlabbatch{end}.spm.tools.vbm8.tools.defs.images = {'/home/notorious/NAS/olivier/MS/atlases/optic_radiation_thr25_1mm.nii'};
	matlabbatch{end}.spm.tools.vbm8.tools.defs.interp = 0;
	matlabbatch{end}.spm.tools.vbm8.tools.defs.modulate = 0;
		
	spm_jobman('run',matlabbatch);
EOF
fi