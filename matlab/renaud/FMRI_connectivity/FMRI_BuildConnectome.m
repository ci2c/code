function FMRI_BuildConnectome(epiFile,rois,prep,conn_opt,outdir)

% usage : FMRI_BuildConnectome(epiFile,rois,prep)
%
% Inputs :
%    epiFile       : functional EPI file (.nii)
%    rois          : structure of rois
%       file          : roi file (.nii)
%       resize        : 'roi2epi' (resize roi to epi) or 'epi2roi' (resize
%                       epi to roi)
%       label         : labels to keep (default [] means all labels)
%    prep          : structure of preprocessing steps ('do': 0 or 1)
%    conn_opt      : structure
%       analysis
%           numrois   : number of rois to be used ('all' or [1 3 4] for
%           example)
%           seed      : true for seed analysis or false for "between rois"
%           analysis
%           type      : 'S', 'R', 'Z', 'U' or 'P' (only for "rois"
%           analysis)
%           normalize : do MNI transformation
%           normFile  ; transformation file
%
% Options
%    structure 'prep'
%       TR              : TR value (Default: 2.4)
%       WM              : white matter mask (Default: True)
%       vent            : ventricles mask (Default: True)
%       brain           : brain mask
%       motion          : motion file
%       hp              : high-pass filter value (Default: 0.01)
%       lp              : low-pass filter value (Default: 0.08)
%       correction.type : type of normalization (Default: 'mean_var')
%       fwhm            : smoothing value (Default: 6)
%    keeprois      : ROIs of the mask (Default: 1:nrois)
%    nameRoi       : name of ROIs (Default: AAL template)
%    tempFile      : template file (Default: AAL template)
%    method        : type of correlation ("correlation" - "" - "") (Default: 'correlation') 
%    path_to_gen   : add path to matlab (Default: true)
%
% Output :
%    Z             : fisher to Z data
%    C             : correlation vector
%    Cmat          : correlation matrix
%    coord         : ROIs coordinate
%    nameRoi       : name of ROIs
%    tseries       : mean time course for each ROI
%    data          : preprocessing data
%
% Renaud Lopes @ CHRU Lille, May 2014


%% PREPROCESSING

if prep.do == 1
    
    [p,n,e] = fileparts(epiFile);
    if ~isfield(prep,'TR')
        prep.TR = 2.4;
    end
    if ~isfield(prep,'WM')
        prep.WM = fullfile(p,'rwm.nii');
    end
    if ~isfield(prep,'vent')
        prep.vent = fullfile(p,'rvent.nii');
    end
    if ~isfield(prep,'brain')
        prep.brain = fullfile(p,'masks','brain.nii');
    end
    if ~isfield(prep,'motion')
        prep.motion = fullfile(p,'mcprextreg');
    end
    if ~isfield(prep,'hp')
        prep.hp = 0.01;
    end
    if ~isfield(prep,'lp')
        prep.lp = 0.08;
    end
    if ~isfield(prep,'correction')
        prep.correction.type = 'mean_var';
    end
    if ~isfield(prep,'fwhm')
        prep.fwhm = 6;
    end
    
    epiTmp = FMRI_PreprocessingForConnectome(epiFile,prep);
    
else
    
    disp('no preprocessing step');
    epiTmp = epiFile;
    
end


%% EXTRACT MEAN TIME-COURSES

fprintf('Reading fMRI dataset %s ...\n',epiTmp);
[hdr,vol]     = niak_read_vol(epiTmp);
[nx,ny,nz,nt] = size(vol);
tseries_vox   = reshape(vol,nx*ny*nz,nt);
[p,n,e]       = fileparts(epiTmp);

nb_mask     = length(rois);
all_ind_roi = cell(nb_mask,1);

opt_tmp.correction.type = 'none';
opt_tmp.flag_all = false;

