  function [mask] = bpm_mask_surf(CP1, BPM, medial_wall);
% __________________________________________________________%
% This function generate a binary brain mask using the individual 
% information from the main modality. The mask is the intersection 
% of all individual masks created by thresholding the individual
% datasets at some %thr of the mean signal.
%___________________________________________________________%
% Input Parameter
%  CP1  - Cell array containing the names of the left and right
%         subjects data sets
%  thr  - a threshold in %
%         subjects data sets
%  medial_wall  - Mask of the medial wall
%___________________________________________________________%
% Output Parameter
% mask_file_name   - path and name of the resulting mask
%__________________________________________________________%


% ------- Computing the intersection masArrayk -------------------- %

[rep,fich,ext] = fileparts(CP1{1,1});
data_lh = SurfStatReadData(CP1{1,1});
nbleft   = length(data_lh);
Sv = SurfStatReadData(CP1(1,:));
inter_mask = zeros(1,size(Sv,2));

for n = 1:size(CP1,1)
    Sv = SurfStatReadData(CP1(n,:));
    Sv(isnan(Sv)) = 0;
    mean_signal = mean(Sv(~medial_wall));
    if isfield(BPM,'mask_pthr')
        mask_subj   = abs(Sv(~medial_wall)) > abs(mean_signal)*BPM.mask_pthr ;
    else
        mask_subj   = abs(Sv(~medial_wall)) > BPM.mask_athr ;
    end        
    inter_mask(~medial_wall) = inter_mask(~medial_wall) + (mask_subj>0);
end

mask = (inter_mask > size(CP1,1)-3);
mask_lh = mask(1:nbleft);
mask_rh = mask(nbleft+1:end);
SurfStatWriteData(fullfile(BPM.result_dir,['lh.mask' ext]), mask_lh , 'b' );
SurfStatWriteData(fullfile(BPM.result_dir,['rh.mask' ext]), mask_rh , 'b' );

% BPM.mask = fullfile(BPM.result_dir,['mask' ext]) ;

    

