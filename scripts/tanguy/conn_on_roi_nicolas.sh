#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
	echo ""
	echo "  -subj        : Subject ID"
	echo ""
	echo "  -roi        : roi name"
	echo ""
	echo ""
	echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
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
		echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
		echo ""
		echo "  -subj        : Subject ID"
		echo ""
		echo "  -roi        : roi name"
		echo ""
		echo ""
		echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "SUBJ ID : $SUBJ"
		;;
	-roi)
		index=$[$index+1]
		eval ROI=\${$index}
		echo "ROI name : $ROI"
		;;
	
	-*)
		echo ""
		echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
		echo ""
		echo "  -subj        : Subject ID"
		echo ""
		echo "  -roi        : roi name"
		echo ""
		echo ""
		echo "Usage: conn_on_roi_nicolas.sh -subj <SUBJ> -roi <ROI>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done




######
### SCRIPT SPECIFIQUE A L ETUDE DE NICOLAS
######
######
### spécificités dans la gestion des fichiers et création de dossier
######
######
### connectivité calculée par conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>
######



### init PATH & variables###

echo "raw_path=/home/tanguy/temp/Nicolas_subjects/fmri_results/${SUBJ}/SurfEPI/spm"
raw_path=/home/tanguy/NAS/nicolas/M2/fmri_results/data/${SUBJ}/SurfEPI/spm

echo "files_pattern=csvraepi"
files_pattern=csvraepi

echo "result_path=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}"
result_path=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}

echo "ROI_path=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}/fconn/seed/native"
ROI_path=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}/fconn/seed/native

echo "ROI=${ROI_path}/${ROI}"
ROI=${ROI_path}/${ROI}

echo "output=${result_path}/fconn/seed/native/conn_corsica"
output=${result_path}/fconn/seed/native/conn_corsica

echo "M=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}/fmri_12/meanafmri.nii"
M=/home/tanguy/NAS/nicolas/M2/tmp_seed12/${SUBJ}/fmri_12/meanafmri.nii




## création des dossiers

if [ ! -d ${result_path}/fmri_12 ]
then
	echo "mkdir ${result_path}/fmri_12"
	mkdir ${result_path}/fmri_12
fi

if [ ! -d ${result_path}/fconn/seed/native/conn_corsica ]
then
	echo "mkdir ${result_path}/fconn/seed/native/conn_corsica"
	mkdir ${result_path}/fconn/seed/native/conn_corsica
else
	echo "le dossier conn_corsica existe deja"
fi





## création du fichier 4D 


if [ -f ${result_path}/fmri_12/${files_pattern}.nii ]
then
	echo "rm -f ${result_path}/fmri_12/${files_pattern}.nii"
	rm -f ${result_path}/fmri_12/${files_pattern}.nii
fi


if [ ! -f ${result_path}/fmri_12/${files_pattern}.nii ]
then
	echo "fslmerge -t ${result_path}/fmri_12/${files_pattern}.nii ${raw_path}/${files_pattern}*"
	fslmerge -t ${result_path}/fmri_12/${files_pattern}.nii ${raw_path}/${files_pattern}*

	echo "gunzip ${result_path}/fmri_12/${files_pattern}.nii.gz"
	gunzip ${result_path}/fmri_12/${files_pattern}.nii.gz
else
	echo "fichier ${result_path}/fmri_12/${files_pattern}.nii déjà présent"
fi

echo "conn_on_roi.sh -epi ${result_path}/fmri_12/${files_pattern}.nii -roi $ROI -mean $M -o $result_path/fconn/seed/native/conn_corsica"

conn_on_roi.sh -epi ${result_path}/fmri_12/${files_pattern}.nii -roi $ROI -mean $M -o $result_path/fconn/seed/native/conn_corsica

