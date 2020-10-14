#!/bin/bash

SD=$1
subj=$2




export FREESURFER_HOME=/home/global/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh


FSdir=/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/
SD=$SD/$subj


nanat=`ls $SD/orig/t1.nii | wc -l`


if [ $nanat -eq 1 ]
then
	echo "anat=`ls $SD/orig/t1.nii`"
	anat=`ls $SD/orig/t1.nii`
	echo "anat=`basename $anat`"
	anat=`basename $anat`

else
	echo "no 3d T1 file found"
	ls $SD
	echo "paste T1 name"
	read anat
fi



recon-all -all -sd $FSdir -subjid tmp_$subj -i $SD/orig/$anat -nuintensitycor-3T 
recon-all -qcache -sd $FSdir -subjid tmp_$subj -nuintensitycor-3T 




