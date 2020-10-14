#!/bin/bash

datadir=$1

freesurfer=$(ls -1 ${datadir}/freesurfer)
ARRAY=(72H M6 M12)
all=$(ls -1 ${datadir})
count=1
nbdos=`ls -1 ${datadir} |wc -l`
while [ ${count} -le ${nbdos} ]
do
if [ ! -d
ARRAY=(72H M6 M12)
count=0
while [ ${count} -le 2 ]
do
for i in `find ${dir} -type f -print |grep -i rec$ |grep -i ${ARRAY[$count]}`
do
dos=`find . -type f -print |grep -i ${i} |sed 's/\// /g' |awk '{print $2}'`
mkdir ${dir}/${dos}_${ARRAY[$count]}
dcm2nii -o ${dir} ${i}
done
count=$[$count+1]
done

#for dir in `find ${datadir} -type d -name ${ARRAY[$count]}`
#do
#echo "${dir}"
#if [ -f ${dir}/*REC ]
#then
#echo "rec present"
#else
#echo "rien"
#fi
#done
#count=$[$count+1]
#done
