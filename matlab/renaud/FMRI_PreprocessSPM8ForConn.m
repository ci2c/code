function FMRI_PreprocessSPM8ForConn(data_path,TR,nslices,refslice,volfwhm,acquisition)


if strcmp(acquisition,'ascending')
    prefix{1}  = '';
    prefix{2}  = 'r';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    joblist    = [2 3];
    sliceorder = 1:1:nslices;
elseif strcmp(acquisition,'interleaved')
    prefix{1}  = 'a';
    prefix{2}  = '';
    prefix{3}  = 'ra';
    prefix{4}  = 'meana';
    joblist    = [3 2];
    %sliceorder = [1:2:nslices 2:2:nslices];
    sliceorder = [];
    space      = round(sqrt(nslices));
    for k=1:space
        tmp        = k:space:nslices;
        sliceorder = [sliceorder tmp];
    end
else
    prefix{1} = '';
    prefix{2} = 'r';
    prefix{3} = 'r';
    prefix{4}  = 'mean';
    joblist    = [2];
    sliceorder = 1:1:nslices;
end


%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('Defaults','fMRI');

spm_jobman('initcfg'); % SPM8 only

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
clear jobs
jobs{1}.spm.util.cdir.directory = cellstr(data_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = spm_select('FPList', fullfile(data_path,'spm'), '^epi_.*\.nii$');
a = fullfile(data_path,'orig.nii');

%% REALIGN
%--------------------------------------------------------------------------
jobs{joblist(1)}.spm.spatial.realign.estwrite.data{1} = editfilenames(f,'prefix',prefix{1});

jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.sep     = 4;
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.fwhm    = 5;
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.rtm     = 1;
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.interp  = 2;
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.wrap    = [0 0 0];
jobs{joblist(1)}.spm.spatial.realign.estwrite.eoptions.weight  = '';
jobs{joblist(1)}.spm.spatial.realign.estwrite.roptions.which   = [2 1];
jobs{joblist(1)}.spm.spatial.realign.estwrite.roptions.interp  = 4;
jobs{joblist(1)}.spm.spatial.realign.estwrite.roptions.wrap    = [0 0 0];
jobs{joblist(1)}.spm.spatial.realign.estwrite.roptions.mask    = 1;
jobs{joblist(1)}.spm.spatial.realign.estwrite.roptions.prefix  = 'r';


%% SLICE TIMING CORRECTION
%--------------------------------------------------------------------------
if ( strcmp(acquisition,'ascending') || strcmp(acquisition,'interleaved') )
    
    jobs{joblist(2)}.spm.temporal.st.scans{1} = editfilenames(f,'prefix',prefix{2});
    jobs{joblist(2)}.spm.temporal.st.nslices  = nslices;
    jobs{joblist(2)}.spm.temporal.st.tr       = TR;
    jobs{joblist(2)}.spm.temporal.st.ta       = TR-TR/nslices;
    jobs{joblist(2)}.spm.temporal.st.so       = sliceorder;
    jobs{joblist(2)}.spm.temporal.st.refslice = refslice;
    jobs{joblist(2)}.spm.temporal.st.prefix   = 'a';
    
end


%% COREGISTRATION
%--------------------------------------------------------------------------

jobs{end+1}.spm.spatial.coreg.estimate.ref             = cellstr(a);
jobs{end}.spm.spatial.coreg.estimate.source            = editfilenames(f(1,:),'prefix',prefix{4});
jobs{end}.spm.spatial.coreg.estimate.other             = editfilenames(f,'prefix',prefix{3});
jobs{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
jobs{end}.spm.spatial.coreg.estimate.eoptions.sep      = [4 2];
jobs{end}.spm.spatial.coreg.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
jobs{end}.spm.spatial.coreg.estimate.eoptions.fwhm     = [7 7];

a2 = spm_select('FPList', data_path, '^orig_2mm.*\.nii$');
jobs{end+1}.spm.spatial.coreg.write.ref  = cellstr(a2);
jobs{end}.spm.spatial.coreg.write.source          = editfilenames(f,'prefix',prefix{3});
jobs{end}.spm.spatial.coreg.write.roptions.interp = 4;
jobs{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
jobs{end}.spm.spatial.coreg.write.roptions.mask   = 0;
jobs{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

jobs{end+1}.spm.spatial.coreg.write.ref           = cellstr(a2);
jobs{end}.spm.spatial.coreg.write.source          = editfilenames(f(1,:),'prefix',prefix{4});
jobs{end}.spm.spatial.coreg.write.roptions.interp = 4;
jobs{end}.spm.spatial.coreg.write.roptions.wrap   = [0 0 0];
jobs{end}.spm.spatial.coreg.write.roptions.mask   = 0;
jobs{end}.spm.spatial.coreg.write.roptions.prefix = 'r';

%% SMOOTHING
%--------------------------------------------------------------------------

jobs{end+1}.spm.spatial.smooth.data   = editfilenames(f,'prefix',['r' prefix{3}]);
jobs{end}.spm.spatial.smooth.fwhm   = [volfwhm volfwhm volfwhm];
jobs{end}.spm.spatial.smooth.dtype  = 0;
jobs{end}.spm.spatial.smooth.im     = 0;
jobs{end}.spm.spatial.smooth.prefix = 'sv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);