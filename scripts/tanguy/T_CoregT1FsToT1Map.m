function T_CoregT1FsToT1Map(datapath,roilist,roidir)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','PET');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch

matlabbatch{1}.spm.spatial.coreg.estimate.ref    = {fullfile(datapath,'T1_ref.nii,1')};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {fullfile(datapath,'T1_fs.nii,1')};
for k = 1:length(roilist)
    matlabbatch{1}.spm.spatial.coreg.estimate.other{k,1}  = fullfile(roidir,roilist{k});
end
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);