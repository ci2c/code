#!/bin/bash

chemin=$1

dcm2nii -o $chemin *

nb=`ls -1 $chemin/*gz |wc -l`
count=1
for i in `ls $chemin/*nii.gz`
do
new=`echo "$nb-$count+1"|bc`
j=$(printf "%.4d" $new)
mv $i $chemin/pet_$j.nii.gz
echo "rename : $i >> pet_$j.nii.gz"
count=$[$count+1]
done

fslmerge -z $chemin/PET.nii.gz $chemin/*gz
mri_convert $chemin/PET.nii.gz --out_type spm --out_orientation LAS PET
rm $chemin/*gz
echo
echo "Verifier que les coupes sont dans le bon ordre : freeview PET001.img"


