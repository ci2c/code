#!/bin/bash

subject=$1

subjdir=`dirname ${subject}`
rm -f ${subjdir}/ws6arepi_al_nan.nii*
fslmaths ${subject} -nan ${subjdir}/ws6arepi_al_nan
if [ -d ${subjdir}/split_GIFT ]
then
    rm -rf ${subjdir}/split_GIFT/*
else
    mkdir ${subjdir}/split_GIFT
fi
fslsplit ${subjdir}/ws6arepi_al_nan ${subjdir}/split_GIFT/ws6arepi_al_nan_ -t
for frame in $(ls ${subjdir}/split_GIFT/ws6arepi_al_nan_*.nii.gz)
do
	base=`basename ${frame}`
	base=${base%.nii.gz}
	mri_convert -it nii -ot nifti1 ${frame} ${subjdir}/split_GIFT/${base}.img
done
rm -f ${subjdir}/split_GIFT/ws6arepi_al_nan_*.nii.gz