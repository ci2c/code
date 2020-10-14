function FMRI_PreprocessingByNiak(epiFiles,anatFile,outdir,TR,acquisition,fwhmvol)

niak_gb_vars

if ~exist(outdir,'dir')
    cmd = sprintf('mkdir %s',outdir);
    unix(cmd);
end

outqc = fullfile(outdir,'quality_control');
if ~exist(fullfile(outdir,'quality_control'),'dir')
    cmd = sprintf('mkdir -p %s',fullfile(outdir,'quality_control'));
    unix(cmd);
end


%% AAL RESAMPLING

files_in.source         = fullfile(gb_niak_path_template,'roi_aal_3mm.mnc.gz');
files_in.target         = fullfile(gb_niak_path_template,'roi_aal_3mm.mnc.gz');
files_in.transformation = '';
files_in.transformation_stereo = 'gb_niak_omitted';

files_out = fullfile(outdir,'template_aal.mnc.gz');

opt = struct('interpolation','nearest_neighbour','flag_test',0,'flag_skip',0,'transf_name','transf',...
             'flag_tfm_space',0,'voxel_size',0,'folder_out','','flag_invert_transf',0,'flag_verbose',1,...
             'flag_adjust_fov',0,'flag_keep_range',0);
       
niak_brick_resample_vol(files_in,files_out,opt);

clear files_in files_out opt;


%% T1 PREPROCESSING

files_in = anatFile;

files_out.transformation_lin     = fullfile(outdir,'transf_subject1_nativet1_to_stereolin.xfm');
files_out.transformation_nl      = fullfile(outdir,'transf_subject1_stereolin_to_stereonl.xfm');
files_out.transformation_nl_grid = fullfile(outdir,'transf_subject1_stereolin_to_stereonl_grid.mnc');
files_out.anat_nuc               = fullfile(outdir,'anat_subject1_nuc_nativet1.mnc');
files_out.anat_nuc_stereolin     = fullfile(outdir,'anat_subject1_nuc_stereolin.mnc');
files_out.anat_nuc_stereonl      = fullfile(outdir,'anat_subject1_nuc_stereonl.mnc');
files_out.mask_stereolin         = fullfile(outdir,'anat_subject1_mask_stereolin.mnc');
files_out.mask_stereonl          = fullfile(outdir,'anat_subject1_mask_stereonl.mnc');
files_out.classify               = fullfile(outdir,'anat_subject1_classify_stereolin.mnc');
         
opt.nu_correct    = struct('arg','-distance 50');
opt.template_t1   = 'mni_icbm152_nlin_sym_09a';
opt.folder_out    = [outdir '/'];
opt.flag_test     = 0;
opt.flag_all      = 0;
opt.mask_brain_t1 = struct('flag_test',0);
opt.mask_head_t1  = struct('flag_test',0);
opt.flag_verbose  = 1;

niak_brick_t1_preprocess(files_in,files_out,opt);

clear files_in files_out opt;


%% PARTIAL VOLUME EFFECT

files_in.vol          = fullfile(outdir,'anat_subject1_nuc_stereolin.mnc');
files_in.mask         = fullfile(outdir,'anat_subject1_mask_stereolin.mnc');
files_in.segmentation = fullfile(outdir,'anat_subject1_classify_stereolin.mnc');

files_out.pve_wm   = fullfile(outdir,'anat_subject1_pve_wm_stereolin.mnc');
files_out.pve_gm   = fullfile(outdir,'anat_subject1_pve_gm_stereolin.mnc');
files_out.pve_csf  = fullfile(outdir,'anat_subject1_pve_csf_stereolin.mnc');
files_out.pve_disc = fullfile(outdir,'anat_subject1_pve_disc_stereolin.mnc');
    
opt.rand_seed    = [102 48 100 53 102 51 99 48 48 51 49 49 55 50 57 98 49 49 53 48 98 49 97 56 98 101 57 99 57 48 101 98];
opt.beta         = 0.1;
opt.class_params = [];
opt.flag_verbose = 1;
opt.flag_test    = 0;

