function ASL_RegisterSPM8(data_path,prefix)

%% Select ASL scans
%--------------------------------------------------------------------------
f = spm_select('FPList', data_path, ['^' prefix '.*\.nii$']);

%% REGISTER
%--------------------------------------------------------------------------

for k = 2:size(f,1)
  
    k
    
    clear matlabbatch
    matlabbatch={};
    
    spm('Defaults','fMRI');
    spm_jobman('initcfg'); % SPM8 only
    
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {f(1,:)};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {f(k,:)};
    matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
    
    spm_jobman('run',matlabbatch);
    
end