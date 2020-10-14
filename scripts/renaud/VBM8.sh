#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: VBM8.sh -i <datapath> "
	echo ""
	echo "  -i        : path"
	echo ""
	echo "Usage: VBM8.sh -i <datapath> "
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
		echo ""
		echo "Usage: VBM8.sh -i <datapath> "
		echo ""
		echo "  -i        : path"
		echo ""
		echo "Usage: VBM8.sh -i <datapath> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data path : $input"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: VBM8.sh -i <datapath> "
		echo ""
		echo "  -i        : path"
		echo ""
		echo "Usage: VBM8.sh -i <datapath> "
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

matlab -nodisplay <<EOF
% Load Matlab Path
p = pathdef;
addpath(p);

VBMWithSPM8('${input}');
 
EOF