for num_m = 1:nb_mask
    
    roiFile = rois{num_m}.file;
    
    if exist(roiFile,'file')
        
        [pr,nr,er] = fileparts(roiFile);
        if ~strcmp(pr,outdir)
            cmd = sprintf('cp -f %s %s',roiFile,outdir);
            unix(cmd);
        end
        roiFile = fullfile(outdir,[nr er]);
        [pr,nr,er] = fileparts(roiFile);
        fprintf('Reading mask %s ...\n',roiFile);
        [hdr2,mask] = niak_read_vol(roiFile);
        rois{num_m}.newfile = roiFile;

        [nx2,ny2,nz2] = size(mask);

        hdrtmp = hdr;
        voltmp = vol;

        if strcmp(rois{num_m}.resize,'roi2epi')
            spm_get_defaults;
            spm_jobman('initcfg');
            matlabbatch = {};
            epitmp=cellstr(spm_select('ExtFPList',p,['^',n,e],1:1e4));
            matlabbatch{end+1}.spm.spatial.coreg.write.ref           = epitmp;
            matlabbatch{end}.spm.spatial.coreg.write.source          = cellstr(roiFile);
            matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 0;
            matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
            matlabbatch{end}.spm.spatial.coreg.write.roptions.mask   = 0;
            matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
            spm_jobman('run',matlabbatch);

            roiFile = fullfile(pr,['r' nr er]);
            rois{num_m}.newfile = roiFile;
            [hdr2,mask] = niak_read_vol(roiFile);
        elseif strcmp(rois{num_m}.resize,'epi2roi')
            epiTmp = fullfile(outdir,['r' n e]);
            if ~exist(epiTmp)
                spm_get_defaults;
                spm_jobman('initcfg');
                matlabbatch = {};
                epitmp=cellstr(spm_select('ExtFPList',p,['^',n,e],1:1e4));
                matlabbatch{end+1}.spm.spatial.coreg.write.ref           = cellstr(roiFile);
                matlabbatch{end}.spm.spatial.coreg.write.source          = epitmp;
                matlabbatch{end}.spm.spatial.coreg.write.roptions.interp = 4;
                matlabbatch{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
                matlabbatch{end}.spm.spatial.coreg.write.roptions.mask   = 0;
                matlabbatch{end}.spm.spatial.coreg.write.roptions.prefix = 'r';
                spm_jobman('run',matlabbatch);

                cmd = sprintf('mv %s %s',fullfile(p,['r' n e]),[outdir '/']);
                unix(cmd);
                cmd = sprintf('mv %s %s',fullfile(p,['r' n '.mat']),[outdir '/']);
                unix(cmd);
            end

            [hdrtmp,voltmp]  = niak_read_vol(epiTmp);
            
        end
        
        if length(rois{num_m}.label)>0
            dim = size(mask);
            mask = mask(:);
            masktmp = zeros(size(mask));
            for k = 1:length(rois{num_m}.label)
                idx = find(mask==rois{num_m}.label(k));
                masktmp(idx) = k;
            end
            mask = reshape(masktmp,dim(1),dim(2),dim(3));
            clear masktmp;
        end

        [all_ind_roi{num_m},I,J] = unique(mask);
        mask = reshape(J,size(mask));
        if all_ind_roi{num_m}(1) == 0
            mask = mask - 1;
            all_ind_roi{num_m} = all_ind_roi{num_m}(2:end);
        end

        [tseries{num_m},std_tseries{num_m},labels_roi{num_m}] = FMRI_Build_Tseries(voltmp,mask,opt_tmp);
        
    else
        
        tseries{num_m} = zeros(nt,1);
        std_tseries{num_m} = zeros(nt,1);
        labels_roi{num_m} = 'none';
        
    end
    
end


%% CONNECTOME

[nx1,ny1,nz1,nt] = size(voltmp);
tseries_vox      = reshape(voltmp,nx1*ny1*nz1,nt);
tseries_vox      = niak_correct_mean_var(tseries_vox','mean');

nb_conn = length(conn_opt.analysis);

for k = 1:nb_conn
    
    sel  = conn_opt.analysis{k}.numrois;
    type = conn_opt.analysis{k}.type;
    
    if strcmp(sel,'all')
        tseries_tmp = cat(2,tseries{:});
    else
        tseries_tmp = cat(2,tseries{sel});
    end
    
    if conn_opt.analysis{k}.seed
        
        tseries_tmp = niak_correct_mean_var(tseries_tmp,'mean');
        
        for j = 1:size(tseries_tmp,2)  
            
            if sum(abs(tseries_tmp(:,j)))>0
            
                switch conn_opt.analysis{k}.type
                    case 'R' 
                        conn(:,j) = corr(tseries_vox,tseries_tmp(:,j));
                    case 'Z'
                        conn(:,j) = corr(tseries_vox,tseries_tmp(:,j));
                        conn(:,j) = niak_fisher(conn(:,j));
                    otherwise
                        error('%s is an unknown type of connectome',conn_opt.type)
                end
                conn(isnan(conn(:,j)),j) = 0;

                CMat = reshape(conn(:,j),nx1,ny1,nz1);
                hdr2.file_name = fullfile(outdir,[conn_opt.analysis{k}.name '_' num2str(j) '.nii']);
                niak_write_vol(hdr2,CMat);
                
                if conn_opt.analysis{k}.normalize
                    spm_get_defaults;
                    spm_jobman('initcfg');
                    clear matlabbatch 
                    matlabbatch = {};
                    matlabbatch{end+1}.spm.spatial.normalise.write.subj.def      = cellstr(conn_opt.analysis{k}.normFile);
                    matlabbatch{end}.spm.spatial.normalise.write.subj.resample   = cellstr(hdr2.file_name);
                    matlabbatch{end}.spm.spatial.normalise.write.woptions.bb     = [-78 -112 -70; 78 76 85];
                    matlabbatch{end}.spm.spatial.normalise.write.woptions.vox    = [2 2 2];
                    matlabbatch{end}.spm.spatial.normalise.write.woptions.interp = 4;
                    spm_jobman('run',matlabbatch);
                end
                
            end
            
        end
        
    else
    
        switch conn_opt.analysis{k}.type
            case 'S'
                conn = niak_build_srup(tseries_tmp,true);
            case 'R' 
                [tmp,conn] = niak_build_srup(tseries_tmp,true);
            case 'Z' 
                [tmp,conn] = niak_build_srup(tseries_tmp,true);
                conn = niak_fisher(conn);
            case 'U'
                [tmp,tmp2,conn] = niak_build_srup(tseries_tmp,true);
            case 'P' 
                [tmp,tmp2,tmp3,conn] = niak_build_srup(tseries_tmp,true);
            otherwise
                error('%s is an unknown type of connectome',conn_opt.type)
        end
    
    end
    
    all_conn{k} = conn;
    
end
            
