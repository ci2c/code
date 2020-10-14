function FMRI_SubCorticalGroup(outdir,outname,inname,subjlist,coiNames,nperm)

addpath('/home/renaud/matlab/snpm8b');

% Group Analysis (NonParametric statistics)

disp('Group Analysis (NonParametric statistics)')

for k = 1:length(coiNames)

    disp([coiNames{k}])

    output = fullfile(outdir,[outname '_' coiNames{k}]);
    if(exist(output,'dir'))
        cmd = sprintf('rm -rf %s',output);
        unix(cmd);
    end
    cmd = sprintf('mkdir -p %s',output);
    unix(cmd);

    mapFiles={};
    for j = 1:length(subjlist)

        subj = subjlist{j};

        tmpFile  = fullfile(['/home/notorious/users/renaud/volunteers_1000connectome/beijing/freesurfer/' subj '/SurfEPI/' inname],['wcon_' coiNames{k} '.img']);
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
