function NRJ_NetwDetByICA(epipath,maskfile,Ns,prefix,ncomp,TR,numvox,thresT,typeCorr)


% %% ICA
% list_res = NRJ_SicaAllRuns(epipath,maskfile,Ns,prefix,ncomp,TR);  
% save(fullfile(epipath,'list_res.mat'),'list_res');


%% HIERARICHAL CLUSTERING

load(fullfile(epipath,'list_res.mat'),'list_res');
[resClust,dataHier] = NRJ_HierClustering(list_res,ncomp);
save(fullfile(epipath,'resClust.mat'),'resClust');
save(fullfile(epipath,'resClustData.mat'),'dataHier');


%% CLASSES DETERMINATION

opt.numvox        = numvox;
opt.thresT        = thresT;
opt.nbclasses     = 15;
opt.thresHierType = 'auto'; % 'manual' 
opt.typeCorr      = typeCorr; % 'BONF' or 'FDR' or 'UNC'

load(fullfile(epipath,'resClust.mat'),'resClust');
resClust.header_sica = spm_vol('/home/fatmike/francois/energy/freesurfer/potin/fmri/run01/ica_40_vol_sm/ica_map_1.nii');
[nbclasses,resClust] = NRJ_Classes(epipath,resClust,maskfile,opt);
save(fullfile(epipath,'resClust.mat'),'resClust');


%% THRESHOLDING

%load(fullfile(epipath,'resClust.mat'),'resClust');
resClust = NRJ_Thresholding(epipath,resClust,opt);
save(fullfile(epipath,'resClust.mat'),'resClust');


%% Display components with factors (represent and unicity) higher than threshold value

%load(fullfile(epipath,'resClust.mat'),'resClust');
thresF = 0.8;
keepC  = [];
for k = 1:length(resClust.represent)
    if(resClust.represent(k)>thresF && resClust.unicity(k)>thresF)
        keepC = [keepC k];
    end
end
resClust.keepC = keepC;
disp(keepC)
save(fullfile(epipath,'resClust.mat'),'resClust');