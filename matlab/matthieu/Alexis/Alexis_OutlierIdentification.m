function Alexis_OutlierIdentification(inputdir)

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

f1 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run1'), '^epi_.*\.nii$');
f2 = spm_select('FPList', fullfile(inputdir,'spm','RawEPI','run2'), '^epi_.*\.nii$');

%-----------------------------------------------------------------------
% Job saved on 22-Oct-2013 10:44:15 by cfg_util (rev $Rev: 4972 $)
% spm SPM - SPM12b (5593)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.tools.art.sess(1).motionfiletype.SPM.mvmtfile = cellstr(fullfile(inputdir,'spm','RawEPI','run1','rp_aepi_0005.txt'));
matlabbatch{1}.spm.tools.art.sess(1).nscan = editfilenames(f1,'prefix','ra');
matlabbatch{1}.spm.tools.art.sess(1).threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{1}.spm.tools.art.sess(1).threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{1}.spm.tools.art.sess(1).threshold.compflag = 1;
matlabbatch{1}.spm.tools.art.sess(2).motionfiletype.SPM.mvmtfile = cellstr(fullfile(inputdir,'spm','RawEPI','run2','rp_aepi_0005.txt'));
matlabbatch{1}.spm.tools.art.sess(2).nscan = editfilenames(f2,'prefix','ra');
matlabbatch{1}.spm.tools.art.sess(2).threshold.globalsig.globaldiff.zthresh = 3;
matlabbatch{1}.spm.tools.art.sess(2).threshold.motionsig.motiondiff.mvmt_diff_thresh = 1;
matlabbatch{1}.spm.tools.art.sess(2).threshold.compflag = 1;
matlabbatch{1}.spm.tools.art.maskfile = {''};
matlabbatch{1}.spm.tools.art.savefiles.motionflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.analysisflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.voxvarflag = 1;
matlabbatch{1}.spm.tools.art.savefiles.SNRflag = 1;
matlabbatch{1}.spm.tools.art.closeflag = 1;
matlabbatch{1}.spm.tools.art.interp = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(inputdir,'batch_OutlierIdentification.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
