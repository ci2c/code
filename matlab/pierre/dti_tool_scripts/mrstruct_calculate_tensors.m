function mrstruct_calculate_tensors(mrstruct_name, threshold)
%
% usage : mrstruct_calculate_tensors(MRSTRUCT_NAME [, THRESHOLD])
%
%   Inputs :
%        MRSTRUCT_NAME   : path to the mrstruct .mat to complete (i.e.
%                          '/path/to/your/file/my_mrstruct.mat')
%
%   Option :
%        THRESHOLD       : tensor calculation threshold (default : 40)
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 1 & nargin ~= 2
    error('invalid usage');
end

if nargin == 1
    threshold = 40;
end
    
matlabbatch{1}.dtijobs.tensor.filename = {mrstruct_name};
matlabbatch{1}.dtijobs.tensor.singleslice = 0;
matlabbatch{1}.dtijobs.tensor.threshold = threshold;

inputs = cell(0, 1);
spm('defaults', 'PET');
spm_jobman('serial', matlabbatch, '', inputs{:});