#!/bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
	echo ""
	echo "  -subj				:subject id "
	echo "  -anat				:path to t1 file"
	echo ""
	echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
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
		echo ""
		echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
		echo ""
		echo "  -subj				:subject id "
		echo "  -anat				:path to t1 file"
		echo ""
		echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "Subj id : ${subj}"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "path to T1 file : ${anat}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo ""
		echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
		echo ""
		echo "  -subj				:subject id "
		echo "  -anat				:path to t1 file"
		echo ""
		echo "Usage:  Cogphenopark_FS.sh  -subj <subject> -anat <t1_file>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2014"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${subj} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${anat} ]
then
	 echo "-s argument mandatory"
	 exit 1
fi



export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh


sd=/NAS/dumbo/protocoles/CogPhenoPark/data/$subj

if [ ! -d $sd/tmp ]
then
	echo "mkdir $sd/tmp"
	mkdir $sd/tmp
else
	rm -Rf $sd/tmp
	echo "mkdir $sd/tmp"
	mkdir $sd/tmp
fi

recon-all -all -sd $sd/tmp -subjid $subj -i $anat -nuintensitycor-3T 
recon-all -qcache -sd $sd/tmp -subjid $subj -nuintensitycor-3T 


cp -Rf $sd/tmp/$subj /NAS/dumbo/protocoles/CogPhenoPark/FS5.1/
rm -Rf $sd/tmp



