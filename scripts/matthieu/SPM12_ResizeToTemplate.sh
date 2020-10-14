#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
	echo ""
	echo "	-o	: output subject directory"
	echo " 	-rx	: resize to apply along the x direction"
	echo " 	-ry	: resize to apply along the y direction"
	echo " 	-rz	: resize to apply along the z direction"
	echo ""
	echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
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
		echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		echo "	-o	: output subject directory"
		echo " 	-rx	: resize to apply along the x direction"
		echo " 	-ry	: resize to apply along the y direction"
		echo " 	-rz	: resize to apply along the z direction"
		echo ""
		echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		exit 1
		;;
	-o)
		index=$[$index+1]
		eval OUTSUBJDIR=\${$index}
		echo "mean PET file : ${OUTSUBJDIR}"
		;;
	-rx)
		index=$[$index+1]
		eval RX=\${$index}
		echo "resize to apply along the x direction : ${RX}"
		;;
	-ry)
		index=$[$index+1]
		eval RY=\${$index}
		echo "resize to apply along the y direction : ${RY}"
		;;
	-rz)
		index=$[$index+1]
		eval RZ=\${$index}
		echo "resize to apply along the z direction : ${RZ}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		echo "	-o	: output subject directory"
		echo " 	-rx	: resize to apply along the x direction"
		echo " 	-ry	: resize to apply along the y direction"
		echo " 	-rz	: resize to apply along the z direction"
		echo ""
		echo "Usage: SPM12_ResizeToTemplate.sh -o <outputsubjdir> -rx <resize_x> -ry <resize_y> -rz <resize_z>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${OUTSUBJDIR} ]
then
	 echo "-o argument mandatory"
	 exit 1
elif [ -z ${RX} ]
then
	 echo "-rx argument mandatory"
	 exit 1
elif [ -z ${RY} ]
then
	 echo "-ry argument mandatory"
	 exit 1
elif [ -z ${RZ} ]
then
	 echo "-rz argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

ResizeToTemplate('${OUTSUBJDIR}',${RX},${RY},${RZ});

EOF
