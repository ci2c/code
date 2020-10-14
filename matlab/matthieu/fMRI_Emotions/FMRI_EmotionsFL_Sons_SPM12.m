function FMRI_EmotionsFL_Sons_SPM12(inputdir,outdir,rem_beg,TR)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

% nbdyn = 190;

%% SPECIFICATION
%-----------------------------------------------------------------------
matlabbatch{end+1}.stats{1}.fmri_spec.dir = cellstr(outdir);
matlabbatch{end}.stats{1}.fmri_spec.timing.units = 'secs';
matlabbatch{end}.stats{1}.fmri_spec.timing.RT = TR;
matlabbatch{end}.stats{1}.fmri_spec.timing.fmri_t = 16;
matlabbatch{end}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%--------------------------------------------------------------------------

f = spm_select('FPList', fullfile(inputdir,'spm','RawEPI'), '^epi_.*\.nii$');

%-----------------------------------------------------------------------
matlabbatch{end}.stats{1}.fmri_spec.sess(1).scans = editfilenames(f,'prefix','swr');
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).name = 'R1*';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).onset = 105-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).duration = 15;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).name = 'R2*';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).onset = 165-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).duration = 15;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).multi = {''};
matlabbatch{end}.stats{1}.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).multi_reg = cellstr(fullfile(inputdir,'spm','RawEPI','art_outliers_and_movement_repi_0003.mat'));
matlabbatch{end}.stats{1}.fmri_spec.sess(1).hpf = 128;

matlabbatch{end}.stats{1}.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{end}.stats{1}.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{end}.stats{1}.fmri_spec.volt = 1;
matlabbatch{end}.stats{1}.fmri_spec.global = 'None';
matlabbatch{end}.stats{1}.fmri_spec.mthresh = 0.8;
matlabbatch{end}.stats{1}.fmri_spec.mask = {''};
matlabbatch{end}.stats{1}.fmri_spec.cvi = 'AR(1)';

%% ESTIMATION
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{end}.stats{2}.fmri_est.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{end}.stats{2}.fmri_est.write_residuals = 0;
matlabbatch{end}.stats{2}.fmri_est.method.Classical = 1;

% %% INFERENCE
% %--------------------------------------------------------------------------

%----------------------------------------------------------------------------
R=load(fullfile(inputdir,'spm','RawEPI','art_outliers_and_movement_repi_0003.mat'));
%----------------------------------------------------------------------------

% Definition of contrasts
matlabbatch{end}.stats{3}.con.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{end}.stats{3}.con.consess{1}.tcon.name = 'R1*';
matlabbatch{end}.stats{3}.con.consess{1}.tcon.weights = [1 0 zeros(1,size(R.R,2)) 0];
matlabbatch{end}.stats{3}.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{2}.tcon.name = 'R2*';
matlabbatch{end}.stats{3}.con.consess{2}.tcon.weights = [0 1 zeros(1,size(R.R,2)) 0];
matlabbatch{end}.stats{3}.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{3}.tcon.name = 'R1*+R2*';
matlabbatch{end}.stats{3}.con.consess{3}.tcon.weights = [1 1 zeros(1,size(R.R,2)) 0];
matlabbatch{end}.stats{3}.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.delete = 0;


% Results
matlabbatch{end}.stats{4}.results.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{end}.stats{4}.results.conspec.titlestr = 'All contrasts';
matlabbatch{end}.stats{4}.results.conspec.contrasts = Inf;
matlabbatch{end}.stats{4}.results.conspec.threshdesc = 'FWE';
matlabbatch{end}.stats{4}.results.conspec.thresh = 0.05;
matlabbatch{end}.stats{4}.results.conspec.extent = 0;
matlabbatch{end}.stats{4}.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{end}.stats{4}.results.print = 'ps';
matlabbatch{end}.stats{4}.results.write.none = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(outdir,'batch_analysisFL.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
