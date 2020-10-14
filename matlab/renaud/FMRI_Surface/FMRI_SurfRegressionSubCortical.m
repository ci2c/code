function FMRI_SurfRegressionSubCortical(fsdir,outdir,datalist,subjlist,TR,nperm,clusFile)

addpath('/home/renaud/matlab/snpm8b');

load(clusFile);

epifolder = 'SurfEPI';

%%  SubCortical Voxels Regression

disp('SubCortical Voxels Regression')

for k = 1:length(subjlist)
    
    subj = subjlist{k};
    
    disp(['subject: ' subj])
    
    mepiFile   = spm_select('FPList', fullfile(fsdir,subj,epifolder,'spm'), '^mean.*\.nii$');
    motionFile = spm_select('FPList', fullfile(fsdir,subj,epifolder,'spm'), '^rp_.*\.txt$');
    epiFile    = fullfile(fsdir,subj,epifolder,'epi_pre.nii');

    roiscFile  = fullfile(fsdir,subj,epifolder,'RoiSc.nii');

    output = datalist{k};

    RegressionOnSSCortical(fsdir,subj,mepiFile,epiFile,TR,clusFile,motionFile,roiscFile,output);
    
end

%% Group Analysis (NonParametric statistics)

disp('Group Analysis (NonParametric statistics)')

COIs = resClust.cois;

for k = 1:length(COIs)
    
    coi = COIs(k);
    disp(['COI: ' num2str(coi)])
    
    output = fullfile(outdir,['subcort_' num2str(coi)]);
    if(exist(output,'dir'))
        cmd = sprintf('rm -rf %s',output);
        unix(cmd);
    end
    cmd = sprintf('mkdir -p %s',output);
    unix(cmd);
    
    mapFiles={};
    for j = 1:length(subjlist)
    
        subj = subjlist{j};
           
        tmpFile  = fullfile(datalist{j},['wtMap_Sc_' num2str(coi) '.nii']);
        if filexist(tmpFile)
            mapFiles{end+1} = tmpFile;
        end
    end

    save(fullfile(output,'maps.mat'),'mapFiles');

    if( 2^(length(mapFiles)) <= 5000 )
        nperm = 2^(length(mapFiles)) - 10;
    end

    DesignNonParametricTest(mapFiles,output,nperm);
    
    matFile = fullfile(output,'SnPMcfg.mat');
    ComputeNonParametricTest(matFile);
    
    ThresholdNonParametricTest(output);
    
end
