#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
	echo ""
	echo "	-f	: input file containing paths of nifti images "
	echo ""
	echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
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
		echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
		echo ""
		echo "	-f	: input file containing paths of nifti images "
		echo ""
		echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
		echo ""
		exit 1
		;;
	-f)
		index=$[$index+1]
		eval inputfile=\${$index}
		echo "file of dicom images : $inputfile"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
		echo ""
		echo "	-f	: input file containing paths of nifti images "
		echo ""
		echo "Usage: SPM_Mean_Images.sh -f <inputfile>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${inputfile} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

MeanImages('${inputfile}');
 
EOF
