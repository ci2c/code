function FMRI_RegressCovariate(epiFile,outdir,motionFile,maskBrain,maskVent,maskWM,TR)

[p,n,ext] = fileparts(epiFile);

%% TIME FILTERING

files_in = epiFile;
files_out.dc_high = fullfile(outdir,'dc_high.mat');
files_out.dc_low  = fullfile(outdir,'dc_low.mat');
files_out.filtered_data = 'gb_niak_omitted';
files_out.var_high = 'gb_niak_omitted';
files_out.var_low = 'gb_niak_omitted';
files_out.beta_high = 'gb_niak_omitted';
files_out.beta_low = 'gb_niak_omitted';
opt_filt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',TR,'hp',0.01,'lp',Inf);
niak_brick_time_filter(files_in,files_out,opt_filt);

clear files_in files_out op_filt;


%% CONFOUNDS REGRESSION

files_in.fmri = epiFile;
files_in.dc_low = fullfile(outdir,'dc_low.mat');
files_in.dc_high = fullfile(outdir,'dc_high.mat');
files_in.custom_param = 'gb_niak_omitted';
files_in.motion_param = motionFile;
files_in.mask_brain = maskBrain;
files_in.mask_vent = maskVent;
files_in.mask_wm = maskWM;

files_out.scrubbing = fullfile(outdir,'scrubbing.mat');
files_out.compcor_mask = fullfile(outdir,['compcor_mask' ext]);
files_out.confounds = fullfile(outdir,'confounds_gs.mat');
files_out.filtered_data = fullfile(outdir,[n '_cor' ext]);
files_out.qc_compcor = fullfile(outdir,['qc_compcor' ext]);
files_out.qc_slow_drift = fullfile(outdir,['qc_slowdrift' ext]);
files_out.qc_high = fullfile(outdir,['qc_high' ext]);
files_out.qc_wm = fullfile(outdir,['qc_wm' ext]);
files_out.qc_vent = fullfile(outdir,['qc_vent' ext]);
files_out.qc_motion = fullfile(outdir,['qc_motion' ext]);
files_out.qc_custom_param = 'gb_niak_omitted';
files_out.qc_gse = fullfile(outdir,['qc_gse' ext]);

opt_comp.flag_compcor = 1;
opt_comp.compcor = struct();
opt_comp.nb_vol_min = 40;
opt_comp.flag_scrubbing = 0;
opt_comp.thre_fd = 0.5000;
opt_comp.flag_slow = 1;
opt_comp.flag_high = 0;
opt_comp.folder_out = [outdir '/'];
opt_comp.flag_verbose = 1;
opt_comp.flag_motion_params = 1;
opt_comp.flag_wm = 1;
opt_comp.flag_vent = 1;
opt_comp.flag_gsc = 0;
opt_comp.flag_pca_motion = 1;
opt_comp.flag_test = 0;
opt_comp.pct_var_explained = 0.9500;
     
%niak_brick_regress_confounds(files_in,files_out,opt_comp);
FMRI_RegressConfoundsByNiak(files_in,files_out,opt_comp);

