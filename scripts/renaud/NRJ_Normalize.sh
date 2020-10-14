#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
	echo ""
	echo "  -i                    : Path to data "
	echo "  -Ns                   : number of sessions "
	echo ""
	echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
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
		echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -Ns                   : number of sessions "
		echo ""
		echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data : ${input}"
		;;
	-Ns)
		index=$[$index+1]
		eval Ns=\${$index}
		echo "number of sessions : ${Ns}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
		echo ""
		echo "  -i                    : Path to data "
		echo "  -Ns                   : number of sessions "
		echo ""
		echo "Usage:  NRJ_Normalize.sh  -i <data_path>  -Ns <value>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - June 6, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${Ns} ]
then
	 echo "-Ns argument mandatory"
	 exit 1
fi

## Preprocessing with SPM
matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

VoxSize=[3 3 3];
BoundingBox=[-90 -126 -72;90 90 108];
opt.IsNormalize=2;
opt.AffineRegularisationInSegmentation='mni';
opt.IsDelFilesBeforeNormalize=0;
NRJ_NormalizeOneSubject('${input}',${Ns},opt,BoundingBox,VoxSize,8);
 
EOF