function DARTEL_NormaliseToMNI(FieldFile,FileList,TemplateFile,VoxSize,BoundingBox)

% Inputs:
%     - FieldFile   : Deformation field ('u_*')
%     - input       : folder with data
%     - prefix      : prefix of data
%     - TemplateFile : Template file 
% Defaults:
%     - VoxSize     : Voxel size ([3 3 3])
%     - BoundingBox : [-90 -126 -72;90 90 108]

if nargin < 5  
    VoxSize = [3 3 3];
end
if nargin < 6
    BoundingBox = [-90 -126 -72;90 90 108];
end

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

matlabbatch{1,1}.spm.tools.dartel.mni_norm.template = {TemplateFile};

matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images = FileList;

matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield = {FieldFile};

matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm     = [0 0 0];
matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve = 0;
matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb       = BoundingBox;
matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox      = VoxSize;

fprintf(['Running DARTEL: Create Template.\n']);
spm_jobman('run',matlabbatch);

