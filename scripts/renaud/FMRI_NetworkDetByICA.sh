#! /bin/bash

if [ $# -lt 18 ]
then
	echo ""
	echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -s <subjfile>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
	echo ""
	echo "  -i                         : Path to data "
	echo "  -s                         : Subjects list (.txt) "
	echo "  -TR                        : TR value "
	echo "  -N                         : Number of components "
	echo "  -pref                      : prefix of preprocess fmri data "
	echo "  -th                        : threshold value "
	echo "  -type                      : type of threshold "
	echo "  -vox                       : minimum size of clusters "
	echo "  -o                         : Output directory "
	echo ""
	echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -f <folder>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - June 27, 2012"
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
		echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -s <subjfile>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
		echo ""
		echo "  -i                         : Path to data "
		echo "  -s                         : Subjects list (.txt) "
		echo "  -TR                        : TR value "
		echo "  -N                         : Number of components "
		echo "  -pref                      : prefix of preprocess fmri data "
		echo "  -th                        : threshold value "
		echo "  -type                      : type of threshold "
		echo "  -vox                       : minimum size of clusters "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -f <folder>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 27, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval datapath=\${$index}
		echo "data path : ${datapath}"
		;;
	-s)
		index=$[$index+1]
		eval subjfile=\${$index}
		echo "subject list : ${subjfile}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of components : ${N}"
		;;
	-pref)
		index=$[$index+1]
		eval prefix=\${$index}
		echo "prefix : ${prefix}"
		;;
	-th)
		index=$[$index+1]
		eval Tval=\${$index}
		echo "threshold value : ${Tval}"
		;;
	-type)
		index=$[$index+1]
		eval Ttype=\${$index}
		echo "type of threshold : ${Ttype}"
		;;
	-vox)
		index=$[$index+1]
		eval numvox=\${$index}
		echo "number of voxels (thresholding) : ${Nnumvox}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -s <subjfile>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
		echo ""
		echo "  -i                         : Path to data "
		echo "  -s                         : Subjects list (.txt) "
		echo "  -TR                        : TR value "
		echo "  -N                         : Number of components "
		echo "  -pref                      : prefix of preprocess fmri data "
		echo "  -th                        : threshold value "
		echo "  -type                      : type of threshold "
		echo "  -vox                       : minimum size of clusters "
		echo "  -o                           : Output directory "
		echo ""
		echo "Usage:  FMRI_NetworkDetByICA.sh  -i <data_path>  -f <folder>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 27, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${datapath} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${subjfile} ]
then
	 echo "-s argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

if [ -z ${prefix} ]
then
	 echo "-fpref argument mandatory"
	 exit 1
fi

if [ -z ${Tval} ]
then
	 echo "-th argument mandatory"
	 exit 1
fi

if [ -z ${Ttype} ]
then
	 echo "-type argument mandatory"
	 exit 1
fi

if [ -z ${numvox} ]
then
	 echo "-vox argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

opt_ned.TR=${TR};
opt_ned.Ncomp=${N};
opt_ned.threshT=${Tval};
opt_ned.Ttype='${Ttype}';
opt_ned.numvox=${numvox};

FMRI_NetworkDetByICA('${datapath}','${subjfile}','${outdir}','${prefix}',opt_ned);
 
EOF
