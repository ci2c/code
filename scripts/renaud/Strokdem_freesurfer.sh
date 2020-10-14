#!/bin/bash

if [ $# -lt 6 ]
then
	echo ""
	echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
	echo ""
	echo "  -i                         : T1 file "
	echo "  -subj                      : subject id "
	echo "  -s                         : session (72H - M6 - M12) "
	echo ""
	echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
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
		echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
		echo ""
		echo "  -i                         : T1 file "
		echo "  -subj                      : subject id "
		echo "  -s                         : session (72H - M6 - M12) "
		echo ""
		echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jul 23, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval input=\${$index}
		echo "T1 file : ${input}"
		;;
	-subj)
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
		echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
		echo ""
		echo "  -i                         : T1 file "
		echo "  -subj                      : subject id "
		echo "  -s                         : session (72H - M6 - M12) "
		echo ""
		echo "Usage:  Strokdem_freesurfer.sh  -i <file> -subj <subject> -s <string> "
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

echo ""
#. ~/.bashrc

echo "init_fs5.1"
#init_fs5.1

export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

echo "recon-all -all -sd /home/fatmike/Protocoles_3T/Strokdem/FS5.1 -s ${subject}_${ses} -i ${input} -no-isrunning -nuintensitycor-3T -hippo-subfields"
recon-all -all -sd /home/fatmike/Protocoles_3T/Strokdem/FS5.1 -s ${subject}_${ses} -i ${input} -no-isrunning -nuintensitycor-3T -hippo-subfields

