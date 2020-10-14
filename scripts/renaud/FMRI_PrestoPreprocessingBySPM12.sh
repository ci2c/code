#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
	echo ""
	echo "  -sd                           : subject's directory "
	echo "  -epi                          : epi file "
	echo "  -anat                         : T1-weighted file "
	echo "  -tr                           : TR value "
	echo "  -rem                           : frames to remove "
	echo ""
	echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
	echo ""
	exit 1
fi

index=1
TR=1
remframe=5

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
		echo ""
		echo "  -sd                           : subject's directory "
		echo "  -epi                          : epi file "
		echo "  -anat                         : T1-weighted file "
		echo "  -tr                           : TR value "
		echo "  -rem                          : frames to remove "
		echo ""
		echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval indir=\${$index}
		echo "subject's folder : ${indir}"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi file : ${epi}"
		;;
	-anat)
		index=$[$index+1]
		eval anat=\${$index}
		echo "T1 file : ${anat}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-rem)
		index=$[$index+1]
		eval remframe=\${$index}
		echo "frames to remove : ${remframe}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
		echo ""
		echo "  -sd                           : subject's directory "
		echo "  -epi                          : epi file "
		echo "  -anat                         : T1-weighted file "
		echo "  -tr                           : TR value "
		echo "  -rem                          : frames to remove "
		echo ""
		echo "Usage: FMRI_PrestoPreprocessingBySPM12.sh  -sd <path>  -epi <file>  -anat <file>  -tr <value>  -rem <value> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

if [ ! -d ${indir}/spm ]
then
	mkdir ${indir}/spm
else
	rm -rf ${indir}/spm/*
fi

fslsplit ${epi} ${indir}/spm/epi_ -t
gunzip ${indir}/spm/*.gz

for ((ind = 0; ind < ${remframe}; ind += 1))
do
	filename=`ls -1 ${indir}/spm/ | sed -ne "1p"`
	rm -f ${indir}/spm/${filename}
done

#N=$(mri_info ${epi} | grep dimensions | awk '{print $6}')
#anat=${indir}/orig.nii

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	
	addpath('/home/global/matlab_toolbox/spm12b');
	
	FMRI_PrestoPreprocessingBySPM12('${indir}/spm','epi_','${anat}');
  
EOF
