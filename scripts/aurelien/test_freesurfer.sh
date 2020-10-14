#!/bin/bash

datadir=$1cd freq

ARRAY=(72H M6 M12)
count=0
while [ ${count} -le 2 ]
do
for i in `ls -1 ${datadir} --hide=freesurfer --hide=liste_strokdem.ods --hide=liste_strokdem.xls --hide=resultats_freesurfer.txt --hide=strokdem_parser.sh`
do
if [ `ls ${i}/${ARRAY[$count]} | grep -i gz$` ] && [ -d freesurfer/${i}_${ARRAY[$count]} ]
then
echo "freesurfer patient ${i} ok pour le timepoint ${ARRAY[$count]}"
else
echo "freesurfer pas fait pour le patient ${i} time point ${ARRAY[$count]}"
if [ `ls ${i}/${ARRAY[$count]} | grep -i rec&` ]
then
echo "on lance le freesurfer pour ${i} ${ARRAY[$count]}" 
fi
fi
done
count=$[$count+1]
done

