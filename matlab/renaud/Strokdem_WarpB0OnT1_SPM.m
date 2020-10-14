function Strokdem_WarpB0OnT1_SPM(datapath)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

cd(datapath);

%% Select scans
%--------------------------------------------------------------------------
trg = fullfile(datapath,'orig','t1_ras.nii');
mov = fullfile(datapath,'warp','epi_0000.nii');
oth = spm_select('FPList', fullfile(datapath,'warp'),'.*\.nii$');

matlabbatch{1}.spm.spatial.coreg.estwrite.ref               = cellstr(trg);
matlabbatch{1}.spm.spatial.coreg.estwrite.source            = cellstr(mov);
matlabbatch{1}.spm.spatial.coreg.estwrite.other             = cellstr(oth);
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep      = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm     = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp   = 6;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap     = [0 1 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask     = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix   = 'r';

%% RUN
%save(fullfile(data_path,'processing.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);