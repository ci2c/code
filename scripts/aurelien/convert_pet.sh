#!/bin/bash

DIR=$1

mkdir $DIR/pet
dcm2nii -o $DIR/pet $DIR/*
nb=`ls -1 $DIR/pet/*gz |wc -l`
count=1
for i in `ls $DIR/pet/*nii.gz`
do
new=`echo "$nb-$count+1"|bc`
j=$(printf "%.4d" $new)
mv $i $DIR/pet/pet_$j.nii.gz
echo "rename : $i >> pet_$j.nii.gz"
count=$[$count+1]
done

fslmerge -z $DIR/pet/PET.nii.gz $DIR/pet/*gz
mri_convert $DIR/pet/PET.nii.gz --out_type spm --out_orientation LAS $DIR/pet/PET
rm $DIR/pet/*gz
echo
