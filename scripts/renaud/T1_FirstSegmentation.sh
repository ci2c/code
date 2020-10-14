#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path>  "
	echo ""
	echo "  -i                          : T1 file (path/.nii) "
	echo "  -o                          : output folder "
	echo ""
	echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path> "
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
		echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path>  "
		echo ""
		echo "  -i                          : T1 file (path/.nii) "
		echo "  -o                          : output folder "
		echo ""
		echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval T1=\${$index}
		echo "T1 file : ${T1}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path>  "
		echo ""
		echo "  -i                          : T1 file (path/.nii) "
		echo "  -o                          : output folder "
		echo ""
		echo "Usage: T1_FirstSegmentation.sh  -i <path>  -o <path> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${T1} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

# Create output folder
echo "Create output folder"
if [ ! -d ${output} ]
then
    mkdir ${output}
else
    rm -rf ${output}/*
fi

# Launch first
run_first_all -i ${T1} -o ${output}/subCort -d