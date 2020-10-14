function tseries = FMRI_ExtractRoiConfounds(epifile,roifile,motionfile,dim)

% Read motion parameters:
entercovariates = load(motionfile);

% erosion of mask
Vmask = conn_prepend('e',roifile);
ERODE = 1;
V0    = spm_vol(roifile); 
X0    = spm_read_vols(V0);
idx1  = find(X0(:)>.5);
[idxx,idxy,idxz] = ind2sub(size(X0),idx1);
idxt  = find(idxx>ERODE&idxx<size(X0,1)+1-ERODE&idxy>ERODE&idxy<size(X0,2)+1-ERODE&idxz>ERODE&idxz<size(X0,3)+1-ERODE);
for n1=1:length(idxt), 
    if (sum(sum(sum(X0(idxx(idxt(n1))+(-ERODE:ERODE),idxy(idxt(n1))+(-ERODE:ERODE),idxz(idxt(n1))+(-ERODE:ERODE))<.5,3),2),1))>1,
        idxt(n1)=0; 
    end; 
end
idxt     = idxt(idxt>0);
idx1     = idx1(idxt);
X1       = zeros(size(X0));X1(idx1)=1;
V0.fname = conn_prepend('e',roifile);
spm_write_vol(V0,X1);

% Extract time courses
mask         = [];
level        = 'rois';
scalinglevel = 'roi';
if dim>1,
    [tseries,namesroi,params]=conn_rex(epifile,Vmask,'summary_measure','eigenvariate','dims',dim,'conjunction_mask',mask,'level',level,'scaling',scalinglevel,'select_clusters',0,'covariates',entercovariates,'output_type','saverex');
else,
    [tseries,namesroi,params]=conn_rex(epifile,Vmask,'summary_measure','mean','conjunction_mask',mask,'level',level,'scaling',scalinglevel,'select_clusters',0,'covariates',[],'output_type','saverex');
end

[tseries,ok] = conn_nan(tseries);
tseries      = detrend(tseries,'constant');
