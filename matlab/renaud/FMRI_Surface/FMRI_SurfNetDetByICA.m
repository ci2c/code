function FMRI_SurfNetDetByICA(subjdir,subjlist,TR,prefix,nbcomp,outdir)


%% INIT

nsubj     = length(subjlist);
fspath    = '/home/global/freesurfer';
surf      = SurfStatReadSurf([fullfile(fspath,'subjects/fsaverage/surf/lh.white')]);
fnumleft  = size(surf.tri,1);
nbleft    = size(surf.coord,2);
surf      = SurfStatReadSurf([fullfile(fspath,'subjects/fsaverage/surf/rh.white')]);
fnumright = size(surf.tri,1);
nbright   = size(surf.coord,2);
clear surf;


%% ICA

disp('*****************************************')
disp('ICA...')

sizeDataHier = 0;

if exist(outdir,'file')~=7
    unix(['mkdir ' outdir)]);
end

for k = 1:nsubj
    
    disp(k)
    
    datapath = fullfile(subjdir,subjlist{k},'fmrisurf');
    sica     = FMRI_SurfICANew(datapath,TR,prefix,nbcomp);
    
    save(fullfile(subjdir,subjlist{k},'fmrisurf','sica.mat'),'sica');

    mask = 1:size(sica.S,1);

    for j = 1:sica.nbcomp
        sig_c = FMRI_CorrectSignalOnSurface(double(sica.S(:,j)),mask,0.05,1);
        write_curv(fullfile(subjdir,subjlist{k},'fmrisurf',['lh.ica_map_' num2str(j)]),sig_c(1:nbleft),fnumleft);
        write_curv(fullfile(subjdir,subjlist{k},'fmrisurf',['rh.ica_map_' num2str(j)]),sig_c(nbleft+1:end),fnumright);
    end

    sizeDataHier = sizeDataHier + nbcomp;
    
end

save(fullfile(outdir,'sizeDataHier.mat'),'sizeDataHier');

disp('*********')
disp('sICA done')
disp('*********')


%% HIERARCHICAL CLUSTERING

disp('*****************************************')
disp('CLUSTERING...')

[resClust,dataHier] = FMRI_SurfHierClustering(subjdir,subjlist,'ica_map_');

save(fullfile(outdir,'resClust.mat'),'resClust');
save(fullfile(outdir,'resClustData.mat'),'dataHier');

disp('*********')
disp('Hierarchical clustering done')
disp('*********')


%% GROUP MAPS CALCULATION

disp('*****************************************')
disp('GROUP MAPS...')

pref_ica          = 'ica_map_';
opt.nbclasses     = 20;
opt.thresHierType = 'manual'; % 'manual'
load(fullfile(outdir,'resClust.mat'),'resClust');
[numClass,resClust] = FMRI_SurfDoClasses(subjdir,subjlist,pref_ica,resClust,outdir,opt);
save(fullfile(outdir,'resClust.mat'),'resClust');
% write tMaps
for k = 1:numClass
    write_curv(fullfile(outdir,['lh.tMapsClass_' num2str(k)]),resClust.tMaps(1:nbleft,k),fnumleft);
    write_curv(fullfile(outdir,['rh.tMapsClass_' num2str(k)]),resClust.tMaps(nbleft+1:end,k),fnumright);
end

disp('*********')
disp('Classes determination done')
disp('*********')

%% GROUP MAPS THRESHOLDING

disp('*****************************************')
disp('T-MAPS THRESHOLDING...')

thresP = 0.05;
load(fullfile(outdir,'resClust.mat'),'resClust');
[resClust,AA,numClass] = FMRI_SurfThresholding(outdir,resClust,thresP);
save(fullfile(outdir,'resClust.mat'),'resClust');
% write tMaps
for k = 1:numClass
    write_curv(fullfile(outdir,['lh.Thres_tMapsClass_' num2str(k)]),AA(1:nbleft,k),fnumleft);
    write_curv(fullfile(outdir,['rh.Thres_tMapsClass_' num2str(k)]),AA(nbleft+1:end,k),fnumright);
end

disp('*********')
disp('group maps thresholding done')
disp('*********')

