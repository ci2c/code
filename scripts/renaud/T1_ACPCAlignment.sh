#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ]  "
	echo ""
	echo "  -wd              : working directory "
	echo "  -in              : t1 file (nifti) "
	echo "  -ref             : template file (nifti) "
	echo "  -out             : output file (nifti) "
	echo "  -omat            : output transformation "
	echo "  -brainsize       : brain size (mm) "
	echo ""
	echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ] "
	echo ""
	exit 1
fi

user=`whoami`
HOME=/home/${user}
index=1
BRAINSIZE=150 # For human

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ]  "
		echo ""
		echo "  -wd              : working directory "
		echo "  -in              : t1 file (nifti) "
		echo "  -ref             : template file (nifti) "
		echo "  -out             : output file (nifti) "
		echo "  -omat            : output transformation "
		echo "  -brainsize       : brain size (mm) "
		echo ""
		echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ] "
		echo ""
		exit 1
		;;
	-wd)
		index=$[$index+1]
		eval WD=\${$index}
		echo "working directory : $WD"
		;;
	-in)
		index=$[$index+1]
		eval INPUT=\${$index}
		echo "input file : $INPUT"
		;;
	-ref)
		index=$[$index+1]
		eval REFERENCE=\${$index}
		echo "template image : $REFERENCE"
		;;
	-out)
		index=$[$index+1]
		eval OUTPUT=\${$index}
		echo "output image : $OUTPUT"
		;;
	-omat)
		index=$[$index+1]
		eval OMATRIX=\${$index}
		echo "output matrix : $OMATRIX"
		;;
	-brainsize)
		index=$[$index+1]
		eval BRAINSIZE=\${$index}
		echo "brain size : $BRAINSIZE"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ]  "
		echo ""
		echo "  -wd              : working directory "
		echo "  -in              : t1 file (nifti) "
		echo "  -ref             : template file (nifti) "
		echo "  -out             : output file (nifti) "
		echo "  -omat            : output transformation "
		echo "  -brainsize       : brain size (mm) "
		echo ""
		echo "Usage: T1_ACPCAlignment.sh  -wd <folder>  -in <image>  -ref <template>  -out <image>  -omat <file>  [-brainsize <brainsize> ] "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

# Crop the FOV
echo "robustfov -i $INPUT -m $WD/roi2full.mat -r $WD/robustroi.nii.gz $BRAINSIZE"
robustfov -i $INPUT -m $WD/roi2full.mat -r $WD/robustroi.nii.gz -b $BRAINSIZE

# Invert the matrix (to get full FOV to ROI)
convert_xfm -omat $WD/full2roi.mat -inverse $WD/roi2full.mat

# Register cropped image to MNI152 (12 DOF)
flirt -interp spline -in $WD/robustroi.nii.gz -ref $REFERENCE -omat $WD/roi2std.mat -out $WD/acpc_final.nii.gz -searchrx -30 30 -searchry -30 30 -searchrz -30 30

# Concatenate matrices to get full FOV to MNI
convert_xfm -omat $WD/full2std.mat -concat $WD/roi2std.mat $WD/full2roi.mat

# Get a 6 DOF approximation which does the ACPC alignment (AC, ACPC line, and hemispheric plane)
aff2rigid $WD/full2std.mat $OMATRIX

# Create a resampled image (ACPC aligned) using spline interpolation
applywarp --rel --interp=spline -i $INPUT -r $REFERENCE --premat=$OMATRIX -o $OUTPUT



