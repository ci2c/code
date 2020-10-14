#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
	echo ""
	echo "  -r1                    : run 1 path (.nii) "
	echo "  -r2                    : run 2 path (.nii) "
	echo "  -m1                    : motion file path for run 1 (.txt) "
	echo "  -m2                    : motion file path for run 2 (.txt) "
	echo "  -o                     : output folder "
	echo "  -marker                : marker file path (.txt) "
	echo "  -rmframe               : frame for removal (Default 3) "
	echo "  -tr                    : TR value (Default 2.4) "
	echo ""
	echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
remframe=3
TR=2.4

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
		echo ""
		echo "  -r1                    : run 1 path (.nii) "
		echo "  -r2                    : run 2 path (.nii) "
		echo "  -m1                    : motion file path for run 1 (.txt) "
		echo "  -m2                    : motion file path for run 2 (.txt) "
		echo "  -o                     : output folder "
		echo "  -marker                : marker file path (.txt) "
		echo "  -rmframe               : frame for removal (Default 3) "
		echo "  -tr                    : TR value (Default 2.4) "
		echo ""
		echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
		echo ""
		exit 1
		;;
	-r1)
		index=$[$index+1]
		eval run1=\${$index}
		echo "run 1 path : $run1"
		;;
	-r2)
		index=$[$index+1]
		eval run2=\${$index}
		echo "run 2 path : $run2"
		;;
	-m1)
		index=$[$index+1]
		eval motion1=\${$index}
		echo "motion file 1 : $motion1"
		;;
	-m2)
		index=$[$index+1]
		eval motion2=\${$index}
		echo "motion file 1 : ${motion2}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output path : $outdir"
		;;
	-marker)
		index=$[$index+1]
		eval marker=\${$index}
		echo "marker File : ${marker}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
		echo ""
		echo "  -r1                    : run 1 path (.nii) "
		echo "  -r2                    : run 2 path (.nii) "
		echo "  -m1                    : motion file path for run 1 (.txt) "
		echo "  -m2                    : motion file path for run 2 (.txt) "
		echo "  -o                     : output folder "
		echo "  -marker                : marker file path (.txt) "
		echo "  -rmframe               : frame for removal (Default 3) "
		echo "  -tr                    : TR value (Default 2.4) "
		echo ""
		echo "Usage: CODE2_ActivationSubjectLevelAnalysis_Secs.sh -r1 <run1_path>  -r2 <run2_path>  -m1 <mot1_path>  -m2 <mot2_path>  -o <path>  -marker <path>  [-rmframe <value>  -tr <value> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${run1} ]
then
	 echo "-r1 argument mandatory"
	 exit 1
fi

if [ -z ${run2} ]
then
	 echo "-r2 argument mandatory"
	 exit 1
fi

if [ -z ${motion1} ]
then
	 echo "-m1 argument mandatory"
	 exit 1
fi

if [ -z ${motion2} ]
then
	 echo "-m2 argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${marker} ]
then
	 echo "-marker argument mandatory"
	 exit 1
fi

# Output folder
echo "create out folder" 
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
else
	rm -rf ${outdir}/*
fi

# Processing...
echo "Processing..."
/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	epiFiles{1} = '${run1}';
	epiFiles{2} = '${run2}';
	motionFiles{1} = '${motion1}';
	motionFiles{2} = '${motion2}';
	'${run1}'
	'${run2}'
	'${motion1}'
	'${motion2}'
	'${marker}'
	'${outdir}'
	${TR}
	${remframe}
	CODE2_ActivationSubjectLevelAnalysis_Secs(epiFiles,motionFiles,'${outdir}','${marker}',${TR},${remframe});

EOF


