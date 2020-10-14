#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
	echo ""
	echo "  -sd                          : Subject directory "
	echo ""
	echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
	echo ""
	echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 23, 2013"
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
		echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
		echo ""
		echo "  -sd                          : Subject directory "
		echo ""
		echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 23, 2013"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SDIR=\${$index}
		echo "Subject directory : ${SDIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
		echo ""
		echo "  -sd                          : Subject directory "
		echo ""
		echo "Usage:  FMRI_OutlierId_SPM12.sh  -sd <subject_dir>"
		echo ""
		echo "Author: Matthieu Vanhoutte - CHRU Lille - Oct 23, 2013"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${SDIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

FMRI_EmotionsOutlierId_Vis_SPM12('${SDIR}')

EOF