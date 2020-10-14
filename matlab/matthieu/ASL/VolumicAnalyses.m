clear all; close all;

% get, read in SPM.mat
%   mat = spm_select(1, 'mat', 'Select SPM.mat', [], '/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/FullFactorial_adapt_s3_zscore', 'SPM.mat');
  mat = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/FullFactorial_adapt_s3_zscore', 'SPM.mat');
  [p, nm, e, ~] = spm_fileparts(mat);
  load(mat);

% read in original spmT
  V_ori = spm_vol([p filesep 'spmT_0007.nii']);
  t_ori = spm_read_vols(V_ori);
  t_ori(isnan(t_ori)) = 0;

% % set, derive uncorrected threshold
%   thr = 0.001;
%   thr_uc = spm_u(thr,[1 SPM.xX.erdf],SPM.xCon(1).STAT);

% % set, derive FDR corrected threshold
%   thr = 0.05;
%   thr_uc = spm_uc_FDR(thr,[SPM.xCon(1).eidf SPM.xX.erdf],SPM.xCon(1).STAT,1,V_ori,0);

% % threshold original t-map
%   t_thr = zeros(size(t_ori));
%   idx = find(t_ori > thr_uc);
%   t_thr(idx) = t_ori(idx);

% % write out
%   V_ori.fname = [p filesep 'spmT_0001_thr_uc.img'];
%   spm_write_vol(V_ori, t_thr);

% Compute the FDR Q values
% slm.t    = 1 x v vector of test statistics, v=#vertices.
% slm.df   = degrees of freedom.
% slm.dfs  = 1 x v vector of optional effective degrees of freedom.
% slm.k    = #variates.
% mask     = 1 x v logical vector, 1=inside, 0=outside, 
%          = ones(1,v), i.e. the whole surface, by default.
slm.t = t_ori(:)';
slm.df   = SPM.xX.erdf;
slm.k   = 1;

mask_orig = spm_vol([p filesep SPM.VM.fname]);
mask = logical(spm_read_vols(mask_orig));
mask(isnan(mask)) = 0;
mask_v = mask(:)';

qval = SurfStatQ( slm , mask_v );

% Reformat Q-values volume image
Qval_thresh = double(zeros(1,length(qval.Q)));
idx = find(qval.Q <= 0.05);
Qval_thresh(idx) = (1-qval.Q(idx));
Qval_thresh = reshape(Qval_thresh,size(t_ori));

% write out
  V_ori.fname = [p filesep 'Qval_thresh.nii'];
  spm_write_vol(V_ori, Qval_thresh);
