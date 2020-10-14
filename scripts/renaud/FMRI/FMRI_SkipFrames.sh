#!/bin/bash
set -e


if [ $# -lt 6 ]
then
	echo ""
	echo "Usage: FMRI_SkipFrames.sh  -i <file>  -o <file>  -skip <number> "
	echo ""
	echo "  -i                : 4d fmri file (.nii.gz) "
	echo "  -o                : output 4d fmri file (.nii.gz) "
	echo "  -skip             : number of frames to skip "
	echo ""
	echo "Usage: FMRI_SkipFrames.sh  -i <file>  -o <file>  -skip <number> "
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
		echo "Usage: FMRI_SkipFrames.sh  -i <file>  -o <file>  -skip <number> "
		echo ""
		echo "  -i                : path to 4d fmri file (.nii.gz) "
		echo "  -o                : path to output 4d fmri file (.nii.gz) "
		echo "  -skip             : number of frames to skip "
		echo ""
		echo "Usage: FMRI_SkipFrames.sh  -i <file>  -o <file>  -skip <number> "
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
	-skip)
		skip=`expr $index + 1`
		eval skip=\${$skip}
		echo "  |-------> number of frames to skip : ${skip}"
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


echo ""
echo "START: FMRI_SkipFrames.sh"
echo ""

# Number of frames
nf=$(fslinfo ${fmri} | grep ^dim4 | awk '{print $2}')

# Discard first "skip" frames to allow for steady state stabilization of BOLD fMRI signal
if (( $skip > 0 )); then 
	echo "discarded $skip frames"
	nf=$(echo "$nf - $skip" | bc)
	echo "new number of frames: ${nf}"
	echo "fslroi ${fmri} ${outfmri} ${skip} ${nf}"
	fslroi ${fmri} ${outfmri} ${skip} ${nf}
else 
	echo "Not discarded any frames"
fi

echo ""
echo "END: FMRI_SkipFrames.sh"
echo ""

