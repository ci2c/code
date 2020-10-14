function ASL_Reslice(t1File,cbfFile)

prefix{1}  = '';

spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear matlabbatch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = t1File;
a = cbfFile;

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{2}.spatial{1}.coreg{1}.write.ref             = editfilenames(f,'prefix',prefix{1});
matlabbatch{2}.spatial{1}.coreg{1}.write.source          = editfilenames(a,'prefix',prefix{1}) ;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.interp = 1;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.wrap   = [0 0 0];
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.mask   = 0;
matlabbatch{2}.spatial{1}.coreg{1}.write.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);