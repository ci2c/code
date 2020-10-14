function SliceTiming(data_path,TR,nslices,refslice,acquisition)

if strcmp(acquisition,'ascending')
    prefix{1}  = '';
    prefix{2}  = 'r';
    prefix{3}  = 'ar';
    prefix{4}  = 'mean';
    prefix{5}  = 'war';
    joblist    = [2 3];
    sliceorder = 1:1:nslices;
else if strcmp(acquisition,'interleaved')
        prefix{1}  = 'a';
        prefix{2}  = '';
        prefix{3}  = 'ra';
        prefix{4}  = 'meana';
        prefix{5}  = 'wra';
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
spm('defaults', 'FMRI');

spm_jobman('initcfg');
matlabbatch={};

%% WORKING DIRECTORY
%--------------------------------------------------------------------------
%clear matlabbatch
%matlabbatch{1}.util{1}.cdir.directory = cellstr(data_path);

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
matlabbatch{end+1}.spm.temporal.st.scans = { editfilenames(f1,'prefix',prefix{2}) editfilenames(f2,'prefix',prefix{2}) }';
matlabbatch{end}.spm.temporal.st.nslices = nslices;
matlabbatch{end}.spm.temporal.st.tr = TR;
matlabbatch{end}.spm.temporal.st.ta = TR-TR/nslices;
matlabbatch{end}.spm.temporal.st.so = sliceorder;
matlabbatch{end}.spm.temporal.st.refslice = refslice;
matlabbatch{end}.spm.temporal.st.prefix = 'a';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save(fullfile(data_path,'spm','RawEPI','batch_preprocessing.mat'),'jobs');
spm_jobman('run',matlabbatch);
