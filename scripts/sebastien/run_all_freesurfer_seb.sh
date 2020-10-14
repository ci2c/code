#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: .sh input_dir"
	echo "Usage spécifique données Strokdem"
	exit 1
fi

datadir=$1

ARRAY=(T0 T1 T2)
count=0
total=0
while [ ${count} -le 2 ]
do
for i in `ls -1 ${datadir} --hide=00_Admin --hide=asl --hide=spharm --hide=freesurfer --hide=jobs --hide=dti --hide=FS5.1 --hide=GPU`
do
if [ `ls ${datadir}/${i}/${ARRAY[$count]} | grep -i gz$ |wc -l` -ge 1 ] && [ -d ${datadir}/FS5.1/${i}_${ARRAY[$count]} ]
then
echo "freesurfer patient ${i} ok pour le timepoint ${ARRAY[$count]}"
else
echo "freesurfer pas fait pour le patient ${i} time point ${ARRAY[$count]}"
if [ `ls ${datadir}/${i}/${ARRAY[$count]} | grep -i rec&` ]
then
echo "on convertit les donnees pour ${i} ${ARRAY[$count]}" 
dcm2nii -o ${datadir}/${i}/${ARRAY[$count]} ${datadir}/${i}/${ARRAY[$count]}/*
rm -f /home/fatmike/sebastien/data/${i}/${ARRAY[$count]}/o*gz /home/fatmike/sebastien/data/${i}/${ARRAY[$count]}/co*gz
echo "qbatch -oe /home/sebastien/log_sge -N fs${i}_${ARRAY[$count]} recon-all -all -sd /home/fatmike/sebastien/FS5.1 -s ${i}_${ARRAY[$count]} -i `ls -1 /home/fatmike/sebastien/data/${i}/${ARRAY[$count]}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields"
qbatch -oe /home/sebastien/log_sge -N fs${i}_${ARRAY[$count]} recon-all -all -sd /home/fatmike/sebastien/FS5.1 -s ${i}_${ARRAY[$count]} -i `ls -1 /home/fatmike/sebastien/data/${i}/${ARRAY[$count]}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields -qcache
total=$[$total+1]
fi
fi
done
count=$[$count+1]
done

echo "il y en a $total a faire"
