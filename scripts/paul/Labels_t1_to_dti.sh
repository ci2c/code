#!/bin/bash


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Labels_t1_to_dti.sh  -fs <freesurfer_dir>  -subj <subj>  -li <label_info_dir>"
	echo ""
	echo "  -fs <freesurfer_dir>      : freesurfer directory (i.e. SUBJECTS_DIR)"
	echo "  -subj <subj>              : subject name"
	echo "  -li <label_info_dir>      : directory containing label info"
	echo ""
	echo "Usage: Labels_t1_to_dti.sh  -fs <freesurfer_dir>  -subj <subj>  -li <label_info_dir>"
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Labels_t1_to_dti.sh  -fs <freesurfer_dir>  -subj <subj>  -li <label_info_dir>"
		echo ""
		echo "  -fs <freesurfer_dir>      : freesurfer directory (i.e. SUBJECTS_DIR)"
		echo "  -subj <subj>              : subject name"
		echo "  -li <label_info_dir>      : directory containing label info"
		echo ""
		echo "Usage: Labels_t1_to_dti.sh  -fs <freesurfer_dir>  -subj <subj>  -li <label_info_dir>"
		exit 1
		;;
	-fs)
		FS=`expr $index + 1`
		eval FS=\${$FS}
		echo "  |-------> FS : ${FS}"
		index=$[$index+1]
		;;
	-subj)
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "  |-------> SUBJ : ${SUBJ}"
		index=$[$index+1]
		;;
	-li)
		LI=`expr $index + 1`
		eval LI=\${$LI}
		echo "  |-------> label info dir : ${LI}"
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

DIR=${FS}/${SUBJ}

for Label in `ls ${LI}`
do
	if [ ! -f ${DIR}/dti/label/${Label%.txt}_dti.nii ]
	then
		echo "*******************************"
		echo "Processing ${Label}"
		
		# Extraction du label
		echo "mri_extract_label "${DIR}/mri/`cat ${LI}/${Label}`" ${DIR}/dti/label/${Label%.txt}.mgz"
		mri_extract_label ${DIR}/mri/`cat ${LI}/${Label}` ${DIR}/dti/label/${Label%.txt}.mgz
		
		# Conversion en nii
		echo "mri_convert ${DIR}/dti/label/${Label%.txt}.mgz ${DIR}/dti/label/${Label%.txt}.nii --out_orientation RAS"
		mri_convert ${DIR}/dti/label/${Label%.txt}.mgz ${DIR}/dti/label/${Label%.txt}.nii --out_orientation RAS
		
		echo "rm -f ${DIR}/dti/label/${Label%.txt}.mgz"
		rm -f ${DIR}/dti/label/${Label%.txt}.mgz
		
		# Binarisation du label
		echo "fslmaths ${DIR}/dti/label/${Label%.txt}.nii -bin ${DIR}/dti/label/${Label%.txt}_bin.nii"
		fslmaths ${DIR}/dti/label/${Label%.txt}.nii -bin ${DIR}/dti/label/${Label%.txt}_bin.nii
		
		echo "gunzip ${DIR}/dti/label/${Label%.txt}_bin.nii.gz"
		gunzip -f ${DIR}/dti/label/${Label%.txt}_bin.nii.gz
		
		# Conversion en mnc
		echo "nii2mnc ${DIR}/dti/label/${Label%.txt}_bin.nii ${DIR}/dti/label/${Label%.txt}_bin.mnc"
		nii2mnc ${DIR}/dti/label/${Label%.txt}_bin.nii ${DIR}/dti/label/${Label%.txt}_bin.mnc
		
		# Recalage non-lineaire sur le dti
		echo "mincresample -like ${DIR}/dti/nl_fit/source_to_target_nlin.mnc -transformation ${DIR}/dti/nl_fit/source_to_target_nlin.xfm ${DIR}/dti/label/${Label%.txt}_bin.mnc ${DIR}/dti/label/${Label%.txt}_dti.mnc"
		mincresample -like ${DIR}/dti/nl_fit/source_to_target_nlin.mnc -transformation ${DIR}/dti/nl_fit/source_to_target_nlin.xfm ${DIR}/dti/label/${Label%.txt}_bin.mnc ${DIR}/dti/label/${Label%.txt}_dti.mnc
		
		echo "rm -f ${DIR}/dti/label/${Label%.txt}_bin.nii ${DIR}/dti/label/${Label%.txt}_bin.mnc"
		rm -f ${DIR}/dti/label/${Label%.txt}_bin.nii ${DIR}/dti/label/${Label%.txt}_bin.mnc
		
		# Convert to nii
matlab -nodisplay <<EOF
cd ${DIR}/dti/label
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${DIR}/dti/label/${Label%.txt}_dti.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF

		echo "rm -f ${DIR}/dti/label/${Label%.txt}_dti.mnc"
		rm -f ${DIR}/dti/label/${Label%.txt}_dti.mnc
	fi
done
