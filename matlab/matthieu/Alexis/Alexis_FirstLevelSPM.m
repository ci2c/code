function Alexis_FirstLevelSPM(inputdir,outdir,rem_beg,sot,TR)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

clear matlabbatch

nbdyn = 190;

%% SPECIFICATION
%-----------------------------------------------------------------------
matlabbatch{1}.stats{1}.fmri_spec.dir = cellstr(outdir);
matlabbatch{1}.stats{1}.fmri_spec.timing.units = 'secs';
matlabbatch{1}.stats{1}.fmri_spec.timing.RT = TR;
matlabbatch{1}.stats{1}.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.stats{1}.fmri_spec.timing.fmri_t0 = 1;

%--------------------------------------------------------------------------

f1 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run1'), '^epi_.*\.nii$');
f2 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run2'), '^epi_.*\.nii$');
f = [f1 ; f2];

%-----------------------------------------------------------------------
matlabbatch{1}.stats{1}.fmri_spec.sess.scans = editfilenames(f,'prefix','sra');

matlabbatch{1}.stats{1}.fmri_spec.sess.cond(1).name = 'words_left';
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(1).onset = [sot{1,1}' ; nbdyn*TR+sot{2,1}'] -rem_beg*TR;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(1).duration = 1;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.stats{1}.fmri_spec.sess.cond(2).name = 'words_right';
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(2).onset = [sot{1,2}' ;nbdyn*TR+sot{2,2}'] -rem_beg*TR;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(2).duration = 1;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(2).tmod = 0;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.stats{1}.fmri_spec.sess.cond(3).name = 'nowords_left';
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(3).onset = [sot{1,3}' ; nbdyn*TR+sot{2,3}'] -rem_beg*TR;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(3).duration = 1;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(3).tmod = 0;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.stats{1}.fmri_spec.sess.cond(4).name = 'nowords_right';
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(4).onset = [sot{1,4}' ; nbdyn*TR+sot{2,4}'] -rem_beg*TR;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(4).duration = 1;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(4).tmod = 0;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.stats{1}.fmri_spec.sess.cond(5).name = 'damier';
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(5).onset = [sot{1,5}' ; nbdyn*TR+sot{2,5}'] -rem_beg*TR;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(5).duration = 5;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(5).tmod = 0;
matlabbatch{1}.stats{1}.fmri_spec.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});

matlabbatch{1}.stats{1}.fmri_spec.sess.multi = {''};
matlabbatch{1}.stats{1}.fmri_spec.sess.regress = struct('name', {}, 'val', {});

MR1 = textread(fullfile(inputdir,'spm','RawEPI','run1','rp_aepi_0005.txt'),'%s','delimiter','\n');
MR2 = textread(fullfile(inputdir,'spm','RawEPI','run2','rp_aepi_0005.txt'),'%s','delimiter','\n');
MR = vertcat(MR1,MR2);
fid = fopen(fullfile(outdir,'motions.txt'),'wt');
fprintf(fid,'%s\n',MR{:});
fclose(fid);
matlabbatch{1}.stats{1}.fmri_spec.sess.multi_reg = cellstr(fullfile(outdir,'motions.txt'));

matlabbatch{1}.stats{1}.fmri_spec.sess.hpf = 128;

matlabbatch{1}.stats{1}.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.stats{1}.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.stats{1}.fmri_spec.volt = 1;
matlabbatch{1}.stats{1}.fmri_spec.global = 'None';
matlabbatch{1}.stats{1}.fmri_spec.mask = {''};
matlabbatch{1}.stats{1}.fmri_spec.cvi = 'AR(1)';

%% ESTIMATION
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.stats{2}.fmri_est.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{1}.stats{2}.fmri_est.method.Classical = 1;

%% INFERENCE
%--------------------------------------------------------------------------

% Definition of contrasts
matlabbatch{1}.stats{3}.con.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{1}.stats{3}.con.consess{1}.tcon.name = 'Words Left';
matlabbatch{1}.stats{3}.con.consess{1}.tcon.convec = [1 0 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{2}.tcon.name = 'Words Right';
matlabbatch{1}.stats{3}.con.consess{2}.tcon.convec = [0 1 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{3}.tcon.name = 'NoWords Left';
matlabbatch{1}.stats{3}.con.consess{3}.tcon.convec = [0 0 1 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{4}.tcon.name = 'NoWords Right';
matlabbatch{1}.stats{3}.con.consess{4}.tcon.convec = [0 0 0 1 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{5}.tcon.name = 'Damier';
matlabbatch{1}.stats{3}.con.consess{5}.tcon.convec = [0 0 0 0 1 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{6}.tcon.name = 'Left vs Right Words';
matlabbatch{1}.stats{3}.con.consess{6}.tcon.convec = [1 -1 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{7}.tcon.name = 'Right vs Left Words';
matlabbatch{1}.stats{3}.con.consess{7}.tcon.convec = [-1 1 0 0 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{8}.tcon.name = 'Left vs Right NoWords';
matlabbatch{1}.stats{3}.con.consess{8}.tcon.convec = [0 0 1 -1 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{9}.tcon.name = 'Right vs Left NoWords';
matlabbatch{1}.stats{3}.con.consess{9}.tcon.convec = [0 0 -1 1 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{10}.tcon.name = 'Left vs Right';
matlabbatch{1}.stats{3}.con.consess{10}.tcon.convec = [1 -1 1 -1 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.consess{11}.tcon.name = 'Right vs Left';
matlabbatch{1}.stats{3}.con.consess{11}.tcon.convec = [-1 1 -1 1 0 0 0 0 0 0 0 0];
matlabbatch{1}.stats{3}.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{1}.stats{3}.con.delete = 0;

% Results
matlabbatch{1}.stats{4}.results.spmmat = cellstr(fullfile(outdir,'SPM.mat'));
matlabbatch{1}.stats{4}.results.conspec.titlestr = 'All contrasts';
matlabbatch{1}.stats{4}.results.conspec.contrasts = Inf;
matlabbatch{1}.stats{4}.results.conspec.threshdesc = 'FWE';
matlabbatch{1}.stats{4}.results.conspec.thresh = 0.05;
matlabbatch{1}.stats{4}.results.conspec.extent = 0;
matlabbatch{1}.stats{4}.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{1}.stats{4}.results.units = 1;
matlabbatch{1}.stats{4}.results.print = true;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(outdir,'batch_analysis.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
