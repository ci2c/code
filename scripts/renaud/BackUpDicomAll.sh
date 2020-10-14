#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: BackUpDicomAll.sh -i <datapath>  -o <output>"
	echo ""
	echo "  -i            : data folder "
	echo "  -o            : output folder "
	echo ""
	echo "Usage: BackUpDicomAll.sh -i <datapath>"
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
		echo "Usage: BackUpDicomAll.sh -i <datapath>  -o <output>"
		echo ""
		echo "  -i            : data folder "
		echo "  -o            : output folder "
		echo ""
		echo "Usage: BackUpDicomAll.sh -i <datapath>  -o <output>"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "data folder : ${input}"
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
		echo "Usage: BackUpDicomAll.sh -i <datapath>  -o <output>"
		echo ""
		echo "  -i            : data folder "
		echo "  -o            : output folder "
		echo ""
		echo "Usage: BackUpDicomAll.sh -i <datapath>  -o <output>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Creates out dir
if [ ! -d ${output} ]
then
	mkdir ${output}
fi

count=0
for subj in `ls -1 ${input} --hide=00_Admin`
do
	if [ ! -d ${output}/${subj} ]
	then
		#qbatch -q fs_q -oe /home/renaud/log/ -N dic${count} BackUpDicom.sh -i ${input} -f ${subj} -o ${output}
		echo "BackUpDicom.sh -i ${input} -f ${subj} -o ${output}"
		BackUpDicom.sh -i ${input} -f ${subj} -o ${output}
		count=$[$count+1]
	else
		echo "backup: ${subj} already done !!"
	fi
done

