function FMRI_GroupSubCorticalRegressionOneClass(dataroot,subjFile,coi,outdir)

addpath('/home/global/matlab_toolbox/spm12b');
addpath('/home/renaud/matlab/snpm8b');

disp('Group Analysis (NonParametric statistics)')

subjlist = textread(subjFile,'%s','delimiter','\n');
    
disp(['COI: ' num2str(coi)])
nperm = 5000;

output = fullfile(outdir,['coi' num2str(coi)]);
if(exist(output,'dir'))
    cmd = sprintf('rm -rf %s',output);
    unix(cmd);
end
cmd = sprintf('mkdir -p %s',output);
unix(cmd);

mapFiles={};
for j = 1:length(subjlist)

    subj = subjlist{j};

    tmpFile  = fullfile(dataroot,subj,'coi',['wcon_coi' num2str(coi) '.nii']);
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
    