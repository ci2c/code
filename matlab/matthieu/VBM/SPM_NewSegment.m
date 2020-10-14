function SPM_NewSegment(t1file)

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1}.spm.tools.preproc8.channel.vols     = {t1file,'1'};
matlabbatch{1}.spm.tools.preproc8.channel.biasreg  = 0.0001;
matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = 60;
matlabbatch{1}.spm.tools.preproc8.channel.write    = [1 1];

nbGauss = [2 2 2 3 4 2];
mat_native = [ones(2,2);[1 0];zeros(3,2)];
mat_warp = zeros(6,2);
[SPMPath, fileN, extn] = fileparts(which('spm.m'));

for k = 1:6
    matlabbatch{1}.spm.tools.preproc8.tissue(k).tpm{1} = fullfile(SPMPath,'toolbox','Seg',['TPM.nii',',',num2str(k)]);
    matlabbatch{1}.spm.tools.preproc8.tissue(k).ngaus  = nbGauss(k);
    matlabbatch{1}.spm.tools.preproc8.tissue(k).native = mat_native(k,:);
    matlabbatch{1}.spm.tools.preproc8.tissue(k).warped = mat_warp(k,:);
end

matlabbatch{1}.spm.tools.preproc8.warp.mrf = 0;
matlabbatch{1}.spm.tools.preproc8.warp.reg = 4;
matlabbatch{1}.spm.tools.preproc8.warp.affreg = 'mni';
matlabbatch{1}.spm.tools.preproc8.warp.samp = 3;
matlabbatch{1}.spm.tools.preproc8.warp.write = [1 1];

fprintf(['Normalize-Segment Setup: ',t1file,' OK']);
fprintf('\n');
spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);