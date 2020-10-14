function FMRI_SurfPreprocessSPM8(data_path,TR,nslices,refslice,surffwhm,volfwhm,coreg,acquisition,resampling)


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
elseif strcmp(acquisition,'descending')
    prefix{1}  = 'a';
    prefix{2}  = '';
    prefix{3}  = 'ra';
    prefix{4}  = 'meana';
    joblist    = [3 2];
    sliceorder = [nslices:-2:1 nslices-1:-2:1];
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
jobs{1}.util{1}.cdir.directory = cellstr(data_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f = spm_select('FPList', fullfile(data_path,'spm'), '^epi_.*\.nii$');
a = spm_select('FPList', data_path, '^orig.*\.nii$');

%% REALIGN
%--------------------------------------------------------------------------
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.data{1} = editfilenames(f,'prefix',prefix{1});

jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.quality = 0.9;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.sep     = 4;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.fwhm    = 5;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.rtm     = 1;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.interp  = 2;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.wrap    = [0 0 0];
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.eoptions.weight  = '';
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.roptions.which   = [2 1];
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.roptions.interp  = 4;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.roptions.wrap    = [0 0 0];
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.roptions.mask    = 1;
jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.roptions.prefix  = 'r';


%% SLICE TIMING CORRECTION
%--------------------------------------------------------------------------
if ( strcmp(acquisition,'ascending') || strcmp(acquisition,'interleaved') || strcmp(acquisition,'descending'))
    
    jobs{joblist(2)}.temporal{1}.st.scans{1} = editfilenames(f,'prefix',prefix{2});
    jobs{joblist(2)}.temporal{1}.st.nslices  = nslices;
    jobs{joblist(2)}.temporal{1}.st.tr       = TR;
    jobs{joblist(2)}.temporal{1}.st.ta       = TR-TR/nslices;
    jobs{joblist(2)}.temporal{1}.st.so       = sliceorder;
    jobs{joblist(2)}.temporal{1}.st.refslice = refslice;
    jobs{joblist(2)}.temporal{1}.st.prefix   = 'a';
    
end


%% COREGISTRATION
%--------------------------------------------------------------------------

if(resampling==0)
    
    disp('no resampling');
    if strcmp(coreg,'epi2anat')
        jobs{end+1}.spatial{1}.coreg{1}.estimate.ref    = cellstr(a);
        jobs{end}.spatial{1}.coreg{1}.estimate.source = editfilenames(f(1,:),'prefix',prefix{4});
        jobs{end}.spatial{1}.coreg{1}.estimate.other  = editfilenames(f,'prefix',prefix{3});
    else if strcmp(coreg,'anat2epi')
        jobs{end+1}.spatial{1}.coreg{1}.estimate.ref    = editfilenames(f(1,:),'prefix',prefix{4});
        jobs{end}.spatial{1}.coreg{1}.estimate.source = cellstr(a);
    else
        disp('error: coregistration');
        return;
    end
    end

    jobs{end}.spatial{1}.coreg{1}.estimate.eoptions.cost_fun = 'nmi';
    jobs{end}.spatial{1}.coreg{1}.estimate.eoptions.sep      = [4 2];
    jobs{end}.spatial{1}.coreg{1}.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{end}.spatial{1}.coreg{1}.estimate.eoptions.fwhm     = [7 7];
    
    % SMOOTHING
    jobs{end}.spatial{2}.smooth.data   = editfilenames(f,'prefix',prefix{3});
    jobs{end}.spatial{2}.smooth.fwhm   = [surffwhm surffwhm surffwhm];
    jobs{end}.spatial{2}.smooth.dtype  = 0;
    jobs{end}.spatial{2}.smooth.im     = 0;
    jobs{end}.spatial{2}.smooth.prefix = 'ss';
    
    jobs{end}.spatial{3}.smooth.data   = editfilenames(f,'prefix',prefix{3});
    jobs{end}.spatial{3}.smooth.fwhm   = [volfwhm volfwhm volfwhm];
    jobs{end}.spatial{3}.smooth.dtype  = 0;
    jobs{end}.spatial{3}.smooth.im     = 0;
    jobs{end}.spatial{3}.smooth.prefix = 'sv';

else
    
    disp('resampling');
    
    if strcmp(coreg,'epi2anat')
        jobs{end+1}.spatial{1}.coreg{1}.estwrite.ref    = cellstr(a);
        jobs{end}.spatial{1}.coreg{1}.estwrite.source = editfilenames(f(1,:),'prefix',prefix{4});
        jobs{end}.spatial{1}.coreg{1}.estwrite.other  = editfilenames(f,'prefix',prefix{3});
    else if strcmp(coreg,'anat2epi')
        jobs{end+1}.spatial{1}.coreg{1}.estwrite.ref    = editfilenames(f(1,:),'prefix',prefix{4});
        jobs{end}.spatial{1}.coreg{1}.estwrite.source = cellstr(a);
    else
        disp('error: coregistration');
        return;
    end
    end
    
    jobs{end}.spatial{1}.coreg{1}.estwrite.eoptions.cost_fun = 'nmi';
    jobs{end}.spatial{1}.coreg{1}.estwrite.eoptions.sep = [4 2];
    jobs{end}.spatial{1}.coreg{1}.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{end}.spatial{1}.coreg{1}.coreg.estwrite.eoptions.fwhm = [7 7];
    jobs{end}.spatial{1}.coreg{1}.coreg.estwrite.roptions.interp = 1;
    jobs{end}.spatial{1}.coreg{1}.coreg.estwrite.roptions.wrap = [0 0 0];
    jobs{end}.spatial{1}.coreg{1}.coreg.estwrite.roptions.mask = 0;
    jobs{end}.spatial{1}.coreg{1}.coreg.estwrite.roptions.prefix = 'r';
    
    % SMOOTHING
    jobs{end}.spatial{2}.smooth.data   = editfilenames(f,'prefix',prefix{3});
    jobs{end}.spatial{2}.smooth.fwhm   = [surffwhm surffwhm surffwhm];
    jobs{end}.spatial{2}.smooth.dtype  = 0;
    jobs{end}.spatial{2}.smooth.im     = 0;
    jobs{end}.spatial{2}.smooth.prefix = 'ss';
    
    jobs{end}.spatial{3}.smooth.data   = editfilenames(f,'prefix',prefix{3});
    jobs{end}.spatial{3}.smooth.fwhm   = [volfwhm volfwhm volfwhm];
    jobs{end}.spatial{3}.smooth.dtype  = 0;
    jobs{end}.spatial{3}.smooth.im     = 0;
    jobs{end}.spatial{3}.smooth.prefix = 'sv';
    
end


%% NEW SEGMENT

% jobs{end+1}.tools.preproc8.channel.vols   = cellstr(a);
% jobs{end}.tools.preproc8.channel.biasreg  = 0.0001;
% jobs{end}.tools.preproc8.channel.biasfwhm = 60;
% jobs{end}.tools.preproc8.channel.write    = [1 1];
% nbGauss = [2 2 2 3 4 2];
% [SPMPath, fileN, extn] = fileparts(which('spm.m'));
% for k = 1:6
%     jobs{end}.tools.preproc8.tissue(1,k).tpm{1,1} = fullfile(SPMPath,'toolbox','Seg',['TPM.nii',',',num2str(k)]);
%     jobs{end}.tools.preproc8.tissue(1,k).ngaus    = nbGauss(k);
%     jobs{end}.tools.preproc8.tissue(1,k).native   = [1 1];
% end
% jobs{end}.tools.preproc8.warp.reg    = 4;
% jobs{end}.tools.preproc8.warp.affreg = 'mni';
% jobs{end}.tools.preproc8.warp.samp   = 3;
% jobs{end}.tools.preproc8.warp.write  = [1 1];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);

