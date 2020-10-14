#!/bin/bash

if [ $# -lt 1 ]
then
	echo ""
	echo "Usage: .sh input_dir"
	echo "Usage spécifique données Strokdem"
	exit 1
fi

datadir=$1

ARRAY=(72H M6 M12)
count=0
total=0
while [ ${count} -le 2 ]
do
for i in `ls -1 ${datadir} --hide=00_Admin --hide=asl --hide=spharm --hide=freesurfer --hide=jobs --hide=dti --hide=FS5.1 --hide=GPU`
do
if [ `ls ${i}/${ARRAY[$count]} | grep -i gz$ |wc -l` -ge 1 ] && [ -d ${datadir}/FS5.1/${i}_${ARRAY[$count]} ]
then
echo "freesurfer patient ${i} ok pour le timepoint ${ARRAY[$count]}"
else
echo "freesurfer pas fait pour le patient ${i} time point ${ARRAY[$count]}"
if [ `ls ${i}/${ARRAY[$count]} | grep -i rec&` ]
then
echo "on convertit les donnees pour ${i} ${ARRAY[$count]}" 
dcm2nii -o ${datadir}/${i}/${ARRAY[$count]} ${datadir}/${i}/${ARRAY[$count]}/*
total=$[$total+1]
fi
fi
done
count=$[$count+1]
done

echo "il y en a $total a faire"
