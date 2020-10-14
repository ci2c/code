function FMRI_PrestoPreprocessingBySPM12(epiDir,pref_epi,anatFile)

addpath('/home/global/matlab_toolbox/spm12b');

spm('defaults', 'FMRI');

spm_jobman('initcfg'); % SPM8 only

f = spm_select('FPList', epiDir, ['^' pref_epi '.*\.nii$']);
a = anatFile;

matlabbatch{1}.spm.util.reorient.srcfiles         = editfilenames(f,'prefix','');
matlabbatch{1}.spm.util.reorient.transform.transM = [0 0 1 0; -1 0 0 0; 0 -1 0 0; 0 0 0 1];
matlabbatch{1}.spm.util.reorient.prefix           = 'o';

matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Reorient Images: Reoriented Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

matlabbatch{3}.spm.spatial.coreg.estimate.ref = cellstr(anatFile);
matlabbatch{3}.spm.spatial.coreg.estimate.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estimate.other(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

matlabbatch{4}.spm.spatial.normalise.est.subj.vol = cellstr(anatFile);
matlabbatch{4}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
matlabbatch{4}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{4}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{4}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{4}.spm.spatial.normalise.est.eoptions.samp = 3;

matlabbatch{5}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{5}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Coregister: Estimate: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{5}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{5}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{5}.spm.spatial.normalise.write.woptions.interp = 4;

matlabbatch{6}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{6}.spm.spatial.smooth.fwhm = [6 6 6];
matlabbatch{6}.spm.spatial.smooth.dtype = 0;
matlabbatch{6}.spm.spatial.smooth.im = 0;
matlabbatch{6}.spm.spatial.smooth.prefix = 's';

matlabbatch{7}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{7}.spm.tools.art.sess.nscan(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{7}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{7}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{7}.spm.tools.art.sess.threshold.compflag = 1;
matlabbatch{7}.spm.tools.art.maskfile = {''};
matlabbatch{7}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{7}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{7}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{7}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{7}.spm.tools.art.closeflag = 1;
matlabbatch{7}.spm.tools.art.interp = 0;

matlabbatch{8}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Normalise: Estimate: Deformation (Subj 1)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','def'));
matlabbatch{8}.spm.spatial.normalise.write.subj.resample = cellstr(anatFile);
matlabbatch{8}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{8}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{8}.spm.spatial.normalise.write.woptions.interp = 4;


spm_jobman('run',matlabbatch);

