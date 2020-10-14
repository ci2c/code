#!/bin/bash

dir=$1

for i in $(find $dir -type f |grep -i rec$)
do
dcm2nii -o . $i
done
