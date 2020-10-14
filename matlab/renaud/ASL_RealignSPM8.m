function ASL_RealignSPM8(data_path,prefix)


%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear jobs
jobs{1}.util{1}.cdir.directory = cellstr(data_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = spm_select('FPList', data_path, ['^' prefix '.*\.nii$']);

%% REALIGN
%--------------------------------------------------------------------------
jobs{2}.spatial{1}.realign{1}.estwrite.data{1} = editfilenames(f,'prefix','');

jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.quality = 0.9;
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.sep     = 4;
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.fwhm    = 5;
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.rtm     = 1;
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.interp  = 2;
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.wrap    = [0 0 0];
jobs{2}.spatial{1}.realign{1}.estwrite.eoptions.weight  = '';
jobs{2}.spatial{1}.realign{1}.estwrite.roptions.which   = [2 1];
jobs{2}.spatial{1}.realign{1}.estwrite.roptions.interp  = 4;
jobs{2}.spatial{1}.realign{1}.estwrite.roptions.wrap    = [0 0 0];
jobs{2}.spatial{1}.realign{1}.estwrite.roptions.mask    = 1;
jobs{2}.spatial{1}.realign{1}.estwrite.roptions.prefix  = 'r';
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spm_jobman('run',jobs);