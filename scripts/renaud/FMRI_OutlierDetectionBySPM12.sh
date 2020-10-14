#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path>  "
	echo ""
	echo "  -sd                           : subjects' directory "
	echo "  -subj                         : subject's name "
	echo "  -pref                         : epi prefix "
	echo "  -tr                           : TR value "
	echo "  -clusFile                     : cluster file "
	echo "  -coiFile                      : COI file "
	echo ""
	echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path> "
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
		echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path>  "
		echo ""
		echo "  -sd                           : subjects' directory "
		echo "  -subj                         : subject's name "
		echo "  -pref                         : epi prefix "
		echo "  -tr                           : TR value "
		echo "  -clusFile                     : cluster file "
		echo "  -coiFile                      : COI file "
		echo ""
		echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path> "
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval indir=\${$index}
		echo "subject's folder : ${indir}"
		;;
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "subject's name : ${subj}"
		;;
	-pref)
		index=$[$index+1]
		eval prefepi=\${$index}
		echo "epi prefix : ${prefepi}"
		;;
	-tr)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-clusFile)
		index=$[$index+1]
		eval clusF=\${$index}
		echo "cluster file : ${clusF}"
		;;
	-coiFile)
		index=$[$index+1]
		eval coiF=\${$index}
		echo "coi file : ${coiF}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path>  "
		echo ""
		echo "  -sd                           : subjects' directory "
		echo "  -subj                         : subject's name "
		echo "  -pref                         : epi prefix "
		echo "  -tr                           : TR value "
		echo "  -clusFile                     : cluster file "
		echo "  -coiFile                      : COI file "
		echo ""
		echo "Usage: FMRI_SubCorticalRegressionBySPM.sh  -sd <path>  -subj <name>  -pref <prefix>  -tr <value>  -clusFile <path>  -coiFile <path> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


if [ ! -d ${indir} ]
then
	echo "no data (group)"
	exit 1
fi

if [ ! -d ${indir}/${subj} ]
then
	echo "no data (subject)"
	exit 1
fi

if [ ! -d ${indir}/${subj}/fmri ]
then
	echo "no data (epi)"
	exit 1
fi

/usr/local/matlab11/bin/matlab -nodisplay <<EOF

	% Load Matlab Path
	
	addpath('/home/global/matlab_toolbox/spm12b');
	
	maskFile = fullfile('${indir}','${subj}','subcort.nii');
	cois = load(fullfile('${indir}','COIs.txt'));
	FMRI_SubCorticalRegression('${indir}/${subj}/fmri','${subj}','${prefepi}',maskFile,${TR},'${clusF}',cois,'${indir}/${subj}');
  
EOF
