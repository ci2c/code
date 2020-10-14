#! /bin/bash

if [ $# -lt 16 ]
then
	echo ""
	echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value> "
	echo ""
	echo "  -i                         : Path to data "
	echo "  -Ns                        : Number of session "
	echo "  -TR                        : TR value "
	echo "  -N                         : Number of components "
	echo "  -pref                      : prefix of preprocess fmri data "
	echo "  -th                        : threshold value "
	echo "  -type                      : type of threshold "
	echo "  -vox                       : minimum size of clusters "
	echo ""
	echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value> "
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
		echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  "
		echo ""
		echo "  -i                         : Path to data "
		echo "  -Ns                        : Number of session "
		echo "  -TR                        : TR value "
		echo "  -N                         : Number of components "
		echo "  -pref                      : prefix of preprocess fmri data "
		echo "  -th                        : threshold value "
		echo "  -type                      : type of threshold "
		echo "  -vox                       : minimum size of clusters "
		echo ""
		echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  "
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
	-Ns)
		index=$[$index+1]
		eval Ns=\${$index}
		echo "number of session : ${Ns}"
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
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
		echo ""
		echo "  -i                         : Path to data "
		echo "  -Ns                        : Number of session "
		echo "  -TR                        : TR value "
		echo "  -N                         : Number of components "
		echo "  -pref                      : prefix of preprocess fmri data "
		echo "  -th                        : threshold value "
		echo "  -type                      : type of threshold "
		echo "  -vox                       : minimum size of clusters "
		echo ""
		echo "Usage:  NRJ_NetworkDetByICA.sh  -i <data_path>  -Ns <value>  -TR <value>  -N <value>  -pref <name>  -th <value>  -type <name>  -vox <value>  -o <output_directory>"
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

if [ -z ${Ns} ]
then
	 echo "-Ns argument mandatory"
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

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

maskfile=fullfile('${datapath}','maskepi.nii');

NRJ_NetwDetByICA('${datapath}',maskfile,${Ns},'${prefix}',${N},${TR},${numvox},${Tval},'${Ttype}');
 
EOF