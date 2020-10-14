#!/bin/bash

datadir=$1
total=0
for i in `ls -1 ${datadir} --hide=fsaverage --hide=rh.EC_average --hide=lh.EC_average`
do
if [ ! -f $datadir/${i}/surf/lh.thickness.fwhm0.fsaverage.mgh ]
then
echo "qcache à faire : patient ${i}"
qbatch -oe /home/aurelien/log_sge -N qcache recon-all -qcache -sd ${datadir} -s ${i} -nuintensitycor-3T -no-isrunning
total=$[$total+1]
sleep 10
else 
echo "qcache patient $i fait"
fi
done

echo "il y a $total qcache à faire"
