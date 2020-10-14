#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "  -od		: Path to output directory (processing results)"
	echo ""
	echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
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
		echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
		echo ""
		exit 1
		;;
	-subjid)
		index=$[$index+1]
		eval SUBJ_ID=\${$index}
		echo "Subject ID : ${SUBJ_ID}"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "Path to output directory (processing results) : ${OUTPUT_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -od		: Path to output directory (processing results)"
		echo ""
		echo "Usage: LST_Alexcis2.sh -subjid <SubjId> -od <OutputDir>"
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
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

########################################################
## Step 1. Normalize Semi-automatic lesion segmentation
########################################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/LST/wmb_000_lesion_lbm0_010_rmT2FLAIR.nii ]
then
	matlab -nodisplay <<EOF
		fprintf('normalize probability lesion map ... ')
		spm('defaults', 'FMRI');
		spm_jobman('initcfg');
		matlabbatch={};
		
		matlabbatch{end+1}.spm.tools.vbm8.tools.defs.field1 = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST', 'y_T1_RAS.nii')};
		matlabbatch{end}.spm.tools.vbm8.tools.defs.images = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST', 'mb_000_lesion_lbm0_010_rmT2FLAIR.nii')};
		matlabbatch{end}.spm.tools.vbm8.tools.defs.interp = 0;
		matlabbatch{end}.spm.tools.vbm8.tools.defs.modulate = 0;
		
		spm_jobman('run',matlabbatch);
EOF
fi

#########################################################################
## Step 2. Reslice normalized lesion segmentation to MNI152_1mm template
#########################################################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii ]
then
	cp ${FSLDIR}/data/standard/MNI152_T1_1mm.nii.gz ${OUTPUT_DIR}/${SUBJ_ID}/LST
	gunzip ${OUTPUT_DIR}/${SUBJ_ID}/LST/MNI152_T1_1mm.nii.gz
	
	matlab -nodisplay <<EOF
		spm('defaults', 'FMRI');
		spm_jobman('initcfg');
		matlabbatch={};
		
		matlabbatch{end+1}.spm.spatial.coreg.write.ref = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST,'MNI152_T1_1mm.nii')};
		matlabbatch{end}.spm.spatial.coreg.write.source = {fullfile('${OUTPUT_DIR}/${SUBJ_ID}/LST', 'wmb_000_lesion_lbm0_010_rmT2FLAIR.nii')};
		matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
		matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
		matlabbatch{end}.spm.spatial.coreg.write.roptions.mask = 0;
		matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
		
		spm_jobman('run',matlabbatch);
EOF
fi

################################################
## Step 3. Remove NaN & Compute lesional volume
################################################

if [ ! -e ${OUTPUT_DIR}/${SUBJ_ID}/LST/b_010_wmb_010_lesion_lbm0_030_rmT2FLAIR.nii ]
then
	fslmaths ${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii -nan ${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii.gz
	rm -f ${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii
	gunzip ${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii.gz
		
	matlab -nodisplay <<EOF
		V1=spm_vol('${OUTPUT_DIR}/atlases/optic_radiation_thr25_1mm.nii');
		V2=spm_vol('${OUTPUT_DIR}/${SUBJ_ID}/LST/rwmb_000_lesion_lbm0_010_rmT2FLAIR.nii');
		V1=spm_read_vols(V1);
		V2=spm_read_vols(V2);
		intersection=(logical(V1)&logical(V2));
		volume_lesionnel=length(find(intersection));
		save('${OUTPUT_DIR}/${SUBJ_ID}/LST/vol_les.txt','volume_lesionnel','-ascii');
EOF
fi