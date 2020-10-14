function create_mrstruct(REGEXP, mrstruct_name)
%
% usage : create_mrstruct(REGEXP, MRSTRUCT_NAME)
%
%   Inputs :
%        REGEXP          : regular expression of input volumes (i.e.
%                          '/path/to/your/vol/my_volumes_*.nii')
%
%        MRSTRUCT_NAME   : name of the output mrstruct file (i.e.
%                          '/output/path/my_mrstruct')
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 2
    error('invalid usage');
end

volume_list = SurfStatListDir(REGEXP);
volume_array = cell(length(volume_list), 1);
for i = 1 : length(volume_list)
    volume_array{i} = strcat(char(volume_list(i)), ',1');
end


out_path = dirname(mrstruct_name);
out_name = basename(mrstruct_name);

matlabbatch{1}.impexp_NiftiMrStruct.nifti2mrstruct.srcimgs = volume_array;
matlabbatch{1}.impexp_NiftiMrStruct.nifti2mrstruct.mrtype.series3D = 'series3D';
matlabbatch{1}.impexp_NiftiMrStruct.nifti2mrstruct.outchoice.outimg.outdir = {out_path};
matlabbatch{1}.impexp_NiftiMrStruct.nifti2mrstruct.outchoice.outimg.fname = out_name;

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});