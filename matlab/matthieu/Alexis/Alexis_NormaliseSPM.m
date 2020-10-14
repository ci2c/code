function Alexis_NormaliseSPM(inputdir,tempdir,vox_size)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

clear matlabbatch

mean_im = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run1'), '^meana.*\.nii$');
con_im = spm_select('FPList', fullfile(inputdir,'spm','FirstLevel'), '^con_.*\.img$');

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = cellstr(mean_im);
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
%%
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = [cellstr(mean_im) ; cellstr(con_im)];
%%
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = cellstr(fullfile(tempdir,'EPI.nii'));
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50
                                                             78 76 85];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [vox_size vox_size vox_size];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 3;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(inputdir,'spm','FirstLevel','batch_normalise.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
