#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
	echo ""
	echo "  -transfo          : spm transformation file (ex : y_T1.nii)"
	echo ""
	echo "  -base	          : image to base inverse on"
	echo ""
	echo ""
	echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
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
		echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
		echo ""
		echo "  -transfo          : spm transformation file (ex : y_T1.nii)"
		echo ""
		echo "  -base	          : image to base inverse on"
		echo ""
		echo ""
		echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
		echo ""
		exit 1
		;;
	-transfo)
		index=$[$index+1]
		eval transfo=\${$index}
		echo "TRANSFO FILE : $transfo"
		;;
	-base)
		index=$[$index+1]
		eval im=\${$index}
		echo "image to base inverse on : $im"
		;;
	
	-*)
				echo ""
		echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
		echo ""
		echo "  -transfo          : spm transformation file (ex : y_T1.nii)"
		echo ""
		echo "  -base	          : image to base inverse on"
		echo ""
		echo ""
		echo "Usage: inverse_transfo_spm_12.sh -transfo <TRANSFO> -base <IM_BASE>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done
  

matlab -nodisplay <<EOF
% Load Matlab Path

inverse_transfo_spm_12('$transfo','$im');

EOF

