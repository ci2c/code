function FMRI_OutlierDetectionBySPM12(dataroot,prefix)

addpath('/home/global/matlab_toolbox/spm12b');

spm('defaults', 'FMRI');

%spm_jobman('initcfg'); % SPM8 only

f = spm_select('FPList', dataroot, ['^' prefix '.*\.nii$']);
mot = spm_select('FPList', dataroot, ['^rp_.*\.txt$']);

matlabbatch{1}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile = cellstr(mot);
matlabbatch{1}.spm.tools.art.sess.nscan = editfilenames(f,'prefix','');
matlabbatch{1}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{1}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{1}.spm.tools.art.sess.threshold.compflag = 1;
matlabbatch{1}.spm.tools.art.maskfile = {''};
matlabbatch{1}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{1}.spm.tools.art.closeflag = 1;
matlabbatch{1}.spm.tools.art.interp = 0;

spm_jobman('run',matlabbatch);
