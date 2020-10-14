function [conn,G,tseries,labels] = FMRI_BuildConnectomeOnSurface(epiFiles,outdir,volFile,TR,parcFiles,optConn,wmFile,ventFile,brainFile,motionFile)


% epiFiles          : files of preprocessed epi mapped to cortical surface (cell(2,1) lh and rh)
% volFile           : preprocessed epi volume file
% wmFile            : White matter mask
% ventFile          : Ventricle mask 
% motionFile        : motion parameters
% parcFiles         : parcellation files (cell(2,1) lh and rh)
% TR                : TR value
% optConn           : options (structure: doPreproc, hp, lp, typeConn, typeThresh.name, typeThresh.param)   


%% LOAD DATA

hdr_lh  = load_nifti(epiFiles{1});
hdr_rh  = load_nifti(epiFiles{2});
data_lh = squeeze(hdr_lh.vol);
data_rh = squeeze(hdr_rh.vol);
nbleft  = size(data_lh,1);
nbright = size(data_rh,1);
y       = [data_lh;data_rh]';   % organize the fMRI dataset as a time x space array

%% CONFOUNDS REGRESSION

if optConn.doPreproc
    
    opt_glm.flag_residuals = true;
    opt_glm.test           = 'none';

    % Compute low drift
    [p,n,e]  = fileparts(volFile);
    files_in = volFile;
    files_out.dc_high       = fullfile(outdir,[n '_dc_high.mat']); 
    files_out.dc_low        = fullfile(outdir,[n '_dc_low.mat']);
    files_out.filtered_data = 'gb_niak_omitted';
    files_out.var_high      = 'gb_niak_omitted';
    files_out.var_low       = 'gb_niak_omitted';
    files_out.beta_high     = 'gb_niak_omitted';
    files_out.beta_low      = 'gb_niak_omitted';
    opt = struct('folder_out',[outdir '/'],'flag_test',0,'flag_mean',1,'flag_verbose',1,'tr',TR,'hp',optConn.hp,'lp',Inf);
    niak_brick_time_filter(files_in,files_out,opt);
    clear files_in files_out opt;

    % Compute confounds
    [p,n,e] = fileparts(volFile);
    files_in.fmri         = volFile;
    files_in.dc_low       = fullfile(outdir,[n '_dc_low.mat']);
    files_in.dc_high      = fullfile(outdir,[n '_dc_high.mat']); 
    files_in.custom_param = 'gb_niak_omitted';
    files_in.motion_param = motionFile;
    files_in.mask_brain   = brainFile;
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
                 'flag_vent',0,'flag_gsc',1,'flag_pca_motion',1,'flag_test',0,'pct_var_explained',0.95);

    [files_in,files_out,opt,x,x2] = FMRI_RegressConfoundsByNiak(files_in,files_out,opt);
    clear files_in files_out opt;

    % Regress confounds stage 1 (slow time drifts, motion parameters)
    mean_y  = mean(y,1);
    y       = niak_normalize_tseries(y,'mean');
    model.y = y;
    model.x = niak_normalize_tseries(x);
    res     = niak_glm(model,opt_glm);
    y       = res.e;

    % Regress confounds stage 2 (global signal, compcorr)
    model.y   = y;
    [tmp,reg] = niak_lse(x2,x);    
    model.x   = reg;
    res       = niak_glm(model,opt_glm);
    y         = res.e;
    y         = y + repmat(mean_y,[size(y,1) 1]); % put the mean back in the time series

    % Filtering the data
    opt_f = struct('flag_mean',1,'tr',TR,'hp',optConn.hp,'lp',optConn.lp);
    y     = niak_filter_tseries(y,opt_f);
    clear opt_f;
    
end


%% EXTRACT TIME-COURSES OF ROI

opt_norm.type = 'none';
y = niak_normalize_tseries(y,opt_norm);
y_lh = y(:,1:nbleft);
y_rh = y(:,nbleft+1:end);
[vert_lh, label_lh, table_lh] = read_annotation(parcFiles{1}); 
[vert_rh, label_rh, table_rh] = read_annotation(parcFiles{2});

