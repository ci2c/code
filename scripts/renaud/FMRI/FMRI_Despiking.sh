#!/bin/bash
set -e


if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: FMRI_Despiking.sh  -i <file>  -o <file>  "
	echo ""
	echo "  -i                : 4d fmri file (.nii.gz) "
	echo "  -o                : output 4d fmri file (.nii.gz) "
	echo ""
	echo "Usage: FMRI_Despiking.sh  -i <file>  -o <file> "
	echo ""
	exit 1
fi


#### Inputs ####
index=1
echo "------------------------"


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_Despiking.sh  -i <file>  -o <file>  "
		echo ""
		echo "  -i                : 4d fmri file (.nii.gz) "
		echo "  -o                : output 4d fmri file (.nii.gz) "
		echo ""
		echo "Usage: FMRI_Despiking.sh  -i <file>  -o <file> "
		echo ""
		exit 1
		;;
	-i)
		fmri=`expr $index + 1`
		eval fmri=\${$fmri}
		echo "  |-------> fmri file : $fmri"
		index=$[$index+1]
		;;
	-o)
		outfmri=`expr $index + 1`
		eval outfmri=\${$outfmri}
		echo "  |-------> output file : ${outfmri}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


if [ ! -f $fmri ]; then echo "no fmri data"; fi

echo ""
echo "START: FMRI_Despiking.sh"
echo ""

echo "3dDespike -overwrite -prefix ${outfmri} ${fmri}"
3dDespike -overwrite -prefix ${outfmri} ${fmri}

echo ""
echo "END: FMRI_Despiking.sh"
echo ""


