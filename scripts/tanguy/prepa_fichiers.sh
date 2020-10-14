#! /bin/bash

if [ $# -lt 4 ]
then
		echo ""
		echo "Usage: prepa_fichiers.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
		echo ""
		echo " -sd				: Subjects Dir : directory containing the patient folder"
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo "Usage: prepa_fichiers.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
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
		echo "Usage: prepa_fichiers.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
		echo ""
		echo " -sd				: Subjects Dir : directory containing the patient folder"
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo "Usage: prepa_fichiers.sh -sd <SUBJECTS_DIR> -subj <SUBJ> "
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

	
	esac
	index=$[$index+1]
done



/home/fatmike/guillaume/data/Freesurfer/nom_du_sujet/mri

echo "mri_convert $SD/$SUBJ/mri/T1.mgz $SD/$SUBJ/mri/T1orient.nii --out_orientation RAS"
mri_convert $SD/$SUBJ/mri/T1.mgz $SD/$SUBJ/mri/T1orient.nii --out_orientation RAS

echo "mri_convert $SD/$SUBJ/mri/T2first.nii $SD/$SUBJ/mri/T2first_ras.nii --out_orientation RAS"
mri_convert $SD/$SUBJ/mri/T2first.nii $SD/$SUBJ/mri/T2first_ras.nii --out_orientation RAS

echo "nii2mnc $SD/$SUBJ/mri/T1orient.nii $SD/$SUBJ/mri/T1orient.mnc"
nii2mnc $SD/$SUBJ/mri/T1orient.nii $SD/$SUBJ/mri/T1orient.mnc

echo "nii2mnc $SD/$SUBJ/mri/T2first_ras.nii $SD/$SUBJ/mri/T2first_ras.mnc"
nii2mnc $SD/$SUBJ/mri/T2first_ras.nii $SD/$SUBJ/mri/T2first_ras.mnc

echo "nii2mnc $SD/$SUBJ/mri/3DT2map.nii $SD/$SUBJ/mri/3DT2map.mnc"
nii2mnc $SD/$SUBJ/mri/3DT2map.nii $SD/$SUBJ/mri/3DT2map.mnc







