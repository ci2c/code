function FMRI_FirstLevel_SPM12(inputdir,outdir,rem_beg,sot,TR)

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
matlabbatch{end}.stats{1}.fmri_spec.timing.fmri_t = 40;
matlabbatch{end}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%--------------------------------------------------------------------------

f1 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run1'), '^epi_.*\.nii$');
f2 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run2'), '^epi_.*\.nii$');

%-----------------------------------------------------------------------
matlabbatch{end}.stats{1}.fmri_spec.sess(1).scans = editfilenames(f1,'prefix','swra');
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).name = 'words_left';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).onset = sot{1,1}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(1).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).name = 'words_right';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).onset = sot{1,2}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(2).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).name = 'nowords_left';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).onset = sot{1,3}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(3).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).name = 'nowords_right';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).onset = sot{1,4}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(4).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).name = 'damier';
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).onset = sot{1,5}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).cond(5).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(1).multi = {''};
matlabbatch{end}.stats{1}.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(1).multi_reg = cellstr(fullfile(inputdir,'spm','RawEPI','run1','art_outliers_and_movement_raepi_0005.mat'));
matlabbatch{end}.stats{1}.fmri_spec.sess(1).hpf = 128;

matlabbatch{end}.stats{1}.fmri_spec.sess(2).scans = editfilenames(f2,'prefix','swra');
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).name = 'words_left';
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).onset = sot{2,1}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(1).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).name = 'words_right';
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).onset = sot{2,2}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(2).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).name = 'nowords_left';
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).onset = sot{2,3}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(3).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).name = 'nowords_right';
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).onset = sot{2,4}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(4).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).name = 'damier';
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).onset = sot{2,5}'-rem_beg*TR;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).duration = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).tmod = 0;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).cond(5).orth = 1;
matlabbatch{end}.stats{1}.fmri_spec.sess(2).multi = {''};
matlabbatch{end}.stats{1}.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
matlabbatch{end}.stats{1}.fmri_spec.sess(2).multi_reg = cellstr(fullfile(inputdir,'spm','RawEPI','run2','art_outliers_and_movement_raepi_0005.mat'));
matlabbatch{end}.stats{1}.fmri_spec.sess(2).hpf = 128;

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
R1=load(fullfile(inputdir,'spm','RawEPI','run1','art_outliers_and_movement_raepi_0005.mat'));
R2=load(fullfile(inputdir,'spm','RawEPI','run2','art_outliers_and_movement_raepi_0005.mat'));
%----------------------------------------------------------------------------

% Definition of contrasts
matlabbatch{end}.stats{3}.con.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{end}.stats{3}.con.consess{1}.tcon.name = 'Words Left';
matlabbatch{end}.stats{3}.con.consess{1}.tcon.weights = [1 0 0 0 0 zeros(1,size(R1.R,2)) 1 0 0 0 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{2}.tcon.name = 'Words Right';
matlabbatch{end}.stats{3}.con.consess{2}.tcon.weights = [0 1 0 0 0 zeros(1,size(R1.R,2)) 0 1 0 0 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{3}.tcon.name = 'NoWords Left';
matlabbatch{end}.stats{3}.con.consess{3}.tcon.weights = [0 0 1 0 0 zeros(1,size(R1.R,2)) 0 0 1 0 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{4}.tcon.name = 'NoWords Right';
matlabbatch{end}.stats{3}.con.consess{4}.tcon.weights = [0 0 0 1 0 zeros(1,size(R1.R,2)) 0 0 0 1 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{5}.tcon.name = 'Damier';
matlabbatch{end}.stats{3}.con.consess{5}.tcon.weights = [0 0 0 0 1 zeros(1,size(R1.R,2)) 0 0 0 0 1 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{6}.tcon.name = 'Left vs Right Words';
matlabbatch{end}.stats{3}.con.consess{6}.tcon.weights = [1 -1 0 0 0 zeros(1,size(R1.R,2)) 1 -1 0 0 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{7}.tcon.name = 'Right vs Left Words';
matlabbatch{end}.stats{3}.con.consess{7}.tcon.weights = [-1 1 0 0 0 zeros(1,size(R1.R,2)) -1 1 0 0 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{8}.tcon.name = 'Left vs Right NoWords';
matlabbatch{end}.stats{3}.con.consess{8}.tcon.weights = [0 0 1 -1 0 zeros(1,size(R1.R,2)) 0 0 1 -1 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{9}.tcon.name = 'Right vs Left NoWords';
matlabbatch{end}.stats{3}.con.consess{9}.tcon.weights = [0 0 -1 1 0 zeros(1,size(R1.R,2)) 0 0 -1 1 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{10}.tcon.name = 'Left vs Right';
matlabbatch{end}.stats{3}.con.consess{10}.tcon.weights = [1 -1 1 -1 0 zeros(1,size(R1.R,2)) 1 -1 1 -1 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{end}.stats{3}.con.consess{11}.tcon.name = 'Right vs Left';
matlabbatch{end}.stats{3}.con.consess{11}.tcon.weights = [-1 1 -1 1 0 zeros(1,size(R1.R,2)) -1 1 -1 1 0 zeros(1,size(R2.R,2)) 0 0];
matlabbatch{end}.stats{3}.con.consess{11}.tcon.sessrep = 'none';
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
