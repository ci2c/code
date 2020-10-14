#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: SPM_NewSegment.sh -i <datapath> "
	echo ""
	echo "  -i        : t1 file (nifti)"
	echo ""
	echo "Usage: SPM_NewSegment.sh -i <datapath> "
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
		echo "Usage: SPM_NewSegment.sh -i <datapath> "
		echo ""
		echo "  -i        : t1 file (nifti)"
		echo ""
		echo "Usage: SPM_NewSegment.sh -i <datapath> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "t1 file : $input"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM_NewSegment.sh -i <datapath> "
		echo ""
		echo "  -i        : t1 file (nifti)"
		echo ""
		echo "Usage: SPM_NewSegment.sh -i <datapath> "
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

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

SPM_NewSegment('${input}');
 
EOF
