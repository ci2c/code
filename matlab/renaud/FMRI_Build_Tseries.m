function [tseries,std_tseries,labels_roi] = FMRI_Build_Tseries(vol,mask,opt)
% Extract the mean and std of time series of in multiple ROI 
% from a 3D+t dataset.
%
% [TSERIES,STD_TSERIES,LABELS_ROI] = FMRI_BUILD_TSERIES(VOL,MASK,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% VOL       
%   (3D+t array or timeXspace array) the fMRI data. 
%
% MASK      
%   (3D volume or vector) mask or ROI coded with integers. 
%   ROI #I is defined by MASK==I
%
% OPT       
%   (structure, optional) each field of OPT is used to specify an 
%   option. If a field was not specified, then the default value is
%   assumed.
%
%   CORRECTION
%      (structure, default CORRECTION.TYPE = 'none') the temporal 
%      normalization to apply on the individual time series before 
%      averaging in each ROI. See OPT in NIAK_NORMALIZE_TSERIES.
%
%   FLAG_ALL
%     (boolean, default false) if FLAG_ALL is true, the time series
%     of all voxels found in MASK>0 will be sent in TSERIES, rather
%     than the mean time series.
%
% _________________________________________________________________________
% OUTPUTS:
%
% TSERIES   
%   (array) TSERIES(:,I) is the mean time series in the ROI MASK==I.
%   In this case, STD_TSERIES is a sparse matrix full of zeros.
%
% STD_TSERIES   
%   (arrays) STD_TSERIES(:,I) is the standard deviation of the time 
%   series in the ROI MASK==I.
%
% LABELS_ROI
%   (vector) LABELS_ROI is the labels of the Ith ROI.
%

%% Setting up default inputs
opt_norm.type = 'none';
gb_name_structure = 'opt';
gb_list_fields = {'flag_all','correction'};
gb_list_defaults = {false,opt_norm};
niak_set_defaults

%% Extracting the labels of regions and reorganizing the data 
if ndims(vol)>2
    tseries_mask = niak_vol2tseries(vol,mask>0);
    mask_v = mask(mask>0);
else
    tseries_mask = vol(:,mask>0);
    mask_v = mask(mask>0);
end

tseries_mask(isnan(tseries_mask))=0;
x=find(abs(sum(tseries_mask,1))>0);
mask_v = mask_v(x);
tseries_mask = tseries_mask(:,x);

labels_roi = unique(mask_v(:));
labels_roi = labels_roi(labels_roi~=0);
nb_rois = length(labels_roi);

tseries_mask = niak_normalize_tseries(tseries_mask,opt.correction);

if flag_all
    tseries = tseries_mask;
    std_tseries = sparse(size(tseries));
else
    tseries = zeros([size(tseries_mask,1) nb_rois]);
    std_tseries = zeros([size(tseries_mask,1) nb_rois]);    

    for num_r = 1:nb_rois
        tseries(:,num_r) = mean(tseries_mask(:,mask_v == labels_roi(num_r)),2);
        std_tseries(:,num_r) = std(tseries_mask(:,mask_v == labels_roi(num_r)),0,2);
    end
end