niak_brick_pve(files_in,files_out,opt);

clear files_in files_out opt;


%% SLICE TIMING CORRECTION

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    [hdr,vol] = niak_read_vol(epiFiles{s});
    nslices   = size(vol,3);
    clear hdr vol;

    if strcmp(acquisition,'ascending')
        sliceorder = 1:1:nslices;
    elseif strcmp(acquisition,'interleaved')
        sliceorder = [];
        space      = round(sqrt(nslices));
        for k=1:space
            tmp        = k:space:nslices;
            sliceorder = [sliceorder tmp];
        end
    elseif strcmp(acquisition,'descending')
        sliceorder = [nslices:-2:1 nslices-1:-2:1];
    else
        sliceorder = 1:1:nslices;
    end

    files_in  = epiFiles{s};
    files_out = fullfile(outdir,[n '_a' e]);
    opt_st    = struct('type_acquisition','manual','type_scanner','','folder_out',[outdir '/'],'flag_test',0,'iter_nu_correct',3,'arg_nu_correct','-distance 200', ...
        'flag_nu_correct',0,'flag_center',0,'flag_history',0,'flag_even_odd',0,'flag_regular',1,'flag_skip',0,'flag_variance',1,'suppress_vol',0,'interpolation','spline', ...
        'slice_order',sliceorder,'first_number','odd','step',[],'ref_slice',[],'timing',[],'nb_slices',[],'tr',[],'delay_in_tr',0,'flag_verbose',1);

    niak_brick_slice_timing(files_in,files_out,opt_st);

    clear files_in files_out opt_st;
    
end


%% MOTION CORRECTION

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    files_in{1} = fullfile(outdir,[n '_a' e]);
    files_out   = fullfile(outdir,['motion_target_' n e]);
    opt         = struct('operation','vol = median(vol_in{1},4);','flag_extra',0,'flag_test',0,'opt_operation',[],'flag_verbose',1);
    niak_brick_math_vol(files_in,files_out,opt);
    clear files_in files_out opt;
    
    files_in.fmri   = fullfile(outdir,[n '_a' e]);
    files_in.target = fullfile(outdir,['motion_target_' n e]);
    files_out       = fullfile(outdir,['motion_Wrun_' n '.mat']);
    opt             = struct('flag_test',0,'ignore_slice',1,'fwhm',5,'step',10,'tol',5.0000e-04,'folder_out',[outdir '/'],'flag_verbose',1);
    niak_brick_motion_parameters(files_in,files_out,opt);
    clear files_in files_out opt;
    
    if s>1
        
        files_in.fmri   = fullfile(outdir,['motion_target_' n e]);
        files_in.target = targetFile;
        files_out       = fullfile(outdir,['motion_Bsession_' n '.mat']);
        opt             = struct('flag_test',0,'ignore_slice',1,'fwhm',5,'step',10,'tol',1.0000e-05,'folder_out',[outdir '/'],'flag_verbose',1);
        niak_brick_motion_parameters(files_in,files_out,opt);
        clear files_in files_out opt;
        
        files_in{1} = fullfile(outdir,['motion_Wrun_' n '.mat']);
        files_in{2} = fullfile(outdir,['motion_Bsession_' n '.mat']);
        files_out   = fullfile(outdir,['motion_parameters_' n '.mat']);
        opt         = struct('var_name','transf','flag_test',0,'flag_verbose',1);
        niak_brick_combine_transf(files_in,files_out,opt);
        clear files_in files_out opt;
        
    else
        
        targetFile = fullfile(outdir,['motion_target_' n e]);
        
        files_in{1} = fullfile(outdir,['motion_Wrun_' n '.mat']);
        files_out   = fullfile(outdir,['motion_parameters_' n '.mat']);
        opt         = struct('var_name','transf','flag_test',0,'flag_verbose',1);
        niak_brick_combine_transf(files_in,files_out,opt);
        clear files_in files_out opt;
        
    end
        
