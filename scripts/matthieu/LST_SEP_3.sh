#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
	echo ""
	echo "  -subjid		: Subject ID"
	echo "  -fs		: Path to the FS subjects directory"
	echo ""
	echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
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
		echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to the FS subjects directory"
		echo ""
		echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
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
		echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
		echo ""
		echo "  -subjid		: Subject ID"
		echo "  -fs		: Path to the FS subjects directory"
		echo ""
		echo "Usage: LST_SEP_3.sh -subjid <SubjId> -fs <SubjDir>"
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

##################################################
## Step 4. Remove NaN & Compute lesional volumes
##################################################

if [ ! -s ${FS_DIR}/${SUBJ_ID}/LST/Volumes_lesionels.txt ]
then
	TIV=$(cat ${FS_DIR}/${SUBJ_ID}/stats/aseg.stats | grep EstimatedTotalIntraCranialVol | awk '{print $9}')
	TIV=${TIV%,}
	
	fslmaths ${FS_DIR}/${SUBJ_ID}/LST/mb_000_lesion_lbm0_010_rmT2FLAIR.nii -nan ${FS_DIR}/${SUBJ_ID}/LST/mb_000_lesion_lbm0_010_rmT2FLAIR.nii.gz
	rm -f ${FS_DIR}/${SUBJ_ID}/LST/mb_000_lesion_lbm0_010_rmT2FLAIR.nii
	gunzip ${FS_DIR}/${SUBJ_ID}/LST/mb_000_lesion_lbm0_010_rmT2FLAIR.nii.gz
		
	matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		
		load('${FS_DIR}/mean_TIV.mat');
		V1=spm_vol('${FS_DIR}/${SUBJ_ID}/LST/woptic_radiation_thr25_1mm.nii');
		V2=spm_vol('${FS_DIR}/${SUBJ_ID}/LST/mb_000_lesion_lbm0_010_rmT2FLAIR.nii');
		V1=spm_read_vols(V1);
		V2=spm_read_vols(V2);
		volume_total_lesionnel = (length(find(logical(V2)))/${TIV})*mean_TIV;
		intersection=(logical(V1)&logical(V2));
		volume_intersection_lesionnel=(length(find(intersection))/${TIV})*mean_TIV;

		fid = fopen('${FS_DIR}/${SUBJ_ID}/LST/Volumes_lesionnels.txt','w');
		fprintf(fid,'%s','Volume lésionnel total : ');
		fprintf(fid,'%f\n',volume_total_lesionnel);
		fprintf(fid,'%s','Volume lésionnel intersecté avec les radiations optiques : ');
		fprintf(fid,'%f\n',volume_intersection_lesionnel);
		fclose(fid);
EOF
fi