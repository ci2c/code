#!/bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: T2map2T1.sh T2map.nii T1.nii outputfolder"
	echo ""
	echo "From multiple or single echo T2 image, create first echo image and register to T1." 
	echo "Create transform matrix in output folder"
	exit 1
fi

###  Gather args
T2map=$1
T1=$2
output=$3

# create output directory and copy files

echo  "mkdir ${output}"
mkdir ${output}


### create T2* first echo
echo "fslval ${T2map} dim4"
echo `fslval ${T2map} dim4`
if [ `fslval ${T2map} dim4` -eq 1 ]
then
	echo "cp ${T2map} ${output}/premierecho.nii.gz"
	cp ${T2map} ${output}/premierecho.nii.gz
else
	echo "cp ${T2map} ${output}/temp"
	cp ${T2map} ${output}/temp
	echo "fslroi ${output}/temp ${output}/premierecho 0 1"
	fslroi ${output}/temp ${output}/premierecho 0 1					
fi

echo "gunzip ${output}/premierecho"
gunzip ${output}/premierecho.nii.gz

echo "nii2mnc premierecho.nii"
nii2mnc ${output}/premierecho.nii ${output}/premierechomnc.mnc

### registration
echo "nii2mnc ${T1}"
nii2mnc ${T1} ${output}/T1mnc.mnc
echo "mritoself ${output}/premierechomnc.mnc ${output}/T1mnc.mnc ${output}/T2toT1.xfm"
mritoself ${output}/premierechomnc.mnc ${output}/T1mnc.mnc ${output}/T2toT1.xfm
echo "mincresample -like ${output}/T1mnc.mnc -transformation ${output}/T2toT1.xfm ${output}/premierechomnc.mnc ${output}/T2toT1.mnc"
mincresample -like ${output}/T1mnc.mnc -transformation ${output}/T2toT1.xfm ${output}/premierechomnc.mnc ${output}/T2toT1.mnc

### convert to nii (matlab)
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${output}
 
% Do the Job
matlabbatch{1}.spm.util.minc.data = {'${output}/T2toT1.mnc'};
matlabbatch{1}.spm.util.minc.opts.dtype = 4;
matlabbatch{1}.spm.util.minc.opts.ext = 'nii';
 
inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF








