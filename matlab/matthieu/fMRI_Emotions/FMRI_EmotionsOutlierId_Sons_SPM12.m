function FMRI_EmotionsOutlierId_Sons_SPM12(subjectdir)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

f = spm_select('FPList', fullfile(subjectdir,'spm','RawEPI'), '^epi_.*\.nii$');

%-----------------------------------------------------------------------
% Job saved on 22-Oct-2013 10:44:15 by cfg_util (rev $Rev: 4972 $)
% spm SPM - SPM12b (5593)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{end+1}.spm.tools.art.sess.motionfiletype.SPM.mvmtfile = cellstr(fullfile(subjectdir,'spm','RawEPI','rp_epi_0003.txt'));
matlabbatch{end}.spm.tools.art.sess.nscan = editfilenames(f,'prefix','r');
matlabbatch{end}.spm.tools.art.sess.threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{end}.spm.tools.art.sess.threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{end}.spm.tools.art.sess.threshold.compflag = 1;
matlabbatch{end}.spm.tools.art.maskfile = {''};
matlabbatch{end}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{end}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{end}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{end}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{end}.spm.tools.art.closeflag = 1;
matlabbatch{end}.spm.tools.art.interp = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(subjectdir,'spm','RawEPI','batch_OutlierIdentification.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
