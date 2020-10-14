function [tseries_all,coord_rois,data_all] = ConcatenateTimeCourses(maskFiles,epiFiles,covFiles,TR)

tseries_all = [];
data_all = {};

opt_pre.normalize = 1;
opt_pre.detrend   = 1;
opt_pre.filtering = 1;

for s = 1:size(epiFiles,1)
    
    Vepi = spm_vol(deblank(epiFiles(s,:)));
    epi  = spm_read_vols(Vepi);
    dim  = size(epi);
    epi  = reshape(epi,dim(1)*dim(2)*dim(3),dim(4));
    
    idx={};
    maskc={};
    data={};
    for k = 1:length(maskFiles)
        if size(maskFiles{k},1)==1
            V{k} = spm_vol(deblank(maskFiles{k}));
            mask = spm_read_vols(V{k});
            mask = mask(:);
            idx{k} = find(mask>0);
            maskc{k} = mask(idx{k});
            data{k} = epi(idx{k},:)';
        else
            V{k} = spm_vol(deblank(maskFiles{k}(s,:)));
            mask = spm_read_vols(V{k});
            mask = mask(:);
            idx{k} = find(mask>0);
            maskc{k} = mask(idx{k});
            data{k} = epi(idx{k},:)';
        end
        
        % NORMALIZATION
        if(opt_pre.normalize == 1)
            opt_norm.type     = 'mean_var';
            opt_norm.ind_time = 2;
            data{k} = niak_normalize_tseries(data{k},opt_norm);
        end
        
        % DETRENDING
        if(opt_pre.detrend == 1)
            covariates = [];
            covariates = FMRI_SignalDetrending(deblank(epiFiles(s,:)),[],TR);

            [p,n,e] = fileparts(deblank(covFiles(s,:)));
            if strcmp(e,'.nii') || strcmp(e,'.img')
                V0 = spm_vol(deblank(covFiles(s,:))); 
                X0 = spm_read_vols(V0);
                X0 = X0(:);
                idx = find(X0>0);
                [eig_val,eig_vec] = niak_pca(epi(idx,:),3);
                covariates = [covariates eig_vec];
            elseif strcmp(e,'.txt')
                X = load(deblank(covFiles(s,:)));
                covariates = [covariates X];
            elseif strcmp(e,'.mat')
                X = load(deblank(covFiles(s,:)));
                covariates = [covariates X.R];
            end        

            % - calcul des betas
            beta = data{k}'*covariates*pinv(covariates'*covariates);
            % - calcul des residus
            data{k} = data{k}' - beta*covariates';
            data{k} = data{k}';
        end
        
        % FILTERING
        if(opt_pre.filtering == 1)
            opt_filter.tr = TR;
            opt_filter.hp = 0.01;
            opt_filter.lp = 0.08;
            data{k} = niak_filter_tseries(data{k},opt_filter);
        end
    
    end
    
    data_all{s} = data;

    % Averaged time-courses
    tseries    = [];
    coord_rois = [];
    rois       = {};

    for k = 1:length(maskFiles)
        rois{k} = unique(maskc{k});
        rois{k} = rois{k}(1:end);

        rot   = V{k}.mat(1:3,1:3);
        trans = V{k}.mat(1:3,4);
        for j = 1:length(rois{k})
            idtmp = find(maskc{k}==rois{k}(j));
            tseries = [tseries mean(data{k}(:,idtmp),2)];
            
            [x,y,z] = ind2sub(V{k}.dim,idx{k}(idtmp));
            mean_coord = mean([x y z],1)';
            coord_rois = [coord_rois; (rot * mean_coord + trans)'] ;
        end
    end

    tseries = tseries';

    tseries_all = [tseries_all tseries];
    
end

