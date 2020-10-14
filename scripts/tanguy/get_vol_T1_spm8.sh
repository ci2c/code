#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
	echo ""
	echo "  -anatpath                        : path to find file t1.nii "
	echo ""
	echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
	echo ""
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
		echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
		echo ""
		echo "  -anatpath                        : path to find file t1.nii "
		echo ""
		echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
		echo ""
		echo ""
		exit 1
		;;
	-anatpath)
		index=$[$index+1]
		eval anatpath=\${$index}
		echo "T1 data : ${anatpath}/t1.nii"
		;;
	
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
		echo ""
		echo "  -anatpath                        : path to find file t1.nii "
		echo ""
		echo "Usage:  get_vol_t1_spm_8.sh  -anatpath <ANATHPATH>"
		echo ""
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


/usr/local/matlab11/bin/matlab -nodisplay <<EOF

rmpath('/home/global/matlab_toolbox/spm12b')
addpath('/home/global/matlab_toolbox/spm8');

write_vol_t1_spm8('$anatpath')

EOF