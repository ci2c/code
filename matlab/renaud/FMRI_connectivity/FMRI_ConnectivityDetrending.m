function tseries = FMRI_ConnectivityDetrending(whiteFile,csfFile,epiFile,motionFile,dim)

ERODE = 1;

% Erosion White mask
V0   = spm_vol(whiteFile); % mask
X0   = spm_read_vols(V0);
idx1 = find(X0(:)>.5);
[idxx,idxy,idxz] = ind2sub(size(X0),idx1);
idxt = find(idxx>ERODE&idxx<size(X0,1)+1-ERODE&idxy>ERODE&idxy<size(X0,2)+1-ERODE&idxz>ERODE&idxz<size(X0,3)+1-ERODE);

for n1 = 1:length(idxt), 
    if (sum(sum(sum(X0(idxx(idxt(n1))+(-ERODE:ERODE),idxy(idxt(n1))+(-ERODE:ERODE),idxz(idxt(n1))+(-ERODE:ERODE))<.5,3),2),1))>1,
        idxt(n1)=0; 
    end; 
end
idxt     = idxt(idxt>0);
idx1     = idx1(idxt);
X1       = zeros(size(X0));X1(idx1)=1;
wmFile   = conn_prepend('e',whiteFile);
V0.fname = wmFile;
spm_write_vol(V0,X1);

% Erosion CSF mask
V0   = spm_vol(csfFile); % mask
X0   = spm_read_vols(V0);
idx1 = find(X0(:)>.5);
[idxx,idxy,idxz] = ind2sub(size(X0),idx1);
idxt = find(idxx>ERODE&idxx<size(X0,1)+1-ERODE&idxy>ERODE&idxy<size(X0,2)+1-ERODE&idxz>ERODE&idxz<size(X0,3)+1-ERODE);

for n1 = 1:length(idxt), 
    if (sum(sum(sum(X0(idxx(idxt(n1))+(-ERODE:ERODE),idxy(idxt(n1))+(-ERODE:ERODE),idxz(idxt(n1))+(-ERODE:ERODE))<.5,3),2),1))>1,
        idxt(n1)=0; 
    end; 
end
idxt = idxt(idxt>0);
idx1 = idx1(idxt);
X1   = zeros(size(X0));X1(idx1)=1;
csffile  = conn_prepend('e',csfFile);
V0.fname = csffile;
spm_write_vol(V0,X1);

% Extract time courses
entercovariates = load(motionFile);
mask         = [];
level        = 'rois';
scalinglevel = 'roi';

rois = {wmFile,csffile};

for k = 1:length(rois)
    
    if dim>1,
        [tseries{k},namesroi,params] = conn_rex(epiFile,rois{k},'summary_measure','eigenvariate','dims',dim,'conjunction_mask',mask,'level',level,'scaling',scalinglevel,'select_clusters',0,'covariates',entercovariates,'output_type','saverex');
    else,
        [tseries{k},namesroi,params] = conn_rex(epiFile,rois{k},'summary_measure','mean','conjunction_mask',mask,'level',level,'scaling',scalinglevel,'select_clusters',0,'covariates',[],'output_type','saverex');
    end

    [tseries{k},ok] = conn_nan(tseries{k});
    tseries{k}      = detrend(tseries{k},'constant');
    
end