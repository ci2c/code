#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: CoregROIOnEPI.sh -i <SUBJECTS_DIR> "
	echo ""
	echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
	echo ""
	echo "Usage: CoregROIOnEPI.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: CoregROIOnEPI.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: CoregROIOnEPI.sh -i <SUBJECTS_DIR> "
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
		echo "Usage: CoregROIOnEPI.sh -i <SUBJECTS_DIR> "
		echo ""
		echo "  -i        : Path to data (i.e. SUBJECTS_DIR)"
		echo ""
		echo "Usage: CoregROIOnEPI.shh -i <SUBJECTS_DIR> "
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

for subj in `ls -1 ${input}`
do
	rm -f ${input}/${subj}/mri/cor*

	echo "Patient : ${subj}"
	
matlab -nodisplay <<EOF
% Load Matlab Path
cd /home/christine
addpath(genpath('/home/christine/Documents/spm8'))

CoregROIOnEPI('${input}/${subj}');
 
EOF

done


