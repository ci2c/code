function FMRI_DartelNormaliseToMNI(fsdir,subjs,datafolder,icafolder,TemplateFile)

BoundingBox     = [-90 -126 -72;90 90 108];
VoxSize         = [3 3 3];

for k = 1:length(subjs)
    
    spm('Defaults','fMRI');

    spm_jobman('initcfg'); % SPM8 only
    
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {TemplateFile};
    
    DirImg    = dir(fullfile(fsdir,subjs{k},datafolder,'u_*'));
    FieldFile = fullfile(fsdir,subjs{k},datafolder,DirImg(1).name);
    
    FileList = [];
    DirImg = dir(fullfile(fsdir,subjs{k},datafolder,icafolder,'tMap*.nii'));
    for j = 1:length(DirImg)
        FileList = [FileList;{fullfile(fsdir,subjs{k},datafolder,icafolder,DirImg(j).name)}];
    end
    
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images = FileList;

    matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield = {FieldFile};

    matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = BoundingBox;
    matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = VoxSize;

    fprintf(['Running DARTEL: Create Template.\n']);
    spm_jobman('run',matlabbatch);
    
end