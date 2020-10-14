clear all;
close all;

%% PATH AND OPTIONS

ProgramPath        = '/home/renaud/matlab/rest_toolbox/DPARSF';
opt.DataProcessDir = '/home/fatmike/renaud/tep_fog/preprocess';
opt.SubjectID      = {'ALIB','BAUD','BETT','BISI','BOND','DAMB','DEBA','DENI','DETH','DUMO','HERL','LOUG','LUCA','MARQ','POCH','VASS'}; 
opt.SubjectNum     = length(opt.SubjectID);
opt.TimePoints     = 250;
opt.SliceNumber    = 40;
opt.TR             = 2.4;

Error              = [];
[SPMversion,c]     = spm('Ver');
SPMversion         = str2double(SPMversion(end));

cur_path           = pwd;

%% REMOVAL TIME POINTS + SLICE TIMING CORRECTION + REALIGNEMENT

opt.RemoveFirstTimePoints = 10;

opt.IsSliceTiming         = 1;
taborder = [];
space    = round(sqrt(opt.SliceNumber));
for k=1:space
    tmp      = k:space:opt.SliceNumber;
    taborder = [taborder tmp];
end
opt.SliceOrder            = taborder;
opt.ReferenceSlice        = 1;
clear taborder;

opt.IsRealign             = 1;

%Error = FMRI_ST_Realign(ProgramPath,opt,SPMversion,Error);


%% NORMALIZATION 

cd(cur_path);

opt.TimePoints  = opt.TimePoints - opt.RemoveFirstTimePoints;
opt.IsNormalize = 3;
opt.BoundingBox = [-90 -126 -72;90 90 108];
opt.VoxSize     = [3 3 3];
opt.AffineRegularisationInSegmentation = 'mni';
opt.IsDelFilesBeforeNormalize = 0;

Error = FMRI_Normalize(ProgramPath,opt,SPMversion,Error);


%% SMOOTHING

cd(cur_path);

opt.DataIsSmoothed = 1;
opt.FWHM           = [6 6 6];
Error = FMRI_Smooth(ProgramPath,opt,SPMversion,Error);


%% DETREND

cd(cur_path);

opt.IsDetrend = 1;

FMRI_Detrend(opt);


%% FILTER

cd(cur_path);

opt.IsFilter            = 1;
opt.IsDelDetrendedFiles = 0;
opt.ASamplePeriod       = opt.TR;
opt.ALowPass_HighCutoff = 0.08;
opt.AHighPass_LowCutoff = 0.01;
opt.AAddMeanBack        = 'yes';
opt.AMaskFilename       = '';

FMRI_Filter(opt);


%% REMOVE COVARIABLE

cd(cur_path);

opt.IsCovremove                  = 1;
opt.Covremove.HeadMotion         = 1;
opt.Covremove.WholeBrain         = 1;
opt.Covremove.CSF                = 0;
opt.Covremove.WhiteMatter        = 0;
opt.Covremove.OtherCovariatesROI = [];

FMRI_CovariablesRemoval(ProgramPath,opt);


