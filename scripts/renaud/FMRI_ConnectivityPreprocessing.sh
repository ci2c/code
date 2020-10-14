#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value>  "
	echo ""
	echo "  -epi                         : Path to epi data "
	echo "  -anat                        : Path to structural data "
	echo "  -TR                          : TR value "
	echo "  -fwhm                        : smoothing value "
	echo ""
	echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Nov 22, 2012"
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
		echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value>  "
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -TR                          : TR value "
		echo "  -fwhm                        : smoothing value "
		echo ""
		echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Nov 22, 2012"
		echo ""
		exit 1
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi data : ${epi}"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "anat data : ${anat}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value>  "
		echo ""
		echo "  -epi                         : Path to epi data "
		echo "  -anat                        : Path to structural data "
		echo "  -TR                          : TR value "
		echo "  -fwhm                        : smoothing value "
		echo ""
		echo "Usage:  FMRI_ConnectivityPreprocessing.sh  -epi <epi_path>  -anat <anat_path>  -TR <value>  -fwhm <value> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Nov 22, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${anat} ]
then
	 echo "-anat argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF
% Load Matlab Path
cd /home/renaud
p = pathdef;
addpath(p);

opt.tr=${TR};
opt.fwhm=${fwhm};
opt.vox=3;
opt.newseg=1;
%STEPS={'coregistration','segmentation','slicetiming','realignment','coregFunc','normalization','smoothing1','smoothing2'};
STEPS={'segmentation','slicetiming','realignment','coregFunc','smoothing1'};
FMRI_ConnectivityPreprocessing('${epi}','${anat}',opt,STEPS);

EOF
