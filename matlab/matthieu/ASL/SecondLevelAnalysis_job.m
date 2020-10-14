%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%-----------------------------------------------------------------------
% Job saved on 26-Aug-2014 14:05:07 by cfg_util (rev $Rev: 4972 $)
% spm SPM - SPM12b (5593)
% cfg_basicio BasicIO - Unknown
% dtijobs DTI tools - Unknown
% impexp_NiftiMrStruct NiftiMrStruct - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.factorial_design.dir = {'/NAS/dumbo/protocoles/ASL_Epilepsy/VolumeAnalysis_SPM12/ASL_S6PVC'};
%%
% matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = {
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BACS09PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BDCS10PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BDCS26/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BECS20/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BMCS01/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/BMCS14PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/CMCS27/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/CRCS17/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/CSCS28/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/DBCS06PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/DSCS18/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/EFCS08PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/HSCS05/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/LDCS16/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/LJCS02/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/LPCS04/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/MFCS23/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/MSCS19/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/NPCS24/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/PVCS25/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/RACS15PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/RBCS03/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/SSCS21/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/TNCS12PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/WECS07PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            };
% %%
% %%
% matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Bricout_Josette/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Damiens_Gerard/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Delforterie_Julien/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Dufay_Christine/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Gerard_Laurent/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Langlet_Laurent/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Legrand_MarieClaire/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Maokhamphiou_Melanie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Mezier_Julie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Mora_Sylvia/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Odot_Angelique/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Ouahlima_Arsene/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Pais_CarlaMaria/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Pospieszny_Jeanne-Marie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Speer_Celine/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Vernieuwe_Frederic/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Witkowski_Jacqueline/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Mercier_Sylvain/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Raccary_Josie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Copin_Sophie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Humez_Xavier/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Gilliot_Aurelie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Leroy_Jeanne/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Hagnere_Marine/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Amphyon_Chantal/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/Caron_Nathalie/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/CNEG08/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/CPED05/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/DCEG19PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/DGEG09/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/DJEG13/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/LHEG23/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/LLEG12/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/MJEG02/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/MMEG03/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/MSEG07/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/OAEG01/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/VGEG10/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            '/NAS/dumbo/protocoles/ASL_Epilepsy/WJEG22PB/ASLProcessing/ASL_S_CBFWToTemplate.nii,1'
%                                                            };
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans1 = {
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BACS09PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BDCS10PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BDCS26/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BECS20/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BMCS01/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/BMCS14PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/CMCS27/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/CRCS17/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/CSCS28/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/DBCS06PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/DSCS18/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/EFCS08PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/HSCS05/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/LDCS16/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/LJCS02/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/LPCS04/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/MFCS23/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/MSCS19/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/NPCS24/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/PVCS25/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/RACS15PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/RBCS03/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/SSCS21/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/TNCS12PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/WECS07PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           };
%%
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.scans2 = {
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Bricout_Josette/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Damiens_Gerard/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Delforterie_Julien/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Deletrez_Corinne/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Dufay_Christine/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Gerard_Laurent/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Ghesquiere_Christine/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Langlet_Laurent/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Legrand_MarieClaire/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Maokhamphiou_Melanie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Mezier_Julie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Mora_Sylvia/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Odot_Angelique/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Ouahlima_Arsene/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Pais_CarlaMaria/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Pospieszny_Jeanne-Marie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Speer_Celine/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Vernieuwe_Frederic/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Witkowski_Jacqueline/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Mercier_Sylvain/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Raccary_Josie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Copin_Sophie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Humez_Xavier/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Gilliot_Aurelie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Leroy_Jeanne/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Hagnere_Marine/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Amphyon_Chantal/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/Caron_Nathalie/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/DGEG09/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/DJEG13/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/LHEG23/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/LLEG12/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/MJEG02/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/MMEG03/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/MSEG07/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/OAEG01/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/VGEG10/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           '/NAS/dumbo/protocoles/ASL_Epilepsy/WJEG22PB/ASLProcessing/Volume/ASL_S6PVC_MeanCBFWToTemplate.nii,1'
                                                           };
%%
matlabbatch{1}.spm.stats.factorial_design.des.t2.dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.t2.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'ControlsVsTLE';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 0;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'FWE';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.mask = struct('contrasts', {}, 'thresh', {}, 'mtype', {});
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.print = 'ps';
matlabbatch{4}.spm.stats.results.write.none = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',matlabbatch);
