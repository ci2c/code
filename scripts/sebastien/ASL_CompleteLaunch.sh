#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname> "
	echo ""
	echo "  -sd         : Path to SUBJECTS_DIR "
	echo "  -subj     : Subject name "
	echo ""
	echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
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
		echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname> "
		echo ""
		echo "  -sd       : Path to SUBJECTS_DIR "
		echo "  -subj     : Subject name "
		echo ""
		echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval input=\${$index}
		echo "data : ${input}"
		;;
	-subj)
		index=$[$index+1]
		eval name=\${$index}
		echo "subject name : ${name}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname> "
		echo ""
		echo "  -sd       : Path to SUBJECTS_DIR "
		echo "  -subj     : Subject name "
		echo ""
		echo "Usage:  ASL_CompleteLaunch.sh  -sd <path> -subj <patientname>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Aug 23, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${input} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

# ASL map
if [ ! -f ${input}/${name}/asl/pve_out/t1_MGRousset.hdr ]
then
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
    % Load Matlab Path
    %p = pathdef;
    %addpath(p);

    process_asl(fullfile('${input}','${name}'));
 
EOF
fi

# Map on surface
Project_ASL.sh -sd ${input} -subj ${name} -fwhm 6 8 10 12 14 16 18 20 22

