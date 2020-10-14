function FMRI_Preprocess_SPM12(data_path,TR,nslices,refslice,fwhm,acquisition,vox_size)


if strcmp(acquisition,'ascending')
    prefix{1}  = '';
    prefix{2}  = 'r';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    prefix{5}  = 'war';
    sliceorder = 1:1:nslices;
elseif strcmp(acquisition,'interleaved')
        prefix{1}  = 'a';
        prefix{2}  = '';
        prefix{3}  = 'ra';
        prefix{4}  = 'meana';
        prefix{5}  = 'wra';
        sliceorder = [];
        space      = round(sqrt(nslices));
        for k=1:space
            tmp        = k:space:nslices;
            sliceorder = [sliceorder tmp];
        end
elseif strcmp(acquisition,'descending')
    prefix{1}  = 'a';
    prefix{2}  = '';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    prefix{5}  = 'war';
    sliceorder = [nslices:-2:1 nslices-1:-2:1];
else
   disp('error for acquisition type');
   return;
end

%% Initialise SPM defaults
%--------------------------------------------------------------------------
spm('defaults', 'FMRI');

spm_jobman('initcfg');
jobs={};

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
% clear jobs
% jobs{1}.util{1}.cdir.directory = cellstr(data_path);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SPATIAL PREPROCESSING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select functional and structural scans
%--------------------------------------------------------------------------
f1 = spm_select('FPList', fullfile(data_path,'spm','RawEPI','run1'), '^epi_.*\.nii$');
f2 = spm_select('FPList', fullfile(data_path,'spm','RawEPI','run2'), '^epi_.*\.nii$');
f = [ f1 ; f2 ];
a = spm_select('FPList', fullfile(data_path,'spm','Structural'), '^orig.*\.nii$');

%% SLICE TIMING CORRECTION
%--------------------------------------------------------------------------
jobs{end+1}.spm.temporal.st.scans = { editfilenames(f1,'prefix',prefix{2}) editfilenames(f2,'prefix',prefix{2}) }';
jobs{end}.spm.temporal.st.nslices = nslices;
jobs{end}.spm.temporal.st.tr = TR;
jobs{end}.spm.temporal.st.ta = TR-TR/nslices;
jobs{end}.spm.temporal.st.so = sliceorder;
jobs{end}.spm.temporal.st.refslice = refslice;
jobs{end}.spm.temporal.st.prefix = 'a';

%% REALIGN
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.realign.estwrite.data = { editfilenames(f1,'prefix',prefix{1}) editfilenames(f2,'prefix',prefix{1}) }';
jobs{end}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
jobs{end}.spm.spatial.realign.estwrite.eoptions.sep = 4;
jobs{end}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
jobs{end}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
jobs{end}.spm.spatial.realign.estwrite.eoptions.interp = 2;
jobs{end}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
jobs{end}.spm.spatial.realign.estwrite.eoptions.weight = '';
jobs{end}.spm.spatial.realign.estwrite.roptions.which = [2 1];
jobs{end}.spm.spatial.realign.estwrite.roptions.interp = 4;
jobs{end}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
jobs{end}.spm.spatial.realign.estwrite.roptions.mask = 1;
jobs{end}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

%% COREGISTRATION
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.coreg.estimate.ref = cellstr(a);
jobs{end}.spm.spatial.coreg.estimate.source = editfilenames(f1(1,:),'prefix',prefix{4});
jobs{end}.spm.spatial.coreg.estimate.other = editfilenames(f,'prefix',prefix{3});
jobs{end}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
jobs{end}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
jobs{end}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
jobs{end}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

%% NORMALISATION : ESTIMATE
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.normalise.est.subj.vol = cellstr(a);
jobs{end}.spm.spatial.normalise.est.eoptions.biasreg = 0.0001;
jobs{end}.spm.spatial.normalise.est.eoptions.biasfwhm = 60;
jobs{end}.spm.spatial.normalise.est.eoptions.tpm = {'/home/global/matlab_toolbox/spm12b/tpm/TPM.nii'};
jobs{end}.spm.spatial.normalise.est.eoptions.affreg = 'mni';
jobs{end}.spm.spatial.normalise.est.eoptions.reg = [0 0.001 0.5 0.05 0.2];
jobs{end}.spm.spatial.normalise.est.eoptions.fwhm = 0;
jobs{end}.spm.spatial.normalise.est.eoptions.samp = 3;

%% NORMALISATION : WRITE
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.normalise.write.subj.def = editfilenames(a,'prefix','y_');
jobs{end}.spm.spatial.normalise.write.subj.resample = editfilenames(f,'prefix',prefix{3});
jobs{end}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
jobs{end}.spm.spatial.normalise.write.woptions.vox = [vox_size vox_size vox_size];
jobs{end}.spm.spatial.normalise.write.woptions.interp = 4;

%% SMOOTHING
%--------------------------------------------------------------------------
jobs{end+1}.spm.spatial.smooth.data = editfilenames(f,'prefix',prefix{5});
jobs{end}.spm.spatial.smooth.fwhm = [fwhm fwhm fwhm];
jobs{end}.spm.spatial.smooth.dtype = 0;
jobs{end}.spm.spatial.smooth.im = 0;
jobs{end}.spm.spatial.smooth.prefix = 's';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save(fullfile(data_path,'spm','RawEPI','batch_preprocessing.mat'),'jobs');
spm_jobman('run',jobs);