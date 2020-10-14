function FMRI_StimMedianNormaliseEachEvent(fsdir,epifile,outdir)

% DIR='/NAS/tupac/protocoles/Stim_EEG_IRMf/FS53/s01_clement';
% EPIFILE = fullfile(outdir,'fmri.nii');

cur_path = pwd;
cd(outdir);

spm_get_defaults;
spm_jobman('initcfg');
matlabbatch = {};
    
[tempa,tempb,tempc]=fileparts(epifile);
epifiles{1} = cellstr(spm_select('ExtFPList',tempa,['^',tempb,tempc],1:1e4));
    
matlabbatch{end+1}.spm.spatial.realign.estwrite.data           = epifiles;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
matlabbatch{end}.spm.spatial.realign.estwrite.eoptions.weight  = '';
matlabbatch{end}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
matlabbatch{end}.spm.spatial.realign.estwrite.roptions.interp  = 4;
matlabbatch{end}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
matlabbatch{end}.spm.spatial.realign.estwrite.roptions.mask    = 1;
matlabbatch{end}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';

% Register EPI stats on T1
sfile={};
glmap=dir(fullfile(outdir,'glove','*.nii'));
p3map=dir(fullfile(outdir,'peak3','*.nii'));
p5map=dir(fullfile(outdir,'peak5','*.nii'));
p7map=dir(fullfile(outdir,'peak7','*.nii'));
p9map=dir(fullfile(outdir,'peak9','*.nii'));
for k = 1:length(glmap)
    sfile{end+1,1} = fullfile(outdir,'glove',glmap(k).name);
end
for k = 1:length(p3map)
    sfile{end+1,1} = fullfile(outdir,'peak3',p3map(k).name);
end
for k = 1:length(p5map)
    sfile{end+1,1} = fullfile(outdir,'peak5',p5map(k).name);
end
for k = 1:length(p7map)
    sfile{end+1,1} = fullfile(outdir,'peak7',p7map(k).name);
end
for k = 1:length(p9map)
    sfile{end+1,1} = fullfile(outdir,'peak9',p9map(k).name);
end
sfile

% Coregister EPI -> T1
matlabbatch{end+1}.spm.spatial.coreg.estimate.ref             = cellstr([fsdir '/mri/T1_las.nii']);
matlabbatch{end}.spm.spatial.coreg.estimate.source            = cellstr([outdir '/meanfmri.nii']);
matlabbatch{end}.spm.spatial.coreg.estimate.other             = sfile;
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

% Write EPI into MNI
matlabbatch{end+1}.spm.spatial.normalise.write.subj.def       = cellstr([fsdir '/mri/y_T1_las.nii']);
matlabbatch{end}.spm.spatial.normalise.write.subj.resample    = sfile;
matlabbatch{end}.spm.spatial.normalise.write.woptions.bb      = [-78 -112 -70; 78 76 85];
matlabbatch{end}.spm.spatial.normalise.write.woptions.vox     = [2 2 2];
matlabbatch{end}.spm.spatial.normalise.write.woptions.interp  = 4;
matlabbatch{end}.spm.spatial.normalise.write.woptions.prefix  = 'w';
    
spm_jobman('run',matlabbatch);

cd(cur_path);
