function [pipeline,opt] = Protocol_sica(DirPathForNiak,opt)
%
% _________________________________________________________________________
% SUMMARY NIAK_DEMO_FMRI_PREPROCESS
%
% This function demonstrates how to use NIAK_PIPELINE_FMRI_PREPROCESS.
%
% SYNTAX:
% [PIPELINE,OPT] = NIAK_DEMO_FMRI_PREPROCESS(PATH_DEMO,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% PATH_DEMO
%       (string, default GB_NIAK_PATH_DEMO in the file NIAK_GB_VARS) 
%       the full path to the NIAK demo dataset. The dataset can be found in 
%       multiple file formats at the following address : 
%       http://www.bic.mni.mcgill.ca/users/pbellec/demo_niak/
% OPT
%       (structure, optional) with the following fields : 
%
%       FLAG_TEST
%           (boolean, default false) if FLAG_TEST == true, the demo will 
%           just generate the PIPELINE and OPT structure, otherwise it will 
%           process the pipeline.
%
%       STYLE
%           (string, default 'fmristat') the style of the pipeline. 
%           Available choices : 'fmristat', 'standard-native',
%           'standard-stereotaxic'.
%
%       SIZE_OUTPUT 
%           (string, default 'quality_control') possible values : 
%           ???minimum???, 'quality_control???, ???all???.
%
%       FLAG_CORSICA
%           (boolean, default 1) if FLAG_CORSICA == 1, the CORSICA method
%           will be applied to correct for physiological & motion noise.
%
%       PSOM
%           (structure) the options of the pipeline manager. See the OPT
%           argument of PSOM_RUN_PIPELINE. Default values can be used here.
%           Note that the field PSOM.PATH_LOGS will be set up by the
%           pipeline.
%
% _________________________________________________________________________
% OUTPUTS:
%
% PIPELINE
%       (structure) a formal description of the pipeline. See
%       PSOM_RUN_PIPELINE.
%
% OPT
%       (structure) the option to call NIAK_PIPELINE_FMRI_PREPROCESS.
%
% _________________________________________________________________________
% COMMENTS:
%
% The demo will apply a 'standard-native' preprocessing pipeline on the 
% functional data of subjects 1 and 2 (rest and motor conditions) as well 
% as their anatomical image. This will take about 2 hours on a single 
% machine. It is possible to configure the pipeline manager to use parallel
% computing, see : 
% http://code.google.com/p/psom/wiki/HowToUsePsom#PSOM_configuration
%
% _________________________________________________________________________
% COMMENT:
%
% NOTE 1:
% A more detailed description of NIAK_PIPELINE_FMRI_PREPROCESS can be found
% on : 
% http://wiki.bic.mni.mcgill.ca/index.php/NiakFmriPreprocessing
%
% NOTE 3:
% The demo database exists in multiple file formats. NIAK looks into the demo 
% path and is supposed to figure out which format you are intending to use 
% by himself. 
%
% Copyright (c) Pierre Bellec, Montreal Neurological Institute, 2008.
% Maintainer : pbellec@bic.mni.mcgill.ca
% See licensing information in the code.
% Keywords : medical imaging, slice timing, fMRI

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Get the files

% if ~exist('DirPathForNiak')
%     [files_in,mainpath]=getDirNIAK();
% else
    [files_in,mainpath]=getDirNIAK(DirPathForNiak);
% end
% files_in.corsica.fmri={'/home/aurelien/corsica_01/fmri/raw_ASL_recal_1.mnc'};
% files_in.corsica.transformation='/home/fatmike/aurelien/ASL/multi-TI/temoin01/mri/transforms/';   
niak_gb_vars

if ~exist('mainpath','var')
    mainpath = '';
end

if isempty(mainpath)
    mainpath = gb_niak_mainpath;
end

if ~strcmp(mainpath(end),filesep)
    mainpath = [mainpath filesep];
end

%% Set up defaults
gb_name_structure = 'opt';
default_psom.path_logs = '';
gb_list_fields = {'flag_corsica','style','size_output','flag_test','psom'};
gb_list_defaults = {1,'fmristat','quality_control',false,default_psom};
niak_set_defaults



%%%%%%%%%%%%%%%%%%%%%%%
%% Pipeline options  %%
%%%%%%%%%%%%%%%%%%%%%%%
% The style of the pipeline. Available options : 'fmristat',
% 'standard-native', 'standard-stereotaxic'.
% opt.style = 'standard-stereotaxic';
% opt.style = 'fmristat';
opt.style = 'standard-native';

% The quantity of outputs. 
% Available options : 'minimum', 'quality_control', 'all'
opt.size_output = 'all';

% Flag to turn on and off the physiological noise correction
opt.flag_corsica = true; 

% Where to store the results
%opt.folder_out = cat(2,mainpath,filesep,'fmri_preprocessOLDProt',filesep); 
opt.folder_out = DirPathForNiak;
%opt.psom.mode = 'batch';
%opt.psom.mode_pipeline_manager = 'batch';
%opt.flag_update = false;
%opt.flag_clean = false;
%opt.flag_test = 1;

%%%%%%%%%%%%%%%%%%%%
%% Bricks options %%
%%%%%%%%%%%%%%%%%%%%

% These options correspond to the 'standard-native' style of
% pipeline, but will also work with 'standard-stereotaxic' and 'fmristat'.
% 
% The options presented here are only the most important ones. A 
% comprehensive list can be found in the help of the respective bricks.

% Linear and non-linear fit of the anatomical image in the stereotaxic
% space (niak_brick_civet)
opt.bricks.civet.n3_distance = 25; % Parameter for non-uniformity correction. 200 is a suggested value for 1.5T images, 25 for 3T images. If you find that this stage did not work well, this parameter is usually critical to improve the results.

% Motion correction (niak_brick_motion_correction)
opt.bricks.motion_correction.suppress_vol = 0; % There is no dummy scan to supress.
opt.bricks.motion_correction.vol_ref = 'median'; % Use the median volume of each run as a target.
opt.bricks.motion_correction.run_ref = 1; % The first run of each session is used as a reference.
opt.bricks.motion_correction.session_ref = 'session1'; % The first session is used as a reference.
opt.bricks.motion_correction.flag_session = 0; % Correct for both within and between sessions motion

%if ~strcmp(opt.style,'fmristat')

    % Slice timing correction (niak_brick_slice_timing)
    TR = 3; % Repetition time in seconds
    delayTR= 0.25;% (delay between TR = 100 ms)
    nb_slices = 25; % Number of slices in a volume
    opt.bricks.slice_timing.slice_order = [1:nb_slices]; % Descending + negative z step (-5) in minc file)
    
    opt.bricks.ref_slice = 1;
    opt.bricks.slice_timing.timing(1)=TR; % Time beetween slices 
    opt.bricks.slice_timing.timing(2)=TR + delayTR; % Time between the last slice of a volume and the first slice of next volume
    opt.bricks.slice_timing.suppress_vol = 1; % Remove the first and last volume after slice-timing correction to prevent edges effects.

    % Temporal filetring (niak_brick_time_filter)
    opt.bricks.time_filter.hp = 0.01; % Apply a high-pass filter at cut-off frequency 0.01Hz (slow time drifts)
    opt.bricks.time_filter.lp = Inf; % Do not apply low-pass filter. Low-pass filter induce a big loss in degrees of freedom without sgnificantly improving the SNR.

%end


% Correction of physiological noise (niak_pipeline_corsica)
if opt.flag_corsica
    opt.bricks.sica.nb_comp = 20;
    opt.bricks.component_supp.threshold = 0.15;
end

% Spatial smoothing (niak_brick_smooth_vol)
opt.bricks.smooth_vol.fwhm = 6; % Apply an isotropic 6 mm gaussin smoothing.

%PSOM options
% opt.psom.qsub_options = '-r y -q grova.q'
opt.psom.mode = 'batch'; % Run the jobs in batch mode
opt.psom.max_queued = 4; % Please try to use the two processors of my laptop, thanks !
opt.psom.mode_pipeline_manager = 'qsub'; % Run the pipeline from the current session;
opt.qsub_options = '-q fs_q';
opt.psom.path_logs=DirPathForNiak;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run the fmri_preprocess template  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pipeline = niak_pipeline_corsica(files_in,opt);