end


%% COREGISTRATION ANAT -> FMRI

[p,n,e] = fileparts(epiFiles{1});

files_in.func                = fullfile(outdir,['motion_target_' n e]);
files_in.anat                = fullfile(outdir,'anat_subject1_nuc_stereolin.mnc');
files_in.mask_anat           = fullfile(outdir,'anat_subject1_mask_stereolin.mnc');
files_in.transformation_init = fullfile(outdir,'transf_subject1_nativet1_to_stereolin.xfm');
files_in.mask_func           = 'gb_niak_omitted';

files_out.transformation = fullfile(outdir,'transf_subject1_nativefunc_to_stereolin.xfm');
files_out.anat_hires     = fullfile(outdir,'anat_subject1_nativefunc_hires.mnc');
files_out.anat_lowres    = fullfile(outdir,'anat_subject1_nativefunc_lowres.mnc');

opt = struct('flag_invert_transf_init',1,'flag_invert_transf_output',1,'flag_test',0,...
             'arg_nu_correct','-distance 200','flag_nu_correct',0,'fwhm_masking',8,...
             'list_fwhm',[8 3 8 4 3],...
             'list_step',[4 4 4 2 1],'list_simplex',[8 4 2 2 1],'folder_out',[outdir '/'],...
             'flag_verbose',1,'init','identity');
opt.list_mes = {'mi'  'mi'  'mi'  'mi'  'mi'};

niak_brick_anat2func(files_in,files_out,opt);
clear files_in files_out opt;


%% CONCATENATE NON-LINEAR TRANSFORMATIONS

files_in{1} = fullfile(outdir,'transf_subject1_nativefunc_to_stereolin.xfm');
files_in{2} = fullfile(outdir,'transf_subject1_stereolin_to_stereonl.xfm');
files_out   = fullfile(outdir,'transf_subject1_nativefunc_to_stereonl.xfm');
opt         = struct('flag_test',0);
niak_brick_concat_transf(files_in,files_out,opt);
clear files_in files_out opt;


%% RESAMPLING

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    files_in.source                = fullfile(outdir,[n '_a' e]);
    files_in.target                = fullfile(outdir,'template_aal.mnc.gz');
    files_in.transformation        = fullfile(outdir,['motion_parameters_' n '.mat']);
    files_in.transformation_stereo = fullfile(outdir,'transf_subject1_nativefunc_to_stereonl.xfm');
    
    files_out = fullfile(outdir,[n '_a_res' e]);
    
    opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_skip',0,'transf_name','transf',...
                 'interpolation','trilinear','flag_tfm_space',0,'voxel_size',0,'flag_invert_transf',0,...
                 'flag_verbose',1,'flag_adjust_fov',0,'flag_keep_range',0);
    
    niak_brick_resample_vol(files_in,files_out,opt);
    clear files_in files_out opt;
    
end


%% QUALITY CONTROL: MOTION

opt = struct();

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    files_in.vol{s} = fullfile(outdir,[n '_a_res' e]);
    files_in.motion_parameters{s} = fullfile(outdir,['motion_Wrun_' n '.mat']);
    
    opt.labels_vol{s} = [n '_a_res'];
end

files_out.fig_motion_parameters = fullfile(outqc,'fig_motion_within_run.pdf');
files_out.mask_average          = fullfile(outqc,'func_subject1_mask_average_stereonl.mnc');
files_out.mask_group            = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
files_out.mean_vol              = fullfile(outqc,'func_subject1_mean_stereonl.mnc');
files_out.std_vol               = fullfile(outqc,'func_subject1_std_stereonl.mnc');
files_out.fig_coregister        = fullfile(outqc,'fig_coregister_motion.pdf'); 
files_out.tab_coregister        = fullfile(outqc,'tab_coregister_motion.csv');

