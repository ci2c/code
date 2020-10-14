#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  prep_data_ictus.sh  -sd <SD>"
	echo ""
	echo "  -sd				:SD "
	echo ""
	echo "Usage:  prep_data_ictus.sh  -sd <SD>"
	echo ""
	echo "Author: Tanguy Hamel - CHRU Lille - 2014"
	echo ""
	exit 1
fi

index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage:  prep_data_ictus.sh  -sd <SD>"
		echo ""
		echo "  -sd				:SD "
		echo ""
		echo "Usage:  prep_data_ictus.sh  -sd <SD>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval sd=\${$index}
		echo "Subj dir : ${sd}"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo ""
		echo "Usage:  prep_data_ictus.sh  -sd <SD>"
		echo ""
		echo "  -sd				:SD "
		echo ""
		echo "Usage:  prep_data_ictus.sh  -sd <SD>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

mkdir $sd/RS
mkdir $sd/DTI
mv $sd/*RESTING* $sd/RS
mv $sd/*TENSOR* $sd/DTI

for wd in RS DTI
do
echo ""
echo ""
echo ""
echo "traitement pour $wd"
echo ""
echo ""
for im in `ls $sd/$wd/*img`
do
image=${im%%.img}
echo "mri_convert $image.img $image.nii"
mri_convert $image.img $image.nii
rm -f $image.img $image.hdr
done

done

