#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
	echo ""
	echo "  -i                        : 4D EPI"
	echo "  -o                        : output directory "
	echo ""
	echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
		echo ""
		echo "  -i                        : 4D EPI"
		echo "  -o                        : output directory "
		echo ""
		echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval epi=\${$index}
		echo "4d epi : $epi"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : $output"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
		echo ""
		echo "  -i                        : 4D EPI"
		echo "  -o                        : output directory "
		echo ""
		echo "Usage: NEDICA_4DNiiTo3DImg.sh -i <4dvol>  -o <path> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ ! -d ${output} ]
then
	mkdir ${output}
fi

N=$(mri_info ${epi} | grep dimensions | awk '{print $8}')

fslsplit ${epi} ${output}/epi_ -t
gunzip ${output}/*.gz
for ((ind=0; ind < ${N}; ind+=1)); do if [ $ind -lt 10 ]; then mri_convert ${output}/epi_000${ind}.nii ${output}/epi_000${ind}.img; elif [ $ind -lt 100 ]; then mri_convert ${output}/epi_00${ind}.nii ${output}/epi_00${ind}.img; else mri_convert ${output}/epi_0${ind}.nii ${output}/epi_0${ind}.img; fi; done

rm -f ${output}/*.nii
