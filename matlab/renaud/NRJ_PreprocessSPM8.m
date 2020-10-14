function NRJ_PreprocessSPM8(data_path,t1file,nsess,TR,nslices,fwhm,coreg,acquisition,resampling)

refslice = 1;
for k = 1:nsess
    if k<10
        session{k} = ['sess0' num2str(k)];
    else
        session{k} = ['sess' num2str(k)];
    end
end

if strcmp(acquisition,'ascending')
    prefix{1}  = '';
    prefix{2}  = 'r';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    joblist    = [2 3];
    sliceorder = 1:1:nslices;
else if strcmp(acquisition,'interleaved')
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
        disp('error for acquisition type');
        return;
    end
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
for k = 1:length(session)
    f{k} = spm_select('FPList', fullfile(data_path,session{k}), '^epi_.*\.nii$');
end

%% REALIGN
%--------------------------------------------------------------------------
for k = 1:length(session)
    jobs{joblist(1)}.spatial{1}.realign{1}.estwrite.data{k} = editfilenames(f{k},'prefix',prefix{1});
end

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
for k = 1:length(session)
    jobs{joblist(2)}.temporal{1}.st.scans{k} = editfilenames(f{k},'prefix',prefix{2});
end
jobs{joblist(2)}.temporal{1}.st.nslices  = nslices;
jobs{joblist(2)}.temporal{1}.st.tr       = TR;
jobs{joblist(2)}.temporal{1}.st.ta       = TR-TR/nslices;
jobs{joblist(2)}.temporal{1}.st.so       = sliceorder;
jobs{joblist(2)}.temporal{1}.st.refslice = refslice;
jobs{joblist(2)}.temporal{1}.st.prefix   = 'a';


%% COREGISTRATION
%--------------------------------------------------------------------------

if(resampling==0)
    
    disp('no resampling');
    if strcmp(coreg,'epi2anat')
        otherf = [];
        jobs{4}.spatial{1}.coreg{1}.estimate.ref    = cellstr(t1file);
        jobs{4}.spatial{1}.coreg{1}.estimate.source = editfilenames(f{1}(1,:),'prefix',prefix{4});
        for k = 1:length(session)
            otherf = [otherf; editfilenames_char(f{k},'prefix',prefix{3})];
        end
        jobs{4}.spatial{1}.coreg{1}.estimate.other  = cellstr(otherf);
    else if strcmp(coreg,'anat2epi')
        jobs{4}.spatial{1}.coreg{1}.estimate.ref    = editfilenames(f{1}(1,:),'prefix',prefix{4});
        jobs{4}.spatial{1}.coreg{1}.estimate.source = cellstr(t1file);
    else
        disp('error: coregistration');
    end
    end

    jobs{4}.spatial{1}.coreg{1}.estimate.eoptions.cost_fun = 'nmi';
    jobs{4}.spatial{1}.coreg{1}.estimate.eoptions.sep      = [4 2];
    jobs{4}.spatial{1}.coreg{1}.estimate.eoptions.tol      = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{4}.spatial{1}.coreg{1}.estimate.eoptions.fwhm     = [7 7];
    
    % SMOOTHING
    otherf = [];
    for k = 1:length(session)
        otherf = [otherf; editfilenames_char(f{k},'prefix',prefix{3})];
    end
    jobs{4}.spatial{2}.smooth.data   = cellstr(otherf);
    jobs{4}.spatial{2}.smooth.fwhm   = [fwhm fwhm fwhm];
    jobs{4}.spatial{2}.smooth.dtype  = 0;
    jobs{4}.spatial{2}.smooth.im     = 0;
    jobs{4}.spatial{2}.smooth.prefix = 's';

else
    
    disp('resampling');
    if strcmp(coreg,'epi2anat')
        otherf = [];
        jobs{4}.spatial{1}.coreg{1}.estwrite.ref    = cellstr(t1file);
        jobs{4}.spatial{1}.coreg{1}.estwrite.source = editfilenames(f{1}(1,:),'prefix',prefix{4});
        for k = 1:length(session)
            otherf = [otherf; editfilenames_char(f{k},'prefix',prefix{3})];
        end
        jobs{4}.spatial{1}.coreg{1}.estwrite.other  = cellstr(otherf);
    else if strcmp(coreg,'anat2epi')
        jobs{4}.spatial{1}.coreg{1}.estwrite.ref    = editfilenames(f(1,:),'prefix',prefix{4});
        jobs{4}.spatial{1}.coreg{1}.estwrite.source = cellstr(t1file);
    else
        disp('error: coregistration');
    end
    end
    
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.cost_fun = 'nmi';
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.sep = [4 2];
    jobs{4}.spatial{1}.coreg{1}.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    jobs{4}.spatial{1}.coreg{1}.coreg.estwrite.eoptions.fwhm = [7 7];
    jobs{4}.spatial{1}.coreg{1}.coreg.estwrite.roptions.interp = 1;
    jobs{4}.spatial{1}.coreg{1}.coreg.estwrite.roptions.wrap = [0 0 0];
    jobs{4}.spatial{1}.coreg{1}.coreg.estwrite.roptions.mask = 0;
    jobs{4}.spatial{1}.coreg{1}.coreg.estwrite.roptions.prefix = 'r';
    
    % SMOOTHING
    otherf = [];
    for k = 1:length(session)
        otherf = [otherf; editfilenames_char(f{k},'prefix',['r' prefix{3}])];
    end
    jobs{4}.spatial{2}.smooth.data   = cellstr(otherf);
    jobs{4}.spatial{2}.smooth.fwhm   = [fwhm fwhm fwhm];
    jobs{4}.spatial{2}.smooth.dtype  = 0;
    jobs{4}.spatial{2}.smooth.im     = 0;
    jobs{4}.spatial{2}.smooth.prefix = 's';
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(data_path,'batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);

