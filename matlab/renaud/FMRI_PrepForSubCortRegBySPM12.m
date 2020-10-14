function FMRI_PrepForSubCortRegBySPM12(dataroot,anat,TR,nslices)

addpath('/home/global/matlab_toolbox/spm12b');

spm('defaults', 'FMRI');

%spm_jobman('initcfg'); % SPM8 only

f = spm_select('FPList', dataroot, '^epi_.*\.nii$');
a = anat;

matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = editfilenames(f,'prefix','');
                                                    
%%
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

matlabbatch{2}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
matlabbatch{2}.spm.temporal.st.nslices = nslices;
matlabbatch{2}.spm.temporal.st.tr = TR;
matlabbatch{2}.spm.temporal.st.ta = TR-(TR/nslices);
matlabbatch{2}.spm.temporal.st.so = 1:nslices;
matlabbatch{2}.spm.temporal.st.refslice = 1;
matlabbatch{2}.spm.temporal.st.prefix = 'a';

matlabbatch{3}.spm.spatial.coreg.estwrite.ref = cellstr(a);
matlabbatch{3}.spm.spatial.coreg.estwrite.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{3}.spm.spatial.coreg.estwrite.other(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{3}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{3}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

matlabbatch{4}.spm.spatial.smooth.data(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{4}.spm.spatial.smooth.fwhm = [3 3 3];
matlabbatch{4}.spm.spatial.smooth.dtype = 0;
matlabbatch{4}.spm.spatial.smooth.im = 0;
matlabbatch{4}.spm.spatial.smooth.prefix = 's1';

matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{5}.spm.spatial.smooth.fwhm = [3 3 3];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.im = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's2';

matlabbatch{6}.spm.spatial.normalise.est.subj.vol = cellstr(a);
matlabbatch{6}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{6}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{6}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
matlabbatch{6}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{6}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{6}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{6}.spm.spatial.normalise.est.eoptions.samp = 3;

matlabbatch{7}.spm.spatial.normalise.est.subj.vol(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{7}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{7}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{7}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
matlabbatch{7}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{7}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{7}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{7}.spm.spatial.normalise.est.eoptions.samp = 3;

matlabbatch{8}.spm.spatial.coreg.write.ref = cellstr(a);
matlabbatch{8}.spm.spatial.coreg.write.source(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));
matlabbatch{8}.spm.spatial.coreg.write.roptions.interp = 4;
matlabbatch{8}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{8}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{8}.spm.spatial.coreg.write.roptions.prefix = 'r';

matlabbatch{9}.spm.spatial.normalise.est.subj.vol(1) = cfg_dep('Coregister: Reslice: Resliced Images', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{9}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
matlabbatch{9}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
matlabbatch{9}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
matlabbatch{9}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
matlabbatch{9}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{9}.spm.spatial.normalise.est.eoptions.fwhm = 0;
matlabbatch{9}.spm.spatial.normalise.est.eoptions.samp = 3;

matlabbatch{10}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile(1) = cfg_dep('Realign: Estimate & Reslice: Realignment Param File (Sess 1)', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rpfile'));
matlabbatch{10}.spm.tools.art.sess.nscan(1) = cfg_dep('Coregister: Estimate & Reslice: Coregistered Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','cfiles'));
matlabbatch{10}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{10}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{10}.spm.tools.art.sess.threshold.compflag = 1;
matlabbatch{10}.spm.tools.art.maskfile = {''};
matlabbatch{10}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{10}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{10}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{10}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{10}.spm.tools.art.closeflag = 1;
matlabbatch{10}.spm.tools.art.interp = 0;

spm_jobman('run',matlabbatch);
