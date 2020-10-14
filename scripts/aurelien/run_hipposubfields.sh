#!/bin/bash

datadir=$1
total=0
for i in `ls -1 ${datadir} --hide=fsaverage --hide=rh.EC_average --hide=lh.EC_average`
do
if [ ! -f $datadir/${i}/mri/posterior_Left-Hippocampus.mgz ] && [ ! -f $datadir/${i}/mri/posterior_Right-Hippocampus.mgz ]
then
echo "hippo-subfields à faire : patient ${i}"
qbatch -oe /home/aurelien/log_sge -N hippo recon-all -hippo-subfields -sd ${datadir} -s ${i}
total=$[$total+1]
sleep 10
else 
echo "hippo-subfields patient $i fait"
fi
done

echo "il y a $total hippo-subfields à faire"
