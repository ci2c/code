#!/bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  VBM_8.sh  -i <datapath>"
	echo ""
	echo "  -i				:datapath "
	echo ""
	echo "Usage:  VBM_8.sh  -i <datapath>"
	echo ""
	echo "Author: Tanguy Hamel - CHRU Lille - 2014"
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
		echo "Usage:  VBM_8.sh  -i <datapath>"
		echo ""
		echo "  -i				:datapath "
		echo ""
		echo "Usage:  VBM_8.sh  -i <datapath>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval SD=\${$index}
		echo "datapath : ${SD}"
		;;

	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  VBM_8.sh  -i <datapath>"
		echo ""
		echo "  -i				:datapath "
		echo ""
		echo "Usage:  VBM_8.sh  -i <datapath>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SD} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF

VBM_8('$SD')

EOF
