function FMRI_ClusteringICAMaps(fsdir,datalist,subjlist,outdir,pref_ica,optfunc)

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


%% HIERARCHICAL CLUSTERING

if (optfunc.hierclus==1)
    
    disp('*****************************************')
    disp('CLUSTERING...')

    [resClust,dataHier] = FMRI_SurfHierClustering(datalist,pref_ica);

    save(fullfile(outdir,'resClust.mat'),'resClust');
    save(fullfile(outdir,'resClustData.mat'),'dataHier','-v7.3');

    disp('*********')
    disp('Hierarchical clustering done')
    disp('*********')
    
end

%% GROUP MAPS CALCULATION

if (optfunc.groupmaps == 1)
    
    disp('*****************************************')
    disp('GROUP MAPS...')

    opt.nbclasses     = 20;
    opt.thresHierType = 'auto'; % 'manual'
    load(fullfile(outdir,'resClust.mat'),'resClust');
    [numClass,resClust] = FMRI_SurfDoClasses(datalist,subjlist,pref_ica,resClust,outdir,opt);
    save(fullfile(outdir,'resClust.mat'),'resClust');
    % write tMaps
    for k = 1:numClass
        write_curv(fullfile(outdir,['lh.tMapsClass_' num2str(k)]),resClust.tMaps(1:nbleft,k),fnumleft);
        write_curv(fullfile(outdir,['rh.tMapsClass_' num2str(k)]),resClust.tMaps(nbleft+1:end,k),fnumright);
    end

    disp('*********')
    disp('Classes determination done')
    disp('*********')
    
end

%% GROUP MAPS THRESHOLDING

if (optfunc.threshmaps == 1)
    
    disp('*****************************************')
    disp('T-MAPS THRESHOLDING...')
    
    medwallfile = '/home/renaud/SVN/medial_wall.mat';
    load(medwallfile);
    Mask = ~Mask;

    load(fullfile(outdir,'resClust.mat'),'resClust');
    [resClust,AA,numClass] = FMRI_SurfThresholding(outdir,resClust,optfunc.thresP,Mask);
    resClust.ThreshMaps = AA;
    resClust.numClass   = numClass;
    resClust.cois = find(resClust.represent+resClust.unicity > 1.2);
    
    save(fullfile(outdir,'resClust.mat'),'resClust');
    
    % write tMaps
    for k = 1:length(resClust.cois)
        write_curv(fullfile(outdir,['lh.Thres_tMapsClass_' num2str(resClust.cois(k))]),AA(1:nbleft,resClust.cois(k)),fnumleft);
        write_curv(fullfile(outdir,['rh.Thres_tMapsClass_' num2str(resClust.cois(k))]),AA(nbleft+1:end,resClust.cois(k)),fnumright);
    end

    disp('*********')
    disp('group maps thresholding done')
    disp('*********')

end

%% CLUSTER MAPS THRESHOLDING

if (optfunc.threshclus == 1)
    
    disp('*****************************************')
    disp('CLUSTER-MAPS THRESHOLDING...')

    load(fullfile(outdir,'resClust.mat'),'resClust');
    
    surflh_file = fullfile(fspath,'subjects/fsaverage/surf/lh.white');
    surfrh_file = fullfile(fspath,'subjects/fsaverage/surf/rh.white');
    % write tMaps
    for k = 1:length(resClust.cois)        
        curv_file = fullfile(outdir,['lh.Thres_tMapsClass_' num2str(resClust.cois(k))]);
        clus_file = fullfile(outdir,['lh.ThresClus_tMapsClass_' num2str(resClust.cois(k))]);
        tmap_file = fullfile(outdir,['lh.ThresMap_tMapsClass_' num2str(resClust.cois(k))]);
        map_file  = fullfile(outdir,['lh.tMapsClass_' num2str(resClust.cois(k))]);
        FMRI_SurfCluster(surflh_file,curv_file,map_file,optfunc.thresP,optfunc.threshC,clus_file,tmap_file);
               
        curv_file = fullfile(outdir,['rh.Thres_tMapsClass_' num2str(resClust.cois(k))]);
        clus_file = fullfile(outdir,['rh.ThresClus_tMapsClass_' num2str(resClust.cois(k))]);
        tmap_file = fullfile(outdir,['rh.ThresMap_tMapsClass_' num2str(resClust.cois(k))]);
        map_file  = fullfile(outdir,['rh.tMapsClass_' num2str(k)]);
        FMRI_SurfCluster(surfrh_file,curv_file,map_file,optfunc.thresP,optfunc.threshC,clus_file,tmap_file);
    end

    disp('*********')
    disp('cluster maps thresholding done')
    disp('*********')

end

%%

if (optfunc.subcort == 1)
    
    %load(fullfile(outdir,'resClust.mat'),'resClust');
    
    nperm = 10000;
    
    FMRI_SurfRegressionSubCortical(fsdir,outdir,datalist,subjlist,optfunc.TR,nperm,fullfile(outdir,'resClust.mat'));
    
end

%% SAVE TIFF MAPS

if (optfunc.tiffmaps == 1)
   
    disp('*****************************************')
    disp('TIFF-MAPS ...')
    
    load(fullfile(outdir,'resClust.mat'),'resClust');
    
    if ( ~exist(fullfile(outdir,'tiffmaps'),'dir') )
        cmd = sprintf('mkdir %s',fullfile(outdir,'tiffmaps'));
        unix(cmd);
    end
    
    s = strfind(outdir,'/');
    fsdir = outdir(1:s(end)-1);
    subj  = outdir(s(end)+1:end);
    for k = 1:length(resClust.cois)
        
        cmd = sprintf('Make_montage.sh -fs %s -subj %s -surf %s -overlay %s -fminmax 0.95 1 -output %s -template',fsdir,subj,'white',['Thres_tMapsClass_' num2str(resClust.cois(k))],fullfile(outdir,'tiffmaps',['Coi_' num2str(resClust.cois(k))]));
        unix(cmd);
        
    end 
    
    disp('*********')
    disp('tiff maps thresholding')
    disp('*********')
    
end

