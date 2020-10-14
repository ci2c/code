#! /bin/bash

FSdir=/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask
directory=/NAS/tupac/protocoles/Strokdem/temp/CA4

for f in $FSdir/*
do
	subj=`basename $f`
	subjid=${subj:0: ( ${#subj}-3 ) }


	if [ -d ${FSdir}/${subjid}_M6 ]
	then
		echo "${subjid}_CA1_left.nii"
		mri_binarize --i ${FSdir}/${subjid}_M6/mri/posterior_right_CA4-DG.mgz --o ${directory}/${subjid}_CA4.nii --min 30 >> /dev/null #Binarize
		mri_convert ${directory}/${subjid}_CA4.nii ${directory}/${subjid}_CA4.nii --voxsize 1.000 1.000 1.000 >> /dev/null #Change la taille des voxels (par défaut 0.5)
	fi
done

