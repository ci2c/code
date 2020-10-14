#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
	echo ""
	echo "	-f	: input file containing paths of dicom images "
	echo ""
	echo "  -od	: output nifti file directory"
	echo ""
	echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
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
		echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
		echo ""
		echo "	-f	: input file containing paths of dicom images "
		echo ""
		echo "  -od	: output nifti file directory"
		echo ""
		echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
		echo ""
		exit 1
		;;
	-f)
		index=$[$index+1]
		eval inputfile=\${$index}
		echo "file of dicom images : $inputfile"
		;;
	-od)
		index=$[$index+1]
		eval OUTPUT_DIR=\${$index}
		echo "output nifti file directory : ${OUTPUT_DIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
		echo ""
		echo "	-f	: input file containing paths of dicom images "
		echo ""
		echo "  -od	: output nifti file directory"
		echo ""
		echo "Usage: SPM_DICOM_Convert.sh -f <inputfile> -od <outputdir>"
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
elif [ -z ${OUTPUT_DIR} ]
then
	 echo "-od argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

Dicom_convert('${OUTPUT_DIR}','${inputfile}');
 
EOF
