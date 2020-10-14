#!/bin/bash

datadir=$1

ARRAY=(72H M6 M12)
count=0
total=0
while [ ${count} -le 2 ]
do
for i in `ls -1 ${datadir} --hide=00_Admin --hide=jobs --hide=freesurfer --hide=asl --hide=dti --hide=spharm --hide=GPU --hide=FS5.1` 
do
if [ `ls -1 ${i}/${ARRAY[$count]} | grep -i gz$ |wc -l` -ge 1 ] && [ -d ${datadir}/FS5.1/${i}_${ARRAY[$count]} ]
then
echo "freesurfer patient ${i} ok pour le timepoint ${ARRAY[$count]}"
else
echo "freesurfer pas fait pour le patient ${i} time point ${ARRAY[$count]}"
if [ `ls ${i}/${ARRAY[$count]} | grep -i gz&` ]
then
echo "on lance le freesurfer pour ${i} ${ARRAY[$count]}" 
total=$[$total+1]
echo "qbatch -oe /home/aurelien/log_sge -N recon-all recon-all -all -sd /home/fatmike/Protocoles_3T/Strokdem/FS5.1 -s ${i}_${ARRAY[$count]} -i `ls -1 /home/fatmike/aurelien/Protocoles_3T/Strokdem/${i}/${ARRAY[$count]}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields"
qbatch -oe /home/aurelien/log_sge -N recon-all recon-all -all -sd /home/fatmike/Protocoles_3T/Strokdem/FS5.1 -s ${i}_${ARRAY[$count]} -i `ls -1 /home/fatmike/Protocoles_3T/Strokdem/${i}/${ARRAY[$count]}/*gz` -no-isrunning -nuintensitycor-3T -hippo-subfields
fi
fi
done
count=$[$count+1]
done
echo "il y en a $total a faire"

#for script in `ls -1 ${datadir}/jobs/*`
#do
#echo "submitting job $script"
#qsub -S /bin/bash -j y -q fs_q -o ${datadir}/jobs $script
#done
