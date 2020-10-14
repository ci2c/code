#!/bin/bash

datadir=$1

total=0
for i in `ls -1 ${datadir}` 
do
if [ `ls -1 ${datadir}/${i} | grep -i gz$ |wc -l` -ge 1 ]
then
total=$[$total+1]
echo "freesurfer patient ${i} pas ok"
echo
echo "qbatch -oe /home/aurelien/log_sge -N fs${i} recon-all -all -sd $datadir/FS -s ${i} -i `ls -1 $datadir/${i}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields"
qbatch -oe /home/aurelien/log_sge -N fs${i} recon-all -all -sd $datadir/FS -s ${i} -i `ls -1 $datadir/${i}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields
echo
sleep 60
else
echo "freesurfer fait pour le patient ${i}"
fi
done
echo "il y en a $total a faire"
