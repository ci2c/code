function ASL_PreprocessSPM8(data_path)

prefix{1}  = '';
prefix{2}  = 'r';
prefix{3}  = 'mean';

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
f = spm_select('FPList', fullfile(data_path,'RawEPI'), '^epi_.*\.nii$');
a = spm_select('FPList', fullfile(data_path,'Structural'), '^brain.*\.nii$');

%% REALIGN
%--------------------------------------------------------------------------
jobs{2}.spatial{1}.realign{1}.estwrite.data{1} = editfilenames(f,'prefix',prefix{1});

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


%% COREGISTRATION
%--------------------------------------------------------------------------

disp('no resampling');
jobs{3}.spatial{1}.coreg{1}.estimate.ref    = cellstr(a);
jobs{3}.spatial{1}.coreg{1}.estimate.source = editfilenames(f(1,:),'prefix',prefix{3});
jobs{3}.spatial{1}.coreg{1}.estimate.other  = editfilenames(f,'prefix',prefix{2});
jobs{3}.spatial{1}.coreg{1}.estimate.eoptions.cost_fun = 'nmi';
jobs{3}.spatial{1}.coreg{1}.estimate.eoptions.sep      = [4 2];
jobs{3}.spatial{1}.coreg{1}.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
jobs{3}.spatial{1}.coreg{1}.estimate.eoptions.fwhm     = [7 7];
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);

