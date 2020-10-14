#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  Strokdem_freesurfer.sh  -i <subject> -s <string>"
	echo ""
	echo "  -i                         : subject id "
	echo "  -s                         : session (72H - M6 - M12) "
	echo ""
	echo "Usage:  Strokdem_freesurfer.sh  -i <data_path> -s <string> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jul 23, 2012"
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
		echo "Usage:  Strokdem_freesurfer.sh  -i <subject> -s <string> "
		echo ""
		echo "  -i                         : Path to data "
		echo "  -s                         : session (72H - M6 - M12) "
		echo ""
		echo "Usage:  Strokdem_freesurfer.sh  -i <subject> -s <string> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jul 23, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval subject=\${$index}
		echo "subject : ${subject}"
		;;
	-s)
		index=$[$index+1]
		eval ses=\${$index}
		echo "number of session : ${ses}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  Strokdem_freesurfer.sh  -i <subject> -s <string> "
		echo ""
		echo "  -i                         : Path to data "
		echo "  -s                         : session (72H - M6 - M12) "
		echo ""
		echo "Usage:  Strokdem_freesurfer.sh  -i <subject> -s <string> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jul 23, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${subject} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${ses} ]
then
	 echo "-s argument mandatory"
	 exit 1
fi





recon-all -all -sd /tmp -s ${subject} -i /NAS/dumbo/protocoles/cervelet/data/${subject}/t1.nii.gz -nuintensitycor-3T
cp -Rf /tmp/${subject} /NAS/dumbo/protocoles/cervelet/FS50
