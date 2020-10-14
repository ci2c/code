#!/bin/bash

#La suite serait mieux mais ne fonctionne pas dans l'état.
#$1 le T1 bien defini
#$2 le real_gre
#$3 le fichier à recaler

R2=$3

newMag=`dirname $2`/r`basename $2`
cp $2 $newMag
gunzip $newMag

newR2=`dirname $3`/r`basename $3`
cp $3 $newR2
gunzip $newR2

CMD="
	% Load Matlab Path
	restoredefaultpath
	addpath('/home/global/matlab_toolbox/spm12/')
	addpath('/home/global/freesurfer6_0/fsfast/toolbox/')
	%addpath(genpath('/home/global/freesurfer6_0/'))

	% spm path
	t = which('spm');
	t = dirname(t);

	spm_get_defaults;
	spm_jobman('initcfg');
	matlabbatch = {};

	% Coregister ECHO -> T1
	matlabbatch{end+1}.spm.spatial.coreg.estimate.ref             = cellstr('$1');
	matlabbatch{end}.spm.spatial.coreg.estimate.source            = cellstr('${newMag::-3}');
	matlabbatch{end}.spm.spatial.coreg.estimate.other             = {'${newR2::-3},1'};
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

	matlabbatch{end+1}.spm.spatial.normalise.estwrite.subj.vol = {'$1,1'};
	matlabbatch{end}.spm.spatial.normalise.estwrite.subj.resample = {'${newR2::-3},1'};
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
	matlabbatch{end}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
	matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.vox = [1 1 1];
	matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.interp = 4;
	matlabbatch{end}.spm.spatial.normalise.estwrite.woptions.prefix = 'w';
	spm_jobman('run',matlabbatch);"

echo ${CMD}

matlab -nodisplay <<EOF
${CMD}
EOF

rm ${newMag::-3}
#rm ${newR2::-3}

exit $?
	% Normalize T1 into MNI
	matlabbatch{end+1}.spm.spatial.normalise.est.subj.vol = cellstr('$1');
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.tpm = {[t '/tpm/TPM.nii']};
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
	matlabbatch{end}.spm.spatial.normalise.est.eoptions.samp = 3;

	% Write QSM into MNI
	matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr('${2}');
	matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = {'${R2::-3},1'};
	matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
	matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [1 1 1];
	matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
	matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix = 'w';

exit $?

#$1 le real_gre
#$2 le fichier à recaler
R2=$2
gunzip ${R2}
CMD="   
	spm('defaults', 'FMRI');
	spm_jobman('initcfg');
	matlabbatch={};
	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.vol = {'$1,1'};
	matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {'${R2::-3},1'};
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
	matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70; 78 76 85];
	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.vox = [1 1 1];
	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.interp = 4;
	matlabbatch{1}.spm.spatial.normalise.estwrite.woptions.prefix = 'N';
	spm_jobman('run',matlabbatch);"

echo ${CMD}
matlab -nodisplay <<EOF
${CMD}
EOF

gzip ${R2::-3}

