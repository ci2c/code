function reslice_asl(data_path)

prefix{1}  = '';

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch

matlabbatch{1}.util{1}.cdir.directory = cellstr(data_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = spm_select('FPList', fullfile(data_path,'mri'), 'T1.nii');
a = spm_select('FPList', fullfile(data_path,'asl'), 'CBF.nii');

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{2}.spatial{1}.coreg{1}.write.ref = editfilenames(f,'prefix',prefix{1});
matlabbatch{2}.spatial{1}.coreg{1}.write.source = editfilenames(a,'prefix',prefix{1}) ;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.interp = 1;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.wrap = [0 0 0];
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.mask = 0;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.prefix = 'r';

save(fullfile(data_path,'batch_reslice.mat'),'matlabbatch');
spm_jobman('run',matlabbatch);
