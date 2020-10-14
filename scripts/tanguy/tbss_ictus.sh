#!/bin/bash


if [ $# -lt  ]
then
	echo ""
	echo "Usage: tbss_ictus.sh -sd <Subject DIR>"
	echo ""
	echo "	-sd 					: Subject directory"
	echo "Usage: tbss_ictus.sh -sd <Subject DIR>"
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
		echo "Usage: tbss_ictus.sh -sd <Subject DIR>"
		echo ""
		echo "	-sd 					: Subject directory"
		echo "Usage: tbss_ictus.sh -sd <Subject DIR>"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval sd=\${$index}
		echo "Subject directory : $sd"
		;;

	esac
	index=$[$index+1]
done

cd $sd

echo ""
echo ""
echo "TBSS - 1ère étape"
echo ""
echo ""

echo "tbss_1_preproc *nii.gz"
tbss_1_preproc *nii.gz


cd $sd


echo ""
echo ""
echo "TBSS - 2ème étape"
echo ""
echo ""

echo "tbss_2_reg" -T
tbss_2_reg -T