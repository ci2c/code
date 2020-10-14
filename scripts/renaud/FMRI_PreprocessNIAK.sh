#! /bin/bash

if [ $# -lt 14 ]
then
	echo ""
	echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
	echo ""
	echo "  -sd                          : Path to subjects "
	echo "  -subj                        : subject name (need file: fmri/EPI.nii)"
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of slices "
	echo "  -a                           : type of acquisition (interleaved or ascending) "
	echo "  -fwhm                        : smoothing value "
	echo "  -o                           : output folder "
	echo ""
	echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jun 01, 2012"
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
		echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
		echo ""
		echo "  -sd                          : Path to subjects "
		echo "  -subj                        : subject name "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -a                           : type of acquisition (interleaved or ascending) "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : output folder "
		echo ""
		echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jun 01, 2012"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval DIR=\${$index}
		echo "subject's path : ${DIR}"
		;;
	-subj)
		index=$[$index+1]
		eval subj=\${$index}
		echo "subject's name : ${subj}"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-a)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "type of acquisition : ${acquis}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "smoothing value : ${fwhm}"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : ${output}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
		echo ""
		echo "  -sd                          : Path to subjects "
		echo "  -subj                        : subject name "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -a                           : type of acquisition (interleaved or ascending) "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : output folder "
		echo ""
		echo "Usage:  FMRI_PreprocessNIAK.sh  -sd <subj_dir>  -subj <name>  -TR <value>  -N <value>  -a <name>  -fwhm <value>  -o <output> "
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jun 01, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${DIR} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${subj} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${TR} ]
then
	 echo "-TR argument mandatory"
	 exit 1
fi

if [ -z ${N} ]
then
	 echo "-N argument mandatory"
	 exit 1
fi

if [ -z ${acquis} ]
then
	 echo "-a argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

## Creates out dir
if [ -d ${DIR}/${subj}/fmri/${output} ]
then
	rm -rf ${DIR}/${subj}/fmri/${output}
fi

mkdir ${DIR}/${subj}/fmri/${output}
mkdir ${DIR}/${subj}/fmri/${output}/fmri
mkdir ${DIR}/${subj}/fmri/${output}/anat
mkdir ${DIR}/${subj}/fmri/${output}/output

nii2mnc ${DIR}/${subj}/fmri/EPI.nii ${DIR}/${subj}/fmri/${output}/fmri/epi.mnc
mri_convert ${DIR}/${subj}/mri/orig.mgz ${DIR}/${subj}/fmri/${output}/anat/orig.nii --out_orientation RAS
nii2mnc ${DIR}/${subj}/fmri/${output}/anat/orig.nii ${DIR}/${subj}/fmri/${output}/anat/orig.mnc

matlab -nodisplay <<EOF
% Load Matlab Path
cd /home/renaud/
p = pathdef;
addpath(p);
addpath(genpath('/home/renaud/matlab/niak-0.6.4.1'));

opt.nslices=${N};
opt.tr=${TR};
FMRI_NiakPreprocess('${DIR}/${subj}/fmri/${output}','/home/renaud/matlab/niak-0.6.4.1','${acquis}',${fwhm},opt);
 
EOF