tseries = [];
std_tseries = [];
labels = {};
% left hemisphere
for k = 1:length(table_lh.struct_names)
    
    if ~strcmp(table_lh.struct_names{k},'Unknown') && ~strcmp(table_lh.struct_names{k},'Medial_wall')
        idx = find(label_lh==table_lh.table(k,5));
        if length(idx)>0
            idx_vert      = vert_lh(idx)+1;
            tseries       = [tseries mean(y_lh(:,idx_vert),2)];
            std_tseries   = [std_tseries std(y_lh(:,idx_vert),0,2)];
        else
            disp([table_lh.struct_names{k} ' no vertex'])
            tseries       = [tseries zeros(size(y_lh,1),1)];
            std_tseries   = [std_tseries zeros(size(y_lh,1),1)];
        end
        labels{end+1} = table_lh.struct_names{k};
    end
    
end
% right hemisphere
for k = 1:length(table_rh.struct_names)
    
    if ~strcmp(table_rh.struct_names{k},'Unknown') && ~strcmp(table_rh.struct_names{k},'Medial_wall')
        idx = find(label_rh==table_rh.table(k,5));
        if length(idx)>0
            idx_vert      = vert_rh(idx)+1;
            tseries       = [tseries mean(y_rh(:,idx_vert),2)];
            std_tseries   = [std_tseries std(y_rh(:,idx_vert),0,2)];
        else
            disp([table_rh.struct_names{k} ' no vertex'])
            tseries       = [tseries zeros(size(y_lh,1),1)];
            std_tseries   = [std_tseries zeros(size(y_lh,1),1)];
        end
        labels{end+1} = table_rh.struct_names{k};
    end
    
end

% Subcortical regions
sub_lab = {'Thalamus_L','Thalamus_R','VentralDC_L','VentralDC_R','Caudate_L','Caudate_R','Putamen_L','Putamen_R','Pallidum_L','Pallidum_R','Accumbens_L','Accumbens_R','Hippocampus_L','Hippocampus_R','Amygdala_L','Amygdala_R'};
sub_ind = [10 49 28 60 11 50 12 51 13 52 26 58 17 53 18 54];

[p,n,e]       = fileparts(volFile);
[hparc,parc]  = niak_read_vol(parcFiles{3});
if optConn.doPreproc
    [hvol,vol]    = niak_read_vol(fullfile(outdir,['c' n e]));
else
    [hvol,vol]    = niak_read_vol(volFile);
end
[nx,ny,nz,nt] = size(vol);
vol           = reshape(vol,nx*ny*nz,nt)';
if optConn.doPreproc
    opt_f         = struct('flag_mean',1,'tr',TR,'hp',optConn.hp,'lp',optConn.lp); % bandpass filtering
    vol           = niak_filter_tseries(vol,opt_f);
    clear opt_f;
end
parc          = parc(:);
for k = 1:length(sub_ind)
    idx_vox = find(parc==sub_ind(k));
    if length(idx_vox)>0
        tseries       = [tseries mean(vol(:,idx_vox),2)];
        std_tseries   = [std_tseries std(vol(:,idx_vox),0,2)];
    else
        disp([sub_lab{k} ' no voxel'])
        tseries       = [tseries zeros(size(vol,1),1)];
        std_tseries   = [std_tseries zeros(size(vol,1),1)];
    end
    labels{end+1} = sub_lab{k};
end

% normalization
optn.type = 'mean_var';
tseries   = niak_normalize_tseries(tseries,optn);
clear optn;


%% BUILD CONNECTOME

switch optConn.typeConn
    case 'S'
        conn = niak_build_srup(tseries,true);
    case 'R' 
        [tmp,conn] = niak_build_srup(tseries,true);
    case 'Z' 
        [tmp,conn] = niak_build_srup(tseries,true);
        conn = niak_fisher(conn);
    case 'U'
        [tmp,tmp2,conn] = niak_build_srup(tseries,true);
    case 'P' 
        [tmp,tmp2,tmp3,conn] = niak_build_srup(tseries,true);
    otherwise
        error('%s is an unknown type of connectome',optConn.typeConn)
end
conn(isnan(conn)) = 0;

switch optConn.typeThresh.name
    case 'sparsity'            
        [val,order] = sort(abs(conn),'descend');
        G = false(size(conn));
        G(order(1:min(ceil(optConn.typeThresh.param * length(G)),length(G)))) = true;            
    case 'sparsity_pos'
        [val,order] = sort(conn,'descend');
        G = false(size(conn));
        G(order(1:min(ceil(optConn.typeThresh.param * length(G)),length(G)))) = true;            
    case 'cut_off'
        G = abs(conn)>=optConn.typeThresh.param;
    case 'cut_off_pos'
        G = conn>=optConn.typeThresh.param;
    otherwise
        error('%s is an unkown type of binarization method',optConn.typeThresh.name);
end


