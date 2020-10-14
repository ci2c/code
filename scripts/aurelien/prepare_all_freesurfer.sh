#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: .sh input_dir"
	echo "Usage spécifique données Strokdem"
	exit 1
fi

datadir=$1

count=0
total=0
for i in `ls -1 ${datadir}`
do
if [ ! -d $datadir/$i/mri ]
then
echo "freesurfer patient ${i} pas fait !"
echo "on convertit les donnees pour ${i}" 
dcm2nii -o ${datadir}/${i} ${datadir}/${i}/*
echo "qbatch -oe /home/aurelien/log_sge -N recon-all recon-all -all -sd /home/fatmike/aurelien/Strokdem/freesurfer -s ${i} -i `ls -1 /home/fatmike/aurelien/Strokdem/${i}/*gz` -force -no-isrunning -nuintensitycor-3T"
#qbatch -oe /home/aurelien/log_sge -N recon-all recon-all -all -sd /home/fatmike/aurelien/Strokdem/freesurfer -s ${i} -i `ls -1 /home/fatmike/aurelien/Strokdem/${i}/*gz` -force -no-isrunning -nuintensitycor-3T
total=$[$total+1]
else
echo "patient $i ok !!"
fi
done

echo "$total freesurfers ont été lancés"
