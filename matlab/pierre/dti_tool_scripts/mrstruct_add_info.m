function mrstruct_add_info(mrstruct_name, bvecs_file, bvals_file)
%
% usage : mrstruct_add_info(MRSTRUCT_NAME, BVECS, BVALS)
%
%   Inputs :
%        MRSTRUCT_NAME   : path to the mrstruct .mat to complete (i.e.
%                          '/path/to/your/file/my_mrstruct.mat')
%
%       BVECS            : path to your bvecs file
%
%       BVALS            : path to your bvals file
%
% Complete a mrstruct with gradient info
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 3
    error('invalid usage');
end

B = dlmread(bvals_file);

matlabbatch{1}.dtijobs.ReadData.mrstruct.filename = {mrstruct_name};
matlabbatch{1}.dtijobs.ReadData.mrstruct.descheme = {bvecs_file};
matlabbatch{1}.dtijobs.ReadData.mrstruct.bvalue = max(B);
matlabbatch{1}.dtijobs.ReadData.mrstruct.nob0s = sum(B==0);

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});