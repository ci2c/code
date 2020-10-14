function CoregROIOnEPI(datapath)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

%spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
cd(fullfile(datapath,'mri'));

%% Select scans
%--------------------------------------------------------------------------
trg = spm_select('FPList', datapath,'^af.*\.nii$');
mov = spm_select('FPList', fullfile(datapath,'mri'), 'T1.nii');
roi = spm_select('FPList', fullfile(datapath,'mri'), 'V1.nii');

%% New segment

matlabbatch{1}.spm.spatial.coreg.estwrite.ref               = cellstr(trg(1,:));
matlabbatch{1}.spm.spatial.coreg.estwrite.source            = cellstr(mov(1,:));
matlabbatch{1}.spm.spatial.coreg.estwrite.other             = cellstr(roi(1,:));
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm     = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp   = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   = 'cor';

%% RUN
%save(fullfile(data_path,'processing.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);