#!/bin/bash

DIR=$1

#mnc2nii $DIR/3dt1.mnc $DIR/3dt1.nii
echo
echo
echo "Recalage ASL sur T1..."
echo
echo
matlab -nodisplay <<EOF >> ${DIR}/recalage_SPM.log
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
cd ${Dicom}

matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {'${DIR}/3dt1.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {'${DIR}/mean.nii,1'};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 2;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

nrun = 1;
inputs = cell(0, nrun);
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', inputs{:});
EOF

fslmaths $DIR/rmean.nii -nan $DIR/rmeancor.nii
gunzip $DIR/rmeancor.nii.gz
nii2mnc $DIR/rmeancor.nii $DIR/rmeanmnc.mnc
