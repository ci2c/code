#!/bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: Labels_to_dti.sh path2seed path2target Subj_dir"
	echo ""
	echo ""
	exit 1
fi

# Gather args
path2seed=$1
path2target=$2
subjdir=$3

# create seed and target directories

echo  "mkdir -p ${subjdir}/dti/ROI/seed"
echo "mkdir ${subjdir}/dti/ROI/target"
mkdir -p ${subjdir}/dti/ROI/seed
mkdir ${subjdir}/dti/ROI/target


### Seed extraction
for seed in `ls ${path2seed}`
do
	seed=`basename ${seed}`
	echo "**********************************"
	echo "           seed : ${seed}"
	echo ""	
	echo "segment= `head -n1 ${path2seed}/${seed}`"
	segment=`head -n1 ${path2seed}/${seed}`
	echo "mri_extract_label ${subjdir}/mri/${segment} `tail -n1 ${path2seed}/${seed}` ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz"
	mri_extract_label ${subjdir}/mri/${segment} `tail -n1 ${path2seed}/${seed}` ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz
	echo "mri_binarize --i ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz --o ${subjdir}/dti/ROI/seed/${seed%.txt}_bin.mgz --min 0.1 --max inf"
	mri_binarize --i ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz --o ${subjdir}/dti/ROI/seed/${seed%.txt}_bin.mgz --min 0.1 --max inf
	
	rm -f ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz
	
	mv ${subjdir}/dti/ROI/seed/${seed%.txt}_bin.mgz ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz
	
	echo "mri_convert ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz ${subjdir}/dti/ROI/seed/${seed%.txt}.nii --out_orientation RAS"
	mri_convert ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz ${subjdir}/dti/ROI/seed/${seed%.txt}.nii  --out_orientation RAS
	
	echo "rm -f ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz"
	rm -f ${subjdir}/dti/ROI/seed/${seed%.txt}.mgz
	
	echo "nii2mnc ${subjdir}/dti/ROI/seed/${seed%.txt}.nii ${subjdir}/dti/ROI/seed/${seed%.txt}.mnc"
	nii2mnc ${subjdir}/dti/ROI/seed/${seed%.txt}.nii ${subjdir}/dti/ROI/seed/${seed%.txt}.mnc
	
	gunzip ${subjdir}/dti/data_corr_FA.nii.gz
	echo "nii2mnc ${subjdir}/dti/data_corr_FA.nii ${subjdir}/dti/FA.mnc"
	nii2mnc ${subjdir}/dti/data_corr_FA.nii ${subjdir}/dti/FA.mnc

	echo "mincresample -like ${subjdir}/dti/FA.mnc -transformation ${subjdir}/dti/nl_fit/source_to_target_nlin.xfm ${subjdir}/dti/ROI/seed/${seed%.txt}.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc"
	mincresample -like ${subjdir}/dti/FA.mnc -transformation ${subjdir}/dti/nl_fit/source_to_target_nlin.xfm ${subjdir}/dti/ROI/seed/${seed%.txt}.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc
	
	# echo "mnc2nii ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.nii"
	# mnc2nii ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.nii
	
	# Convert to nii
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${subjdir}/dti/ROI/seed/
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF
	
	rm -f ${subjdir}/dti/FA.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}_dti.mnc ${subjdir}/dti/ROI/seed/${seed%.txt}.mnc
	
	gzip ${subjdir}/dti/data_corr_FA.nii
	
done
	
	
### Target extraction
for target in `ls ${path2target}`
do
	target=`basename ${target}`
	echo "**********************************"
	echo "           target : ${target}"
	echo ""	
	echo "segment= `head -n1 ${path2target}/${target}`"
	segment=`head -n1 ${path2target}/${target}`
	echo "mri_extract_label ${subjdir}/mri/${segment} `tail -n1 ${path2target}/${target}` ${subjdir}/dti/ROI/target/${target%.txt}.mgz"
	mri_extract_label ${subjdir}/mri/${segment} `tail -n1 ${path2target}/${target}` ${subjdir}/dti/ROI/target/${target%.txt}.mgz
	echo "mri_binarize --i ${subjdir}/dti/ROI/target/${target%.txt}.mgz --o ${subjdir}/dti/ROI/target/${target%.txt}_bin.mgz --min 0.1 --max inf"
	mri_binarize --i ${subjdir}/dti/ROI/target/${target%.txt}.mgz --o ${subjdir}/dti/ROI/target/${target%.txt}_bin.mgz --min 0.1 --max inf
	
	rm -f ${subjdir}/dti/ROI/target/${target%.txt}.mgz
	
	mv ${subjdir}/dti/ROI/target/${target%.txt}_bin.mgz ${subjdir}/dti/ROI/target/${target%.txt}.mgz
	
	echo "mri_convert ${subjdir}/dti/ROI/target/${target%.txt}.mgz ${subjdir}/dti/ROI/target/${target%.txt}.nii --out_orientation RAS"
	mri_convert ${subjdir}/dti/ROI/target/${target%.txt}.mgz ${subjdir}/dti/ROI/target/${target%.txt}.nii --out_orientation RAS
	
	echo "rm -f ${subjdir}/dti/ROI/target/${target%.txt}.mgz"
	rm -f ${subjdir}/dti/ROI/target/${target%.txt}.mgz

	echo "nii2mnc ${subjdir}/dti/ROI/target/${target%.txt}.nii ${subjdir}/dti/ROI/target/${target%.txt}.mnc"
	nii2mnc ${subjdir}/dti/ROI/target/${target%.txt}.nii ${subjdir}/dti/ROI/target/${target%.txt}.mnc
	
	gunzip ${subjdir}/dti/data_corr_FA.nii.gz
	echo "nii2mnc ${subjdir}/dti/data_corr_FA.nii ${subjdir}/dti/FA.mnc"
	nii2mnc ${subjdir}/dti/data_corr_FA.nii ${subjdir}/dti/FA.mnc
	
	echo "mincresample -like ${subjdir}/dti/FA.mnc -transformation ${subjdir}/dti/nl_fit/source_to_target_nlin.xfm ${subjdir}/dti/ROI/target/${target%.txt}.mnc ${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc"
	mincresample -like ${subjdir}/dti/FA.mnc -transformation ${subjdir}/dti/nl_fit/source_to_target_nlin.xfm ${subjdir}/dti/ROI/target/${target%.txt}.mnc ${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc
	
	# echo "mnc2nii ${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc ${subjdir}/dti/ROI/target/${target%.txt}_dti.nii"
	# mnc2nii ${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc ${subjdir}/dti/ROI/target/${target%.txt}_dti.nii
	
# Convert to nii
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${subjdir}/dti/ROI/target/
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF
	
	rm -f ${subjdir}/dti/FA.mnc ${subjdir}/dti/ROI/target/${target%.txt}_dti.mnc ${subjdir}/dti/ROI/target/${target%.txt}.mnc
	
	gzip ${subjdir}/dti/data_corr_FA.nii
done





