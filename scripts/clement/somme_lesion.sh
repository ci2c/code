#!/bin/bash

data_dir='/NAS/tupac/protocoles/Strokdem/Lesions/72H'

i=0
for f in $data_dir/*/*lesions_mni152.nii.gz
do 
	echo `basename $f` $i
	if [ -e $f ]
	then
	if [ $i -eq 0 ]
	then
		mris_calc -o tmp.nii $f add 0
	else
		mris_calc -o tmp.nii tmp.nii add $f
		
	fi
	((i++))
	fi
done
echo $i
mris_calc -o $data_dir/moyenne_lesions_72H.nii tmp.nii div $((i-1))
rm -f tmp.nii