opt.flag_test    = 0;
opt.mask         = struct();
opt.label        = '';
opt.thresh       = 0.95;
opt.flag_verbose = 1;
opt.folder_out   = [outqc '/'];
      
niak_brick_qc_motion_correction_ind(files_in,files_out,opt);

clear files_in files_out opt;


%% CORSICA MASK

files_in.mask_vent_stereo  = fullfile(gb_niak_path_template,'roi_ventricle.mnc.gz');
files_in.mask_wm_stereo    = fullfile(gb_niak_path_template,'mni-models_icbm152-nl-2009-1.0/mni_icbm152_t1_tal_nlin_sym_09a_mask_pure_wm_2mm.mnc.gz');
files_in.mask_stem_stereo  = fullfile(gb_niak_path_template,'roi_stem.mnc.gz');
files_in.mask_brain        = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
files_in.aal               = fullfile(gb_niak_path_template,'roi_aal.mnc.gz');
files_in.functional_space  = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
files_in.transformation_nl = fullfile(outdir,'transf_subject1_stereolin_to_stereonl.xfm');
files_in.segmentation      = fullfile(outdir,'anat_subject1_classify_stereolin.mnc');

files_out.mask_vent_ind    = fullfile(outdir,'subject1_mask_vent_funcstereonl.mnc');
files_out.mask_stem_ind    = fullfile(outdir,'subject1_mask_stem_funcstereonl.mnc');
files_out.white_matter_ind = fullfile(outdir,'subject1_mask_wm_funcstereonl.mnc');

opt = struct('target_space','stereonl','flag_test',0,'flag_verbose',1,'folder_out',[outdir '/']);

niak_brick_mask_corsica(files_in,files_out,opt);

clear files_in files_out opt;


%% TIME FILTERING

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    files_in = fullfile(outdir,[n '_a_res' e]);

    files_out.dc_high       = fullfile(outdir,[n '_a_res_dc_high.mat']);
    files_out.dc_low        = fullfile(outdir,[n '_a_res_dc_low.mat']);
    files_out.filtered_data = 'gb_niak_omitted';
    files_out.var_high      = 'gb_niak_omitted';
    files_out.var_low       = 'gb_niak_omitted';
    files_out.beta_high     = 'gb_niak_omitted';
    files_out.beta_low      = 'gb_niak_omitted';
    
    opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',TR,'hp',0.01,'lp',Inf);
    
    niak_brick_time_filter(files_in,files_out,opt);
    
    clear files_in files_out opt;
    
end


%% CONFOUNDS REGRESSION

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    files_in.fmri         = fullfile(outdir,[n '_a_res' e]);
    files_in.dc_low       = fullfile(outdir,[n '_a_res_dc_low.mat']);
    files_in.dc_high      = fullfile(outdir,[n '_a_res_dc_high.mat']);
    files_in.custom_param = 'gb_niak_omitted';
    files_in.motion_param = fullfile(outdir,['motion_parameters_' n '.mat']);
    files_in.mask_brain   = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
    files_in.mask_vent    = fullfile(outdir,'subject1_mask_vent_funcstereonl.mnc');
    files_in.mask_wm      = fullfile(outdir,'subject1_mask_wm_funcstereonl.mnc');
    
    files_out.scrubbing       = fullfile(outdir,['scrubbing_' n '.mat']);
    files_out.compcor_mask    = fullfile(outdir,['compcor_mask_' n '.mat']);
    files_out.confounds       = fullfile(outdir,['confounds_gs_' n '_cor' '.mat']);
    files_out.filtered_data   = fullfile(outdir,[n '_cor' e]);
    files_out.qc_compcor      = fullfile(outdir,[n '_qc_compcor_funcstereonl' e]);
    files_out.qc_slow_drift   = fullfile(outdir,[n '_qc_slow_drift_funcstereonl' e]);
    files_out.qc_high         = fullfile(outdir,[n '_qc_high_funcstereonl' e]);
    files_out.qc_wm           = fullfile(outdir,[n '_qc_wm_funcstereonl' e]);
    files_out.qc_vent         = fullfile(outdir,[n '_qc_vent_funcstereonl' e]);
    files_out.qc_motion       = fullfile(outdir,[n '_qc_motion_funcstereonl' e]);
    files_out.qc_custom_param = 'gb_niak_omitted';
    files_out.qc_gse          = fullfile(outdir,[n '_qc_gse_funcstereonl' e]);
    
    opt = struct('flag_compcor',0,'compcor',struct(),'nb_vol_min',40,'flag_scrubbing',1,'thre_fd',0.5,'flag_slow',1,...
                 'flag_high',0,'folder_out',[outdir '/'],'flag_verbose',1,'flag_motion_params',1,'flag_wm',1,...
                 'flag_vent',1,'flag_gsc',0,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);
    
    niak_brick_regress_confounds(files_in,files_out,opt);
    
    clear files_in files_out opt;
    
