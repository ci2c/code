#!/bin/bash

DIR=$1

mkdir $DIR/mri
dcm2nii -o $DIR/mri $DIR/*
for i in `ls $DIR/mri/*nii.gz`
do
mri_convert $i --out_type spm --out_orientation LAS $DIR/mri/T1
done
rm $DIR/mri/*gz
