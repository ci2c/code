function [tS,data,indice_roi,nb_tir,dataNN] = HierarchicCovariance(epiDir,prefepi,roiFiles,nb_tir,filter)

if nargin < 5
    filter = struct('do',true,'flag_mean',1,'tr',2,'hp',0.01,'lp',0.1);
end

indice_roi =[];
for k = 1:length(roiFiles)
    [hdr,vol] = niak_read_vol(roiFiles{k});
    roi = unique(vol(:));
    idx=[];
    if roi(1)==0
        roi = roi(2:end);
    end
    for j = 1:length(roi)
        idx{j} = find(vol(:)==roi(j));
    end
    indice_roi{k} = idx;
end

optn.type = 'mean_var';

dataNN = zeros(1,length(epiDir));

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
        % Reset voxels outside of the brain
        vol(isnan(vol)) = 0;
        vol       = niak_normalize_tseries(vol,optn);
        tseries   = [tseries; vol];
    end
    
    indice_network = indice_roi;
    % Supress voxels from ROIs if outside the brain (mean time-series == 0)
    Tmeans = mean(tseries,1);
    for k = 1:length(indice_network)
        for j = 1:length(indice_network{k})
            ind_null = find(Tmeans(indice_network{k}{j})==0);
            indice_network{k}{j}(ind_null) = [];
        end
    end

    % filtering
    if filter.do
        tseries = niak_filter_tseries(tseries,filter);
    end

    for k = 1:length(indice_network)
        ts = [];
        for j = 1:length(indice_network{k})
            ts = [ts mean(tseries(:,indice_network{k}{j}),2)];
        end
        data{s} = [data{s} ts];       
    end
    
    if length(find(isnan(data{s})))>0
        dataNN(s)=1;
    end
end

tS = donnees_vers_covariance_hierarchique(data,nb_tir);


