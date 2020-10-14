function Coregister_PET_MRI(InRefImg,InSrcImg)

% Init of spm_jobman
spm_jobman('initcfg'); % SPM8 only

matlabbatch{1}.spm.spatial.coreg.estimate.ref = {InRefImg};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {InSrcImg};
matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

fprintf('Coregister_PET_MRI Setup: OK');
fprintf('\n')

spm('defaults', 'PET');
spm_jobman('run',matlabbatch);