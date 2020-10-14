#! /bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo "  -fcd                             : Path to the FCD volume"
	echo ""
	echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
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
		echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fcd                             : Path to the FCD volume"
		echo ""
		echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "SD : $SD"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-fcd)
		index=$[$index+1]
		eval FCD=\${$index}
		echo "FCD : $FCD"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fcd                             : Path to the FCD volume"
		echo ""
		echo "Usage: ResampleFCDlabels.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -fcd <FCD_VOLUME>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

# Check if FCD volumes exists
if [ ! -f ${FCD} ]
then
	echo "The FCD volume provided does not exist"
	exit 1
fi

# Create epilepsy directory if not already created
if [ ! -d ${DIR}/epilepsy ]
then
	mkdir ${DIR}/epilepsy
fi

# Binarize FCD volume
echo "mri_binarize --i ${FCD} --o /tmp/FCD_tmp_$$.nii --min 0.001 --max inf"
mri_binarize --i ${FCD} --o /tmp/FCD_tmp_$$.nii --min 0.001 --max inf

# Project FCD on cortical surfaces
echo "mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi lh --surf white --o lh.fcd --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi lh --surf white --o lh.fcd --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi rh --surf white --o rh.fcd --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi rh --surf white --o rh.fcd --regheader ${SUBJ} --out_type paint

# Project FCD on cortical with a slight fwhm 5mm surface smooth
echo "mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi lh --surf white --o lh.fwhm5.fcd --regheader ${SUBJ} --out_type paint --surf-fwhm 5"
mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi lh --surf white --o lh.fwhm5.fcd --regheader ${SUBJ} --out_type paint --surf-fwhm 5

echo "mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi rh --surf white --o rh.fwhm5.fcd --regheader ${SUBJ} --out_type paint --surf-fwhm 5"
mri_vol2surf --mov /tmp/FCD_tmp_$$.nii --hemi rh --surf white --o rh.fwhm5.fcd --regheader ${SUBJ} --out_type paint --surf-fwhm 5

# Convert stuffs
echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fcd.w lh.fcd"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fcd.w lh.fcd

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fcd.w rh.fcd"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fcd.w rh.fcd

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm5.fcd.w lh.fwhm5.fcd"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm5.fcd.w lh.fwhm5.fcd

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm5.fcd.w rh.fwhm5.fcd"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm5.fcd.w rh.fwhm5.fcd

rm -f ${DIR}/surf/lh.fcd.w ${DIR}/surf/rh.fcd.w ${DIR}/surf/lh.fwhm5.fcd.w ${DIR}/surf/rh.fwhm5.fcd.w /tmp/FCD_tmp_$$.nii

# Resample to common surface fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/surf/lh.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/lh.fsaverage.fcd.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/surf/lh.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/lh.fsaverage.fcd.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/surf/rh.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/rh.fsaverage.fcd.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/surf/rh.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/rh.fsaverage.fcd.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/surf/lh.fwhm5.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/lh.fwhm5.fsaverage.fcd.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/surf/lh.fwhm5.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/lh.fwhm5.fsaverage.fcd.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/surf/rh.fwhm5.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/rh.fwhm5.fsaverage.fcd.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/surf/rh.fwhm5.fcd --sfmt curv --noreshape --no-cortex --tval ${DIR}/surf/rh.fwhm5.fsaverage.fcd.mgh --tfmt curv

# Move data
mv ${DIR}/surf/lh.fcd ${DIR}/surf/rh.fcd ${DIR}/surf/lh.fsaverage.fcd.mgh ${DIR}/surf/rh.fsaverage.fcd.mgh ${DIR}/surf/lh.fwhm5.fcd ${DIR}/surf/rh.fwhm5.fcd ${DIR}/surf/lh.fwhm5.fsaverage.fcd.mgh ${DIR}/surf/rh.fwhm5.fsaverage.fcd.mgh ${DIR}/epilepsy

