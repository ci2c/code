#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
	echo ""
	echo "	-i	: input mean PET file"
	echo " 	-fx	: flip to apply along the x direction"
	echo " 	-fy	: flip to apply along the y direction"
	echo " 	-fz	: flip to apply along the z direction"
	echo ""
	echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
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
		echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
		echo ""
		echo "	-i	: input mean PET file"
		echo " 	-fx	: flip to apply along the x direction"
		echo " 	-fy	: flip to apply along the y direction"
		echo " 	-fz	: flip to apply along the z direction"
		echo ""
		echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval inputfile=\${$index}
		echo "mean PET file : $inputfile"
		;;
	-fx)
		index=$[$index+1]
		eval FX=\${$index}
		echo "flip to apply along the x direction : ${FX}"
		;;
	-fy)
		index=$[$index+1]
		eval FY=\${$index}
		echo "flip to apply along the y direction : ${FY}"
		;;
	-fz)
		index=$[$index+1]
		eval FZ=\${$index}
		echo "flip to apply along the z direction : ${FZ}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
		echo ""
		echo "	-i	: input mean PET file"
		echo " 	-fx	: flip to apply along the x direction"
		echo " 	-fy	: flip to apply along the y direction"
		echo " 	-fz	: flip to apply along the z direction"
		echo ""
		echo "Usage: SPM12_FlipPet.sh -i <inputfile> -fx <flipx> -fy <flipy> -fz <flipz>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${inputfile} ]
then
	 echo "-i argument mandatory"
	 exit 1
elif [ -z ${FX} ]
then
	 echo "-fx argument mandatory"
	 exit 1
elif [ -z ${FY} ]
then
	 echo "-fy argument mandatory"
	 exit 1
elif [ -z ${FZ} ]
then
	 echo "-fz argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

FlipPet('${inputfile}',${FX},${FY},${FZ});
 
EOF
