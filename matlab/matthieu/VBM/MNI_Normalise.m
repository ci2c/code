function MNI_Normalise(template_file,varargin)

spm_jobman('initcfg'); % SPM8 only

NbImgType = size(varargin,2)/2;

CellFF = cell(NbImgType,1);
CellGM = cell(NbImgType,1);

index=1;
for k= 1 : NbImgType 
    t=varargin(k);
    CellFF{index,1} =t{1};
    clear t
    t=varargin(k+NbImgType);
    CellGM{index,1} = t{1};
    clear t
    index=index+1;
end

mat_voxel_size = [NaN NaN NaN];
mat_bounding_box = [NaN NaN NaN
                    NaN NaN NaN];
mat_fwhm = [8 8 8];

matlabbatch{1}.spm.tools.dartel.mni_norm.template = {template_file};
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.flowfields = CellFF;
matlabbatch{1}.spm.tools.dartel.mni_norm.data.subjs.images = {CellGM}';
matlabbatch{1}.spm.tools.dartel.mni_norm.vox = mat_voxel_size;
matlabbatch{1}.spm.tools.dartel.mni_norm.bb = mat_bounding_box;
matlabbatch{1}.spm.tools.dartel.mni_norm.preserve = 1;
matlabbatch{1}.spm.tools.dartel.mni_norm.fwhm = mat_fwhm;

fprintf('MNI_Normalise Setup: OK');
fprintf('\n')

spm('defaults', 'FMRI');
spm_jobman('run',matlabbatch);

