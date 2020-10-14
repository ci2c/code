#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
	echo ""
	echo "  -epi        : path to EPI file (4D NIFTI file)"
	echo ""
	echo "  -roi        : path to ROI file (3D NIFTI file)"
	echo ""
	echo "  -mean       : path to mean fmri file"
	echo ""
	echo "  -o          : output directory"
	echo ""
	echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
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
		echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
		echo ""
		echo "  -epi        : path to EPI file (4D NIFTI file)"
		echo ""
		echo "  -roi        : path to ROI file (3D NIFTI file)"
		echo ""
		echo "  -mean       : path to mean fmri file"
		echo ""
		echo "  -o          : output directory"
		echo ""
		echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval EPI=\${$index}
		echo "EPI path : $EPI"
		;;
	-roi)
		index=$[$index+1]
		eval ROI=\${$index}
		echo "ROI path : $ROI"
		;;
	-mean)
		index=$[$index+1]
		eval MEAN=\${$index}
		echo "mean path : $MEAN"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output path : $output"
		;;
	-*)
		echo ""
		echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
		echo ""
		echo "  -epi        : path to EPI file (4D NIFTI file)"
		echo ""
		echo "  -roi        : path to ROI file (3D NIFTI file)"
		echo ""
		echo "  -mean       : path to mean fmri file"
		echo ""
		echo "  -o          : output directory"
		echo ""
		echo "Usage: conn_on_roi.sh -epi <EPI> -roi <ROI> -mean <MEANAFMRI> -o <OUTPUT>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


if [ -z ${EPI} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi


if [ -z ${ROI} ]
then
	 echo "-roi argument mandatory"
	 exit 1
fi


if [ -z ${MEAN} ]
then
	 echo "-mean argument mandatory"
	 exit 1
fi


if [ -z ${output} ]
then
	 echo "-output argument mandatory"
	 exit 1
fi




matlab -nodisplay <<EOF
% Load Matlab Path

conn_on_roi('$EPI','$ROI','$MEAN','$output')

EOF

