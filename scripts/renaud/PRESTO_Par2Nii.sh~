#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name>]"
	echo ""
	echo "  -par                         : PAR file "
	echo "  -o                           : output directory "
	echo "  -n                           : output name (Default: 'presto') "
	echo ""
	echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name> ]"
	echo ""
	exit 1
fi

index=1
outname=presto

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name>]"
		echo ""
		echo "  -par                         : PAR file "
		echo "  -o                           : output directory "
		echo "  -n                           : output name (Default: 'presto') "
		echo ""
		echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name> ]"
		echo ""
		exit 1
		;;
	-par)
		index=$[$index+1]
		eval parFile=\${$index}
		echo "PAR file : $parFile"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "Output folder : ${output}"
		;;
	-n)
		index=$[$index+1]
		eval outname=\${$index}
		echo "Output name : ${outname}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name>]"
		echo ""
		echo "  -par                         : PAR file "
		echo "  -o                           : output directory "
		echo "  -n                           : output name (Default: 'presto') "
		echo ""
		echo "Usage: PRESTO_Par2Nii.sh -par <par_file>  -o <folder>  [-n <name> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ -z ${parFile} ]
then
	 echo "-par argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ ! -d ${output}/tmp ]
then
    mkdir -p ${output}/tmp
fi

## Processing
#echo "PRESTO_Par2Nii(${parFile},${output},'${outname}');"
matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);

addpath(genpath('/home/notorious/NAS/renaud/scripts/NeuroElf_v09c'))

% Convert PAR to NIFTI
PRESTO_Par2Nii('${parFile}','${output}','${outname}');

EOF

fslmerge -t ${output}/${outname}.nii.gz ${output}/tmp/opresto_*.img

rm -rf ${output}/tmp

