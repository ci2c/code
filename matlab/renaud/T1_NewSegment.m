function T1_NewSegment(t1file)

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1,1}.spm.tools.preproc8.channel.vols     = {t1file};
matlabbatch{1,1}.spm.tools.preproc8.channel.biasreg  = 0.0001;
matlabbatch{1,1}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{1,1}.spm.tools.preproc8.channel.write    = [1 1];

nbGauss = [2 2 2 3 4 2];
[SPMPath, fileN, extn] = fileparts(which('spm.m'));
outNat = [1 1; 1 1; 1 0; 0 0; 0 0; 0 0];
for k = 1:6
    matlabbatch{1,1}.spm.tools.preproc8.tissue(1,k).tpm{1,1} = fullfile(SPMPath,'toolbox','Seg',['TPM.nii',',',num2str(k)]);
    matlabbatch{1,1}.spm.tools.preproc8.tissue(1,k).ngaus    = nbGauss(k);
    matlabbatch{1,1}.spm.tools.preproc8.tissue(1,k).native   = outNat(k,:);
end

matlabbatch{1,1}.spm.tools.preproc8.warp.reg    = 4;
matlabbatch{1,1}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{1,1}.spm.tools.preproc8.warp.samp   = 3;
matlabbatch{1,1}.spm.tools.preproc8.warp.write  = [1 1];

fprintf(['Normalize-Segment Setup: ',t1file,' OK']);
fprintf('\n');
spm_jobman('run',matlabbatch);