end


%% CORSICA

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    % SICA
    files_in.fmri = fullfile(outdir,[n '_cor' e]);
    files_in.mask = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
    
    files_out.space = fullfile(outdir,[n '_cor_sica_space' e]);
    files_out.time  = fullfile(outdir,[n '_cor_sica_time' '.mat']);
    
    opt = struct('flag_test',0,'rand_seed',[102 48 100 53 102 51 99 48 48 51 49 49 55 50 57 98 49 49 53 48 98 49 97 56 98 101 57 99 57 48 101 98],...
                 'folder_out',[outdir '/'],'norm','mean','algo','Infomax','nb_comp',60,'flag_verbose',1);
    
    niak_brick_sica(files_in,files_out,opt);
    clear files_in files_out opt;
    
    
    % SELECT VENTRICLES COMPONENT
    
    files_in.fmri              = fullfile(outdir,[n '_cor' e]);
    files_in.component         = fullfile(outdir,[n '_cor_sica_time' '.mat']);
    files_in.mask              = fullfile(outdir,'subject1_mask_vent_funcstereonl.mnc');
    files_in.transformation    = 'gb_niak_omitted';
    files_in.component_to_keep = 'gb_niak_omitted';
    
    files_out = fullfile(outdir,[n '_cor_compsel_ventricles.mat']);

    opt = struct('flag_test',0,'rand_seed',[106 52 104 57 106 55 103 52 52 55 53 53 59 54 61 102 53 53 57 52 102 53 101 60 102 105 61 103 61 52 105 102],...
                 'ww',0,'nb_cluster',0,'p',1.0000e-04,'nb_samps',50,'type_score','freq','flag_verbose',1,'folder_out',[outdir '/']);
    
    niak_brick_component_sel(files_in,files_out,opt);
    clear files_in files_out opt;
    
    
    % SELECT STEM COMPONENT
    
    files_in.fmri              = fullfile(outdir,[n '_cor' e]);
    files_in.component         = fullfile(outdir,[n '_cor_sica_time' '.mat']);
    files_in.mask              = fullfile(outdir,'subject1_mask_stem_funcstereonl.mnc');
    files_in.transformation    = 'gb_niak_omitted';
    files_in.component_to_keep = 'gb_niak_omitted';
    
    files_out = fullfile(outdir,[n '_cor_compsel_stem.mat']);

    opt = struct('flag_test',0,'rand_seed',[107 53 105 58 107 56 104 53 53 56 54 54 60 55 62 103 54 54 58 53 103 54 102 61 103 106 62 104 62 53 106 103],...
                 'ww',0,'nb_cluster',0,'p',1.0000e-04,'nb_samps',50,'type_score','freq','flag_verbose',1,'folder_out',[outdir '/']);
    
    niak_brick_component_sel(files_in,files_out,opt);
    clear files_in files_out opt;
    
    
    % QC CORSICA 1
    
    files_in.space    = fullfile(outdir,[n '_cor_sica_space' e]);
    files_in.time     = fullfile(outdir,[n '_cor_sica_time' '.mat']);
    files_in.score{1} = fullfile(outdir,[n '_cor_compsel_ventricles.mat']);
    files_in.score{2} = fullfile(outdir,[n '_cor_compsel_stem.mat']);
    files_in.mask     = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
    
    files_out = fullfile(outqc,[n '_cor_sica_space_qc_corsica.pdf']);
    
    opt = struct('flag_test',0,'threshold',0.15,'folder_out',[outqc '/'],'labels_score','','fwhm',5,'flag_verbose',1);
    
    niak_brick_qc_corsica(files_in,files_out,opt);
    clear files_in files_out opt;
    
    
    % REMOVE COMPONENTS
    
    files_in.fmri       = fullfile(outdir,[n '_cor' e]);
    files_in.space      = fullfile(outdir,[n '_cor_sica_space' e]);
    files_in.time       = fullfile(outdir,[n '_cor_sica_time' '.mat']);
    files_in.mask_brain = fullfile(outqc,'func_subject1_mask_stereonl.mnc');
    files_in.compsel{1} = fullfile(outdir,[n '_cor_compsel_ventricles.mat']);
    files_in.compsel{2} = fullfile(outdir,[n '_cor_compsel_stem.mat']);
    
    files_out = fullfile(outdir,[n '_cor_p' e]);
    
    opt = struct('flag_test',0,'threshold',0.15,'folder_out',[outdir '/'],'flag_verbose',1);
    
    niak_brick_component_supp(files_in,files_out,opt);
    clear files_in files_out opt;
    
    
    % QC CORSICA 2
    
    files_in{1} = fullfile(outdir,[n '_cor_p' e]);
    files_in{2} = fullfile(outdir,[n '_cor' e]);
    
    files_out = fullfile(outqc,['qc_corsica_var_' n 'funcstereonl' e]);
    
    opt = struct('operation','var1 = std(vol_in{1},[],4).^2; var2 = std(vol_in{2},[],4).^2; mask = (var1>0) & (var2>0); vol = ones(size(var1)); vol(mask)=var1(mask)./var2(mask);',...
                 'flag_test',0,'opt_operation',[],'flag_extra',1,'flag_verbose',1);
             
    niak_brick_math_vol(files_in,files_out,opt);
    clear files_in files_out opt;
       
