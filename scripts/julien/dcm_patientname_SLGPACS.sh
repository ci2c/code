#!/bin/bash

input='/NAS/tupac/backup_SLGPACS/Archives/ARCH01/lib07/Incoming/2012/05/10/'

echo 'Scanning files ...
' 


cd ${input}
cat /NAS/tupac/backup_SLGPACS/20120510_PN.txt
# Pour chaque dicom
for study in $(ls -d *)
do

echo "Study ${study}"

c_dcm=$(ls ${input}${study}/* | head -1)
PatientsName=$(dcmdump -M +P "0010,0010" ${c_dcm} | sed -e 's/.*\[\(.*\)\].*/\1/')
echo "  |_ ${PatientsName}"

echo "${study}  --> ${PatientsName}" >> /NAS/tupac/backup_SLGPACS/20120510_PN.txt
done









