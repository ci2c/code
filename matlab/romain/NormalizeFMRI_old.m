function NormalizeFMRI(indir,i)

spm_get_defaults;
spm('Defaults','fMRI');
spm_jobman('initcfg');
clear matlabbatch
matlabbatch={}; 
cd '/NAS/dumbo/protocoles/IRMf_memoire/FS5.3/'
matlabbatch{i}.spm.spatial.normalise.estwrite.subj.vol = cellstr(fullfile(indir,'fmri/mot/T1_las.nii'));
matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{1,1} = fullfile(indir,'fmri/mot/T1_las.nii');

if exist(fullfile(indir,'fmri/mot/con_0001.img'), 'file')
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{2,1} = fullfile(indir,'fmri/mot/con_0001.img');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{3,1} = fullfile(indir,'fmri/mot/con_0002.img');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{4,1} = fullfile(indir,'fmri/mot/con_0003.img');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{5,1} = fullfile(indir,'fmri/visage/con_0001.img');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{6,1} = fullfile(indir,'fmri/visage/con_0002.img');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{7,1} = fullfile(indir,'fmri/visage/con_0003.img');
elseif exist(fullfile(indir,'fmri/mot/con_0001.nii'), 'file')
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{2,1} = fullfile(indir,'fmri/mot/con_0001.nii');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{3,1} = fullfile(indir,'fmri/mot/con_0002.nii');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{4,1} = fullfile(indir,'fmri/mot/con_0003.nii');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{5,1} = fullfile(indir,'fmri/visage/con_0001.nii');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{6,1} = fullfile(indir,'fmri/visage/con_0002.nii');
    matlabbatch{i}.spm.spatial.normalise.estwrite.subj.resample{7,1} = fullfile(indir,'fmri/visage/con_0003.nii');
else
    return;
end

matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.biasreg = 0.0001;
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.biasfwhm = 60;
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.tpm = {'/home/global/matlab_toolbox/spm12/tpm/TPM.nii'};
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.affreg = 'mni';
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.fwhm = 0;
matlabbatch{i}.spm.spatial.normalise.estwrite.eoptions.samp = 3;
matlabbatch{i}.spm.spatial.normalise.estwrite.woptions.bb = [-78 -112 -70; 78 76 85];
matlabbatch{i}.spm.spatial.normalise.estwrite.woptions.vox = [2 2 2];
matlabbatch{i}.spm.spatial.normalise.estwrite.woptions.interp = 4;

if ~isempty(matlabbatch),
    spm_jobman('run',matlabbatch);
end
