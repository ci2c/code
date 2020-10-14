function ConvertAslToZscoreVol(datapath,file)

V_ori = spm_vol(fullfile(datapath,file));
V = spm_read_vols(V_ori);
V_vec = V(:);

TemplateMask_ori = spm_vol('/NAS/dumbo/matthieu/ASL_Epilepsy/template/T_templateMask.nii');
TemplateMask = spm_read_vols(TemplateMask_ori);
TemplateMask_vec = TemplateMask(:);

BrainMask_idx = find(TemplateMask_vec);
BrainExtract = V_vec(BrainMask_idx);
Z = zscore(BrainExtract);

V_vec(BrainMask_idx) = Z;
V_vec(~isfinite(V_vec))=0;

V_zscore = reshape(V_vec,size(V));

[pathstr,name,ext] = fileparts(fullfile(datapath,file));
V_ori.fname = fullfile(pathstr,[name '_zscore' ext]);
spm_write_vol(V_ori,V_zscore);