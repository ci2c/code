#!/bin/bash

pattern=$1
echo > ~/results.txt

for i in `ls -1 /mnt/sauvegarde_DICOM`
do 
dcmdump /mnt/sauvegarde_DICOM/$i/DICOMDIR > ~/temp.txt
echo $i >> ~/results.txt
grep -i $pattern ~/temp.txt >> ~/results.txt
done
