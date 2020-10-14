#!/bin/bash

if [ -s ~/IRMf_memoire/IRMf_cohorte.txt ]
then	
	while read SUBJECT_ID  
	do
	IOpath="/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/${SUBJECT_ID}_enc";
	cd $IOpath
	mkdir mri/masks/
	mri_extract_label mri/aparc.a2009s+aseg.mgz 17 53 1007 2007 1016 2016 1013 2013 18 54 11121 12121 11123 12123 11122 12122 mri/masks/Full.mgz
	mri_convert mri/masks/Full.mgz mri/masks/Full.nii

	#Hippocampes 17 53
	mri_extract_label mri/aparc.a2009s+aseg.mgz 17 53 mri/masks/Hippocampus.mgz
	mri_convert mri/masks/Hippocampus.mgz mri/masks/Hippocampus.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 53 mri/masks/Hippocampus_R.mgz
	mri_convert mri/masks/Hippocampus_R.mgz mri/masks/Hippocampus_R.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 17 mri/masks/Hippocampus_L.mgz
	mri_convert mri/masks/Hippocampus_L.mgz mri/masks/Hippocampus_L.nii

	#Amydales 18 54
	mri_extract_label mri/aparc.a2009s+aseg.mgz 18 54 mri/masks/Amygdala.mgz
	mri_convert mri/masks/Amygdala.mgz mri/masks/Amygdala.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 54 mri/masks/Amygdala_R.mgz
	mri_convert mri/masks/Amygdala_R.mgz mri/masks/Amygdala_R.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 18 mri/masks/Amygdala_L.mgz
	mri_convert mri/masks/Amygdala_L.mgz mri/masks/Amygdala_L.nii

	#Fusiform 1007 2007 11121 12121
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1007 2007 11121 12121 mri/masks/Fusiform.mgz
	mri_convert mri/masks/Fusiform.mgz mri/masks/Fusiform.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 2007 12121 mri/masks/Fusiform_R.mgz
	mri_convert mri/masks/Fusiform_R.mgz mri/masks/Fusiform_R.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1007 11121 mri/masks/Fusiform_L.mgz
	mri_convert mri/masks/Fusiform_L.mgz mri/masks/Fusiform_L.nii

	#Parahippocampe 1016 2016 11123 12123
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1016 2016 11123 12123 mri/masks/Parahippocampal.mgz
	mri_convert mri/masks/Parahippocampal.mgz mri/masks/Parahippocampal.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 2016 12123 mri/masks/Parahippocampal_R.mgz
	mri_convert mri/masks/Parahippocampal_R.mgz mri/masks/Parahippocampal_R.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1016 11123 mri/masks/Parahippocampal_L.mgz
	mri_convert mri/masks/Parahippocampal_L.mgz mri/masks/Parahippocampal_L.nii

	#Lingual 1013 2013 11122 12122
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1013 2013 12122 11122 mri/masks/Lingual.mgz
	mri_convert mri/masks/Lingual.mgz mri/masks/Lingual.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 2013 12122 mri/masks/Lingual_R.mgz
	mri_convert mri/masks/Lingual_R.mgz mri/masks/Lingual_R.nii
	mri_extract_label mri/aparc.a2009s+aseg.mgz 1013 11122 mri/masks/Lingual_L.mgz
	mri_convert mri/masks/Lingual_L.mgz mri/masks/Lingual_L.nii

	#for fileName in $IOpath/mri/masks/*.mgz
	#do
	#	structName=basename $fileName
	#	mri_convert mri/masks/$structName.mgz mri/masks/$structName.nii
	#done
	#gzip -f mri/masks/*.nii
	done < ~/IRMf_memoire/IRMf_cohorte.txt
fi
