function T_ResliceROI(datapath,roilist,roidir)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','PET');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch

matlabbatch{1}.spm.spatial.coreg.write.ref             = {fullfile(datapath,'T1_ref.nii,1')};
for k = 1:length(roilist)
    matlabbatch{1}.spm.spatial.coreg.write.source{k,1} = fullfile(roidir,roilist{k});
end
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask   = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);