#!/bin/bash

for i in `ls -1 --hide=lab --hide=fsaverage --hide=lh.EC_average --hide=rh.EC_average /home/fatmike/Protocoles_3T/Strokdem/freesurfer`
do
echo
echo "patient $i"
mkdir -p /home/fatmike/Protocoles_3T/Strokdem/FS5.1/$i/mri/orig
cp /home/fatmike/Protocoles_3T/Strokdem/freesurfer/$i/mri/orig/001.mgz /home/fatmike/Protocoles_3T/Strokdem/FS5.1/$i/mri/orig/
qbatch -oe ~/log_sge -N recon-all recon-all -all -sd /home/fatmike/Protocoles_3T/Strokdem/FS5.1 -s $i -nuintensitycor-3T -hippo-subfields
sleep 60
done
