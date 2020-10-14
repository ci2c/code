#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: ExtractWM.sh aparc2009.nii WM.nii"
	echo ""
	echo "  aparc2009.nii             : aparc.a2009s+aseg.mgz in nii format"
	echo "  WM.nii                    : white matter mask including subcortical regions excluding"
	echo "                               4th ventricle, brain stem, cerebellum in nii format"
	echo ""
	echo "Usage: ExtractWM.sh aparc2009.nii WM.nii"
	echo ""
	exit 1
fi


aparc=$1
wm=$2
outdir=`dirname ${wm}`

fslmaths ${aparc} -uthr 500 -bin ${outdir}/temp1
mri_extract_label ${aparc} 7 8 15 16 46 47 ${outdir}/temp2.nii
fslmaths ${outdir}/temp2.nii -bin ${outdir}/temp3
fslmaths ${outdir}/temp1 -sub ${outdir}/temp3 ${outdir}/temp4

gunzip -f ${outdir}/temp4.nii

mri_morphology ${outdir}/temp4.nii dilate 1 ${wm}

rm -f ${outdir}/temp1.nii.gz ${outdir}/temp2.nii ${outdir}/temp3.nii.gz ${outdir}/temp4.nii
