#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Labels_to_dti.sh Label_file dti_ref.nii Transform.mat Subj_dir"
	echo ""
	echo "  Label_file             : File of the manual segmentation. "
	echo "                     Can be a .txt file containing the name of the segmentation volume and the ROIs ID."
	echo "                     Can be a label manually drawn in T1 space."
	echo "  dti_ref.nii            : Reference DTI for resampling parameters"
	echo "  Transform.mat          : Transformation matrix from T1 to DTI."
	echo "  Subj_dir               : Path to subject directory"
	echo ""
	echo "Usage: Labels_to_dti.sh Label_file dti_ref.nii Transform.mat Subj_dir"
	echo ""
	exit 1
fi

# Gather args
Infile=$1
DTI=$2
Mat=$3
SD=$4

# Type of input label

### ROIs in FS
if [ -n "`echo ${Infile} | grep .txt`" ]
then
	infile=`basename ${Infile}`
	echo "**********************************"
	echo "           FS ROIs"
	echo "mri_extract_label ${SD}/mri/`cat ${Infile}` ${SD}/dti/ROI/${infile%.txt}.mgz"
	mri_extract_label ${SD}/mri/`cat ${Infile}` ${SD}/dti/ROI/${infile%.txt}.mgz
	
	echo "mri_binarize --i ${SD}/dti/ROI/${infile%.txt}.mgz --o ${SD}/dti/ROI/${infile%.txt}_bin.mgz --min 0.1 --max inf"
	mri_binarize --i ${SD}/dti/ROI/${infile%.txt}.mgz --o ${SD}/dti/ROI/${infile%.txt}_bin.mgz --min 0.1 --max inf
	
	rm -f ${SD}/dti/ROI/${infile%.txt}.mgz
	
	mv ${SD}/dti/ROI/${infile%.txt}_bin.mgz ${SD}/dti/ROI/${infile%.txt}.mgz
	
	echo "mgz2FSLnii.sh ${SD}/dti/ROI/${infile%.txt}.mgz ${DTI} ${SD}/dti/ROI/${infile%.txt}_dti.nii ${Mat}"
	mgz2FSLnii.sh ${SD}/dti/ROI/${infile%.txt}.mgz ${DTI} ${SD}/dti/ROI/${infile%.txt}_dti.nii ${Mat}
	
	echo "fslmaths ${SD}/dti/ROI/${infile%.txt}_dti.nii -thr 0.4 -bin ${SD}/dti/ROI/${infile%.txt}_dti_bin.nii"
	fslmaths ${SD}/dti/ROI/${infile%.txt}_dti.nii -thr 0.4 -bin ${SD}/dti/ROI/${infile%.txt}_dti_bin.nii
	
	rm -f ${SD}/dti/ROI/${infile%.txt}_dti.nii.gz
	
	mv ${SD}/dti/ROI/${infile%.txt}_dti_bin.nii.gz ${SD}/dti/ROI/${infile%.txt}_dti.nii.gz
	

### Label on T1
elif [ -n "`echo $1 | grep _t1.nii`" ]
then
	echo "**********************************"
	echo "           T1 Label"
	
	
### Invalid input
else
	echo "Unrecognized label type"
fi
