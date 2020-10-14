#!/bin/bash

dir=$1

for i in `ls -1 $dir --hide=fsaverage --hide=lh.EC_average --hide=rh.EC_average`
do
mri_convert $dir/$i/mri/T1.mgz $dir/$i/mri/T1.mnc
mritoself $dir/$i/mri/T1.mnc /home/global/freesurfer/mni/share/mni_autoreg/average_305.mnc $dir/$i/mri/trans_to_tal

done
