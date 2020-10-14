#!/bin/bash

if [ $# -lt 10 ]
then
	echo ""
	echo "Usage: ComputeMeanFA.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels>  -outdir  <outputDirectory>  -pref <prefix> "
	echo ""
	echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
	echo "  -subj SubjName               : Subject ID"
	echo "  -labels Labels_list          : Path to a file containing label info "
	echo "  -outdir outputDirectory      : Output directory"
	echo "  -pref prefix                 : prefix name"
	echo " "
	echo "Usage: ComputeMeanFA.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels.txt>  -outdir  <outputDirectory>  -pref <prefix> "
	exit 1
fi

#### Inputs ####
index=1
echo "------------------------"

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: ComputeMeanFA.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels>  -outdir  <outputDirectory>  -pref <prefix> "
		echo ""
		echo "  -fs SubjDir                  : Path to FS output directory (equivalent to SUBJECTS_DIR)"
		echo "  -subj SubjName               : Subject ID"
		echo "  -labels Labels_list          : Path to a file containing label info "
		echo "  -outdir outputDirectory      : Output directory"
		echo "  -pref prefix                 : prefix name"
		echo " "
		echo "Usage: ComputeMeanFA.sh  -fs  <SubjDir>  -subj  <SubjName>  -labels <labels.txt>  -outdir  <outputDirectory>  -pref <prefix> "
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "  |-------> SubjDir : $fs"
		index=$[$index+1]
		;;
	-labels)
		LOI=`expr $index + 1`
		eval LOI=\${$LOI}
		echo "  |-------> Labels list : ${LOI}"
		index=$[$index+1]
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "  |-------> Subject Name : ${subj}"
		index=$[$index+1]
		;;
	-outdir)
		outdir=`expr $index + 1`
		eval outdir=\${$outdir}
		echo "  |-------> Output directory : ${outdir}"
		index=$[$index+1]
		;;
	-pref)
		pref=`expr $index + 1`
		eval pref=\${$pref}
		echo "  |-------> Prefix : ${pref}"
		index=$[$index+1]
		;;
	-*)
		TEMP=`expr $index`
		eval TEMP=\${$TEMP}
		echo "${TEMP} : unknown argument"
		echo ""
		echo "Enter $0 -help for help"
		exit 1
		;;
	esac
	index=$[$index+1]
done
#################


if [ ! -e ${LOI} ]
then
	echo "Can not find ${LOI}"
	exit 1
fi

if [ ! -e ${fs}/${subj} ]
then
	echo "Can not find ${fs}/${subj} directory"
	exit 1
fi

# Set some paths
DIR=${fs}/${subj}/
SUBJECTS_DIR=${fs}

# Creates output dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

echo "cd ${DIR}/dti/mrtrix"
cd ${DIR}/dti/mrtrix

# LOI mask
echo "mri_extract_label `cat ${LOI}` ${outdir}/${pref}_${subj}_mask.nii"
mri_extract_label `cat ${LOI}` ${outdir}/${pref}_${subj}_mask.nii

# Import all .mnc file
matlab -nodisplay <<EOF

  [moy,stdev]=MeanFA_OneRoi('${DIR}/dti/mrtrix/fa.nii','${outdir}/${pref}_${subj}_mask.nii');
  save('${outdir}/${pref}_${subj}_mean.mat','moy','stdev');
  
EOF

