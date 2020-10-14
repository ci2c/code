function FMRI_CounfoundsDetrendingAndSmoothing(epiFiles,outdir,TR,brainMaskFile,motionFiles,ventFile,wmFile,preproc)


%% INIT

prefix      = '';

opt_pre.normalize = 1;
opt_pre.detrend   = 1;
opt_pre.filtering = 1;

if nargin < 8
    preproc.conf.do = false;
    preproc.filt.do = false;
    preproc.fwhm.do = false;
end


%% CHECK DIMENSIONS

[hdr,vol] = niak_read_vol(epiFiles{1});
dim = size(vol);
clear hdr vol;
[hdr,vol] = niak_read_vol(ventFile);
dimvent = size(vol);
clear hdr vol;
[hdr,vol] = niak_read_vol(wmFile);
dimwm = size(vol);
clear hdr vol;

if dim(1) ~= dimvent(1) || dim(2) ~= dimvent(2) || dim(3) ~= dimvent(3)
    disp('not the same dimensions between EPI and ventricle mask');
    return;
end

if dim(1) ~= dimwm(1) || dim(2) ~= dimwm(2) || dim(3) ~= dimwm(3)
    disp('not the same dimensions between EPI and white matter mask');
    return;
end

for s = 1:length(epiFiles)
    [p,n,e] = fileparts(epiFiles{s});
    if ~exist(fullfile(outdir,[n e]))
        cmd = sprintf('cp -f %s %s',epiFiles{s},[outdir '/']);
        unix(cmd);
    end
end


%% CONFOUNDS REGRESSION

if preproc.conf.do
    
    for s = 1:length(epiFiles)

        [p,n,e] = fileparts(epiFiles{s});
        files_in = epiFiles{s};

        files_out.dc_high       = fullfile(outdir,[n '_dc_high.mat']); 
        files_out.dc_low        = fullfile(outdir,[n '_dc_low.mat']);
        files_out.filtered_data = 'gb_niak_omitted';
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',TR,'hp',0.01,'lp',Inf);

        niak_brick_time_filter(files_in,files_out,opt);

        clear files_in files_out opt;

    end


    for s = 1:length(epiFiles)

        [p,n,e] = fileparts(epiFiles{s});

        files_in.fmri         = epiFiles{s};
        files_in.dc_low       = fullfile(outdir,[n '_dc_low.mat']);
        files_in.dc_high      = fullfile(outdir,[n '_dc_high.mat']); 
        files_in.custom_param = 'gb_niak_omitted';
        files_in.motion_param = motionFiles{s};
        files_in.mask_brain   = brainMaskFile;
        files_in.mask_vent    = ventFile;
        files_in.mask_wm      = wmFile;

        files_out.scrubbing       = fullfile(outdir,['scrubbing_' n '.mat']);
        files_out.compcor_mask    = fullfile(outdir,['compcor_mask_' n '.mat']);
        files_out.confounds       = fullfile(outdir,['confounds_gs_' n '_cor' '.mat']);
        files_out.filtered_data   = fullfile(outdir,['c' n e]);
        files_out.qc_compcor      = fullfile(outdir,[n '_qc_compcor' e]);
        files_out.qc_slow_drift   = fullfile(outdir,[n '_qc_slow_drift' e]);
        files_out.qc_high         = fullfile(outdir,[n '_qc_high' e]);
        files_out.qc_wm           = fullfile(outdir,[n '_qc_wm' e]);
        files_out.qc_vent         = fullfile(outdir,[n '_qc_vent' e]);
        files_out.qc_motion       = fullfile(outdir,[n '_qc_motion' e]);
        files_out.qc_custom_param = 'gb_niak_omitted';
        files_out.qc_gse          = fullfile(outdir,[n '_qc_gse' e]);

        opt = struct('flag_compcor',1,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',0,'thre_fd',0.5,'flag_slow',1,...
                     'flag_high',0,'folder_out',[outdir '/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',0,...
                     'flag_vent',0,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

        FMRI_RegressConfoundsByNiak(files_in,files_out,opt);

        clear files_in files_out opt;

    end
    prefix = ['c' prefix];
    
end


%% TIME FILTERING

if preproc.filt.do
    
    for s = 1:length(epiFiles)

        [p,n,e]  = fileparts(epiFiles{s});
        files_in = fullfile(outdir,[prefix n e]);

        files_out.dc_high       = 'gb_niak_omitted'; 
        files_out.dc_low        = 'gb_niak_omitted';
        files_out.filtered_data = fullfile(outdir,['f' prefix n e]);
        files_out.var_high      = 'gb_niak_omitted';
        files_out.var_low       = 'gb_niak_omitted';
        files_out.beta_high     = 'gb_niak_omitted';
        files_out.beta_low      = 'gb_niak_omitted';

        opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',TR,'hp',preproc.filt.hp,'lp',preproc.filt.lp);

        niak_brick_time_filter(files_in,files_out,opt);

        clear files_in files_out opt;

    end
    prefix = ['f' prefix];
    
end


%% SMOOTHING

if preproc.fwhm.do
    
    for s = 1:length(epiFiles)

        [p,n,e]  = fileparts(epiFiles{s});
        files_in = fullfile(outdir,[prefix n e]);
        files_out = fullfile(outdir,['s' prefix n e]);    
        opt       = struct('flag_test',0,'flag_edge',1,'fwhm',preproc.fwhm.fwhm*[1 1 1],'flag_verbose',1,'folder_out',[outdir '/'],'flag_skip',0);    
        niak_brick_smooth_vol(files_in,files_out,opt);    
        clear files_in files_out opt;
        
    end
    prefix = ['s' prefix];
    
end