end


%% SMOOTHING

for s = 1:length(epiFiles)
    
    [p,n,e] = fileparts(epiFiles{s});
    
    files_in  = fullfile(outdir,[n '_cor_p' e]);    
    files_out = fullfile(outdir,[n '_cor_p_s' e]);    
    opt       = struct('flag_test',0,'flag_edge',1,'fwhm',fwhmvol*[1 1 1],'flag_verbose',1,'folder_out',[outdir '/'],'flag_skip',0);    
    niak_brick_smooth_vol(files_in,files_out,opt);    
    clear files_in files_out opt;
    
    files_in  = fullfile(outdir,[n '_cor' e]);    
    files_out = fullfile(outdir,[n '_cor_s' e]);    
    opt       = struct('flag_test',0,'flag_edge',1,'fwhm',fwhmvol*[1 1 1],'flag_verbose',1,'folder_out',[outdir '/'],'flag_skip',0);    
    niak_brick_smooth_vol(files_in,files_out,opt);    
    clear files_in files_out opt;
    
    files_in  = fullfile(outdir,[n '_a_res' e]);
    files_out = fullfile(outdir,[n '_a_res_s' e]);    
    opt       = struct('flag_test',0,'flag_edge',1,'fwhm',fwhmvol*[1 1 1],'flag_verbose',1,'folder_out',[outdir '/'],'flag_skip',0);    
    niak_brick_smooth_vol(files_in,files_out,opt);    
    clear files_in files_out opt;
    
end
    