function [tS,data,indice_roi,nb_tir] = NRJ_HierarchicalCovariance(epiDir,prefepi,roiFiles,nb_tir,filter)

if nargin < 5
    filter = struct('do',true,'flag_mean',1,'tr',2,'hp',0.01,'lp',0.1);
end

for k = 1:length(roiFiles)
    [hdr,vol] = niak_read_vol(roiFiles{k});
    roi = unique(vol(:));
    if roi(1)==0
        roi = roi(2:end);
    end
    for j = 1:length(roi)
        idx{j} = find(vol(:)==roi(j));
    end
    indice_roi{k} = idx;
end

optn.type = 'mean_var';

for s = 1:length(epiDir)
    
    disp(['Loading subject ' epiDir{s}])
    
    epiFiles = cellstr(conn_dir(fullfile(epiDir{s},[prefepi '*.nii'])));
    data{s}  = [];
    
    % Concatenate runs
    tseries = [];
    for k = 1:length(epiFiles)    
        [hdr,vol] = niak_read_vol(epiFiles{k});
        dim       = size(vol);
        vol       = reshape(vol,dim(1)*dim(2)*dim(3),dim(4))';
        vol       = niak_normalize_tseries(vol,optn);
        tseries   = [tseries; vol];
    end

    % filtering
    if filter.do
        tseries = niak_filter_tseries(tseries,filter);
    end

    for k = 1:length(indice_roi)
        ts = [];
        for j = 1:length(indice_roi{k})
            ts = [ts mean(tseries(:,indice_roi{k}{j}),2)];
        end
        data{s} = [data{s} ts];       
    end
    
end

tS = donnees_vers_covariance_hierarchique(data,nb_tir);


