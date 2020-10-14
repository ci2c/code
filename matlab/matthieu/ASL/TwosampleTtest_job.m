%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%-----------------------------------------------------------------------
% Job saved on 27-Feb-2015 15:23:08 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
% dtijobs DTI tools - Unknown
% impexp_NiftiMrStruct NiftiMrStruct - Unknown
%-----------------------------------------------------------------------
matlabbatch{end+1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/VolumeAnalysis_SPM12/TwoSampleTtest_adapt_s3'};
matlabbatch{end}.spm.stats.factorial_design.des.t2.scans1 = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/BDCS26/asl/Volumetric_Analyses/s3_cbf_s.nii,1'};
matlabbatch{end}.spm.stats.factorial_design.des.t2.scans2 = {'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Vilain_Serge/asl/Volumetric_Analyses/cbf_s.nii,1'};
matlabbatch{end}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{end}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{end}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{end}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{end}.spm.stats.factorial_design.cov.c = [1
                                                   0
                                                   3
                                                   6
                                                   5
                                                   8];
matlabbatch{end}.spm.stats.factorial_design.cov.cname = 'boulette';
matlabbatch{end}.spm.stats.factorial_design.cov.iCFI = 1;
matlabbatch{end}.spm.stats.factorial_design.cov.iCC = 1;
matlabbatch{end}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{end}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{end}.spm.stats.factorial_design.masking.em = {'/NAS/dumbo/matthieu/ASL_Epilepsy/template/T_templateMask.nii,1'};
matlabbatch{end}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{end}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{end+1}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{end}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{end+1}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{end}.spm.stats.con.consess{1}.tcon.name = 'CS > LTLE';
matlabbatch{end}.spm.stats.con.consess{1}.tcon.weights = [1 -1 0 0];
matlabbatch{end}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.name = 'LTLE > CS';
matlabbatch{end}.spm.stats.con.consess{2}.tcon.weights = [-1 1 0 0];
matlabbatch{end}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{end}.spm.stats.con.delete = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);