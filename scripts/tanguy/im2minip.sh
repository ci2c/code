#! /bin/bash

if [ $# -lt 6 ]
then
		echo ""
		echo "Usage: im2minip.sh -im <image> -slice <SLICE> -dir <DIRECTION>"
		echo ""
		echo " -im				: Image : raw data to compute min ip"
		echo ""
		echo " -slice				: slice thickness"
		echo ""
		echo " -dir				: direction : axial, sagittal or coronal"
		echo ""
		echo "Usage: im2minip.sh -im <image> -slice <SLICE> -dir <DIRECTION>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
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
		echo "Usage: im2minip.sh -im <image> -slice <SLICE> -dir <DIRECTION>"
		echo ""
		echo " -im				: Image : raw data to compute min ip"
		echo ""
		echo " -slice				: slice thickness"
		echo ""
		echo " -dir				: direction : axial, sagittal or coronal"
		echo ""
		echo "Usage: im2minip.sh -im <image> -slice <SLICE> -dir <DIRECTION>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-im)
		
		raw_data=`expr $index + 1`
		eval raw_data=\${$raw_data}
		echo "raw image : $raw_data"
		;;

	-slice)
		
		s=`expr $index + 1`
		eval s=\${$s}
		echo "number of slices : $s"
		;;


	-dir)
		
		direction=`expr $index + 1`
		eval direction=\${$direction}
		echo "direction : $direction"
		;;
	
	esac
	index=$[$index+1]
done


if [ ! -f $raw_data ]
then
	echo ""
	echo "cannot find the file $raw_data"
	echo ""
	exit
else
	echo "compute Min Ip for $raw_data"
fi


if [ $direction = "axial" ] || [ $direction = "sagittal" ] || [ $direction = "coronal" ] 
then
	echo "min ip will be compute in $direction direction"
else
	echo ""
	echo ""
	echo "invalide value for direction"
	echo ""
	echo "direction has to be axial, sagittal or coronal"
	echo ""
	exit
fi



matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);

im2min_ip('$raw_data',$s,'$direction') 

EOF

