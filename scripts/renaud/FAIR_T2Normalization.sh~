#! /bin/bash

if [ $# -lt 2 ]
then
	echo ""
	echo "Usage: FAIR_T2Normalization.sh -i <path> "
	echo ""
	echo "  -i                      : Path to data "
	echo ""
	echo "Usage: FAIR_T2Normalization.sh -i <path> "
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: FAIR_T2Normalization.sh -i <path> "
		echo ""
		echo "  -i                      : Path to data "
		echo ""
		echo "Usage: FAIR_T2Normalization.sh -i <path> "
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval indir=\${$index}
		echo "path to data : $indir"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: FAIR_T2Normalization.sh -i <path> "
		echo ""
		echo "  -i                      : Path to data "
		echo ""
		echo "Usage: FAIR_T2Normalization.sh -i <path> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

# Output folder
echo "create out folder" 
if [ ! -f ${indir}/T1.nii ]
then
	mri_convert ${indir}/T1.mnc ${indir}/T1.nii
fi

if [ ! -f ${indir}/T2maptoT1.nii ]
then
	mri_convert ${indir}/T2maptoT1.mnc ${indir}/T2maptoT1.nii
fi

# Processing...
echo "Processing..."
#/usr/local/matlab11/bin/matlab -nodisplay <<EOF
#
#	% Load Matlab Path
#	cd ${HOME}
#	p = pathdef;
#	addpath(p);
#
#	spm('Defaults','fMRI');
#	spm_jobman('initcfg'); % SPM8 only
#
#	clear matlabbatch
#	matlabbatch = {};
#
#	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol          = cellstr(fullfile('${indir}','T1.nii'));
#	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample     = cellstr(fullfile('${indir}','T2maptoT1.nii'));
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg  = 0.0001;
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm      = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg   = 'mni';
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg      = [0 0.001 0.5 0.05 0.2];
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm     = 0;
#	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp     = 3;
#	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb       = [-78 -112 -70; 78 76 85];
#	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox      = [1 1 1];
#	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp   = 4;
#
#	spm_jobman('run',matlabbatch);
#
#EOF

cd ${indir}
ANTS 3 -m  CC[/home/lucie/memoire/avg152T1.nii.gz,T1.nii,1,5] -t SyN[0.25] -r Gauss[3,0] -o T1_al -i 30x90x20 --use-Histogram-Matching  --number-of-affine-iterations 10000x10000x10000x10000x10000 --MI-option 32x16000
WarpImageMultiTransform 3 T2maptoT1.nii T2maptoT1_al.nii T1_alWarp.nii.gz T1_alAffine.txt -R /home/lucie/memoire/avg152T1.nii.gz --use-BSpline
WarpImageMultiTransform 3 T1.nii T1_al.nii T1_alWarp.nii.gz T1_alAffine.txt -R /home/lucie/memoire/avg152T1.nii.gz --use-BSpline


