#! /bin/bash

if [ $# -lt 5 ]
then
		echo ""
		echo "Usage: prep_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "  -roidir 			: ROI DIR : directory containing roi files in MNI space"
		echo ""
		echo "Usage: prep_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
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
		echo ""
		echo "Usage: prep_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "  -sd                             : Subjects Dir : directory containing the patient records to control"
		echo ""
		echo "	-subj				: Subj ID"
		echo ""
		echo "  -roidir 			: ROI DIR : directory containing roi files in MNI space"
		echo ""
		echo "Usage: prep_tracto_on_roi -sd <SUBJECTS_DIR> -subj <SUBJ>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "SUBJ_DIR : $SD"
		;;

	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "SUBJ : $SUBJ"
		;;

	-roidir)
		
		ROIDIR=`expr $index + 1`
		eval ROIDIR=\${$ROIDIR}
		echo "ROIDIR : $ROIDIR"
		;;

	
	esac
	index=$[$index+1]
done




## créé la matrice de transformation dti_to_mni 

echo "DIR=${SD}/${SUBJ}/dti"
DIR=${SD}/${SUBJ}/dti

echo "mri_convert ${DIR}/mrtrix/t1_ras.nii ${DIR}/mrtrix/t1_ras.mnc"
mri_convert ${DIR}/mrtrix/t1_ras.nii ${DIR}/mrtrix/t1_ras.mnc

echo "mritotal ${DIR}/mrtrix/t1_ras.mnc ${DIR}/mrtrix/nl_transform/b0_to_mni.xfm -clobber"
mritotal ${DIR}/mrtrix/t1_ras.mnc ${DIR}/mrtrix/nl_transform/b0_to_mni.xfm -clobber



## utilise les ROI dans le dossier ROIDIR
## recale les ROI dans l'espace du sujet avec la matrice inverse dti_to_mni
## binarise les ROI obtenues pour obtenir des masques

echo "rm -Rf ${DIR}/ROI"
rm -Rf ${DIR}/ROI

echo "mkdir ${DIR}/ROI"
mkdir ${DIR}/ROI

for ROI in `ls $ROIDIR --hide tep_mask_pm_right_las.nii`
do

	echo "nameROI=${ROI%.*}"
	nameROI=${ROI%.*}

	echo "mincresample -like ${DIR}/mrtrix/t1_ras.mnc -invert_transformation -transformation ${DIR}/mrtrix/nl_transform/b0_to_mni.xfm ${ROIDIR}/${ROI} ${DIR}/ROI/${nameROI}_recal.mnc -short -clobber"
	mincresample -like ${DIR}/mrtrix/t1_ras.mnc -invert_transformation -transformation ${DIR}/mrtrix/nl_transform/b0_to_mni.xfm ${ROIDIR}/${ROI} ${DIR}/ROI/${nameROI}_recal.mnc -short -clobber

	echo "	mri_convert ${DIR}/ROI/${nameROI}_recal.mnc ${DIR}/ROI/${nameROI}_recal.nii"
	mri_convert ${DIR}/ROI/${nameROI}_recal.mnc ${DIR}/ROI/${nameROI}_recal.nii

	echo "	mri_binarize --i ${DIR}/ROI/${nameROI}_recal.nii --min 10 --binval 1 --o ${DIR}/ROI/${nameROI}_recal.nii"
	mri_binarize --i ${DIR}/ROI/${nameROI}_recal.nii --min 10 --binval 1 --o ${DIR}/ROI/${nameROI}_recal.nii
done
