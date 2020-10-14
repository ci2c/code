# !/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
	echo ""
	echo "  -ref                         : Path to reference image "
	echo "  -src                         : Path to source image "
	echo "  -in                          : Path to data "
	echo ""
	echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - May 14, 2012"
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
		echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
		echo ""
		echo "  -ref                         : Path to reference image "
		echo "  -src                         : Path to source image "
		echo "  -in                          : Path to data "
		echo ""
		echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - May 14, 2012"
		echo ""
		exit 1
		;;
	-ref)
		index=$[$index+1]
		eval refima=\${$index}
		echo "reference image : ${refima}"
		;;
	-src)
		index=$[$index+1]
		eval srcima=\${$index}
		echo "source image : ${srcima}"
		;;
	-in)
		index=$[$index+1]
		eval datapath=\${$index}
		echo "path to data : ${datapath}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
		echo ""
		echo "  -ref                         : Path to reference image "
		echo "  -src                         : Path to source image "
		echo "  -in                          : Path to data "
		echo ""
		echo "Usage:  FMRICorrection.sh  -ref <path>  -src <path>  -in <path> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - May 14, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

refpath=${datapath}/${refima}
srcpath=${datapath}/${srcima}
outpath=${datapath}/corspm.nii

# Register (only translations)
matlab -nodisplay <<EOF

% Load Matlab Path
p = pathdef;
addpath(p);
cd /home/renaud/SVN/matlab/renaud
RegisterForEPICorrect('${refpath}','${srcpath}','${outpath}');
 
EOF

# Launch correction
EPIVolumeCorrect.sh -f ${refpath} -b ${outpath} -o ${datapath} -pref corepi

