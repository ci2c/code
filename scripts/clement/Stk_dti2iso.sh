#!/bin/bash

dir=/NAS/tupac/protocoles/Strokdem/par

for f in $dir/*
do

f2=`basename $f`

diff=$(ls -d /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/dwi_b_0001.nii.gz 2>/dev/null | wc -l )

if [ $diff -eq 0 ]; then
	mkdir /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/
	DTI_dir_test=$(ls -d ${f}/${f2}_72H/*DTI*dir*/ 2> /dev/null | wc -l)
	if [ $DTI_dir_test -gt 0 ]; then
		DTI_DIR=$(ls -d ${f}/${f2}_72H/*DTI*dir*/ 2> /dev/null)

		echo "dti2iso.sh -i $DTI_DIR* -o /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/ -s $f2"
		cd /home/clement
		dti2iso.sh -i $DTI_DIR* -o /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/ -s dwi_b_0001.nii.gz
		echo "mv /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/ISO_${f2}.nii.gz /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/dwi_b_001.nii.gz"
		mv /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/ISO_${f2}.nii.gz /NAS/tupac/protocoles/Strokdem/Lesions/72H/${f2}_72H/dwi_b_001.nii.gz
	fi
fi


done
