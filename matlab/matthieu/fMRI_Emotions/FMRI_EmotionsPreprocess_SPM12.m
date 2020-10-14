function FMRI_EmotionsPreprocess_SPM12(data_path,fwhm,vox_size)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
jobs={};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = spm_select('FPList', fullfile(data_path,'spm','RawEPI'), '^epi_.*\.nii$');
a = spm_select('FPList', fullfile(data_path,'spm','Structural'), '^orig.*\.nii$');

%% REALIGN
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.realign.estwrite.data{1} = editfilenames(f,'prefix','');
jobs{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
jobs{end}.spm.spatial.realign.estwrite.eoptions.sep = 4;
jobs{end}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
jobs{end}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
jobs{end}.spm.spatial.realign.estwrite.eoptions.interp = 2;
jobs{end}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
jobs{end}.spm.spatial.realign.estwrite.eoptions.weight = '';
jobs{end}.spm.spatial.realign.estwrite.roptions.which = [2 1];
jobs{end}.spm.spatial.realign.estwrite.roptions.interp = 4;
jobs{end}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
jobs{end}.spm.spatial.realign.estwrite.roptions.mask = 1;
jobs{end}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%% COREGISTRATION
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.coreg.estimate.ref = cellstr(a);
jobs{end}.spm.spatial.coreg.estimate.source = editfilenames(f(1,:),'prefix','mean');
jobs{end}.spm.spatial.coreg.estimate.other = editfilenames(f,'prefix','r');
jobs{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
jobs{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
jobs{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
jobs{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% NORMALISATION : ESTIMATE
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.normalise.est.subj.vol = cellstr(a);
jobs{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
jobs{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
jobs{end}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
jobs{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
jobs{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
jobs{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
jobs{end}.spm.spatial.normalise.est.eoptions.samp = 3;

%% NORMALISATION : WRITE
%--------------------------------------------------------------------------

%% Normalise epi files
jobs{end+1}.spm.spatial.normalise.write.subj.def = editfilenames(a,'prefix','y_');
jobs{end}.spm.spatial.normalise.write.subj.resample = editfilenames(f,'prefix','r');
jobs{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
jobs{end}.spm.spatial.normalise.write.woptions.vox = [vox_size vox_size vox_size];
jobs{end}.spm.spatial.normalise.write.woptions.interp = 4;

%% Normalise mean epi file
jobs{end+1}.spm.spatial.normalise.write.subj.def = editfilenames(a,'prefix','y_');
jobs{end}.spm.spatial.normalise.write.subj.resample = editfilenames(f(1,:),'prefix','mean');
jobs{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
jobs{end}.spm.spatial.normalise.write.woptions.vox = [vox_size vox_size vox_size];
jobs{end}.spm.spatial.normalise.write.woptions.interp = 4;

%% SMOOTHING
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix','wr');
jobs{end}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];
jobs{end}.spm.spatial.smooth.dtype = 0;
jobs{end}.spm.spatial.smooth.im = 0;
jobs{end}.spm.spatial.smooth.prefix = 's';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(data_path,'spm','RawEPI','batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);
