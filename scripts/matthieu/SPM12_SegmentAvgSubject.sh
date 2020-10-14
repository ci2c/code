#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
	echo ""
	echo "	-d	: Input working directory "
	echo "	-subj	: Name of the subject "
	echo ""
	echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
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
		echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
		echo ""
		echo "	-d	: Input working directory "
		echo "	-subj	: Name of the subject "
		echo ""
		echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
		echo ""
		exit 1
		;;
	-d)
		index=$[$index+1]
		eval inputdir=\${$index}
		echo "Input working directory : $inputdir"
		;;
	-subj)
		index=$[$index+1]
		eval subject=\${$index}
		echo "Name of the subject : $subject"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
		echo ""
		echo "	-d	: Input working directory "
		echo "	-subj	: Name of the subject "
		echo ""
		echo "Usage: SPM12_SegmentAvgSubject.sh -d <inputdir> -subj <subject>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${inputdir} ]
then
	 echo "-d argument mandatory"
	 exit 1
fi
if [ -z ${subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

matlab -nodisplay <<EOF
	
	%% Load Matlab Path: Matlab 14 and SPM12 version
	cd ${HOME}
	p = pathdef14_SPM12;
	addpath(p);

	SegmentSubject_SPM12('${inputdir}', '${subject}');
	
EOF
