#! /bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path> -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
	echo ""
	echo "  -sp                          : Path to the data file sots_${subjects}.mat "
	echo "  -sub			      : Name of the subject "
	echo "  -id                          : Input preprocessed subject data directory "
	echo "  -TR                          : TR value "
	echo " 	-rmframe                     : frame for removal "
	echo ""
	echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path>  -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
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
		echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path> -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
		echo ""
		echo "  -sp                          : Path to the data file sots_${subjects}.mat "
		echo "  -sub			      : Name of the subject "
		echo "  -id                          : Input preprocessed subject data directory "
		echo "  -TR                          : TR value "
		echo " 	-rmframe                     : frame for removal "
		echo ""
		echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path>  -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
		echo ""
		exit 1
		;;
	-sp)
		index=$[$index+1]
		eval sot_path=\${$index}
		echo "sot_path : ${sot_path}"
		;;
	-sub)
		index=$[$index+1]
		eval subject=\${$index}
		echo "subject value : ${subject}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-rmframe)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frame for removal : ${remframe}"
		;;
	-id)
		index=$[$index+1]
		eval INDIR=\${$index}
		echo "Input preprocessed subject data directory : ${INDIR}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path> -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
		echo ""
		echo "  -sp                          : Path to the data file sots_${subjects}.mat "
		echo "  -sub			      : Name of the subject "
		echo "  -id                          : Input preprocessed subject data directory "
		echo "  -TR                          : TR value "
		echo " 	-rmframe                     : frame for removal "
		echo ""
		echo "Usage:  FMRI_FirstLevel_SPM12.sh -sp <sot_path>  -sub <subject> -id <inputdir> -TR <value> -rmframe <value>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${sot_path} ]
then
	 echo "-sp argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${remframe} ]
then
	 echo "-rmframe argument mandatory"
	 exit 1
fi

if [ -z ${INDIR} ]
then
	 echo "-id argument mandatory"
	 exit 1
fi

if [ -z ${subject} ]
then
	 echo "-sub argument mandatory"
	 exit 1
fi

## Create output directories and copy source files
if [ ! -d ${INDIR}/spm/FirstLevel ]
then
	mkdir -p ${INDIR}/spm/FirstLevel
else
	rm -rf ${INDIR}/spm/FirstLevel/*
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

subj = '${subject}';
outname = fullfile('${INDIR}','spm','FirstLevel');
load(fullfile('${sot_path}',['sots_' subj '.mat']),'sot'); 
FMRI_FirstLevel_SPM12('${INDIR}',outname,${remframe},sot,${TR});

EOF