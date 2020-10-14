function [roi,labels] = QSM_GetValueFromHCPParcellation(dscalarFile,outFile)

% usage : Conn = QSM_GetValueFromHCPParcellation(dscalarFile,outFile)
%
% Inputs :
%    dscalarFile       : nii file of scalar values
%    outfile           : path to mat file for results
%
% Output :
%    roi               : qsm values in each parcel
%    labels            : labels of each parcel
%
% Renaud Lopes @ CHRU Lille, May 2018



%% Parcellation files

parc_lh   = '/NAS/tupac/renaud/HCP/Glasser_et_al_2016_HCP_MMP1.0_RVVG/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii';
parc_rh   = '/NAS/tupac/renaud/HCP/Glasser_et_al_2016_HCP_MMP1.0_RVVG/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii';
alllabels = textread('/NAS/tupac/renaud/HCP/MMP_Parcellation/fsaverage/labels.txt','%s');


%% Read dscalar file

% Read dscalar file
map = ft_read_cifti(dscalarFile);

% Remove nan values
idkeep = find(~isnan(map.x32k_fs_lr(:,1)));
map.x32k_fs_lr = map.x32k_fs_lr(idkeep,:);
map.brainstructure = map.brainstructure(idkeep,1);
map.pos = map.pos(idkeep,:);
map.idkeep = idkeep;


%% Extract qsm values

% Extract time series from left cortex
idx_lh = find(map.brainstructure==1);
value_lh = map.x32k_fs_lr(idx_lh,:);
keep_lh = map.idkeep(idx_lh,1);

% Extract time series from right cortex
idx_rh  = find(map.brainstructure==2);
value_rh = map.x32k_fs_lr(idx_rh,:);
keep_rh = map.idkeep(idx_rh,1);

% Extract time series from subcortical structures
labels_sc = {'ACCUMBENS_LEFT' 'ACCUMBENS_RIGHT' 'AMYGDALA_LEFT' 'AMYGDALA_RIGHT' 'CAUDATE_LEFT' 'CAUDATE_RIGHT' 'HIPPOCAMPUS_LEFT' 'HIPPOCAMPUS_RIGHT' 'PALLIDUM_LEFT' 'PALLIDUM_RIGHT' 'PUTAMEN_LEFT' 'PUTAMEN_RIGHT' 'THALAMUS_LEFT' 'THALAMUS_RIGHT'};
for k = 1:length(labels_sc)
    idlabel = find(strcmp(map.brainstructurelabel,labels_sc{k}));
    idx_sc = find(map.brainstructure==idlabel);
    value_sc{k,1} = map.x32k_fs_lr(idx_sc,:);
    keep_sc{k,1} = map.idkeep(idx_sc,1);
end



%% Mean time-serie for each parcel

plh = ft_read_cifti(parc_lh);
sizelh = size(plh.x1,1);
plh.x1(isnan(plh.x1))=0;
rois_lhinit = unique(plh.x1);
plh.x1 = plh.x1(keep_lh,1);
plh.brainstructure = plh.brainstructure(keep_lh,1);
plh.pos = plh.pos(keep_lh,1);

prh = ft_read_cifti(parc_rh);
prh.x1(isnan(prh.x1))=0;
rois_rhinit = unique(prh.x1);
prh.x1 = prh.x1(keep_rh-sizelh,1);
prh.brainstructure = prh.brainstructure(keep_rh-sizelh,1);
prh.pos = prh.pos(keep_rh-sizelh,1);

labels = {};
roi = {};

% Compute mean
num_r = 0;
% Left Cortical
rois_lh = unique(plh.x1);
if length(rois_lh) == length(rois_lhinit)-1
    
    for k = 1:length(rois_lh)

        num_r = num_r+1;
        idx = find(plh.x1==rois_lh(k));
        roi{end+1,1} = value_lh(idx,:);
%         ts_conn(:,num_r) = mean(value_lh(idx,:),1)';
%         labels{end+1,1} = ['lh_' num2str(k,'%10.3i')];
        labels{end+1,1} = alllabels{k};

    end
    
else
    
    sprintf('not the same number of rois in left cortical')
    return;
    
end


% Right Cortical
rois_rh = unique(prh.x1);
if length(rois_rh) == length(rois_rhinit)-1
    
    for k = 1:length(rois_rh)

        num_r = num_r+1;
        idx = find(prh.x1==rois_rh(k));
        roi{end+1,1} = value_rh(idx,:);
%         ts_conn(:,num_r) = mean(ts_rh(idx,:),1)';
%         labels{end+1,1} = ['rh_' num2str(k,'%10.3i')];
        labels{end+1,1} = alllabels{k+length(rois_lh)};

    end
    
else
    
    sprintf('not the same number of rois in left cortical')
    return;
    
end


% Subcortical
for k = 1:length(value_sc)
    
    num_r = num_r+1;
    roi{end+1,1} = value_sc{k};
%     ts_conn(:,num_r) = mean(ts_sc{k},1)';
%     labels{end+1,1} = labels_sc{k};
    labels{end+1,1} = alllabels{k+length(rois_lh)+length(rois_rh)};
    
end



%% Save results

save(outFile,'roi','labels');

