function FMRI_VolClusteringICAMaps(datalist,subjlist,outdir,pref_ica,optfunc,maskFile)

hdrmask = spm_vol(maskFile);
mask    = spm_read_vols(hdrmask);
indmask = find(mask(:)>0);

hdrsave = spm_vol(fullfile(datalist{1},[pref_ica '1.nii']));
dim     = hdrsave.dim;

%% HIERARCHICAL CLUSTERING

if (optfunc.hierclus==1)
    
    disp('*****************************************')
    disp('CLUSTERING...')

    [resClust,dataHier] = FMRI_HierClustering(datalist,pref_ica,maskFile);

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
    [numClass,resClust] = FMRI_VolDoClasses(datalist,subjlist,pref_ica,resClust,outdir,opt,maskFile);
    
    save(fullfile(outdir,'resClust.mat'),'resClust');
    
    % write tMaps
    for k = 1:numClass
        
        hdrsave.fname = fullfile(outdir,['tMapsClass_' num2str(k) '.nii']);
        vol = zeros(dim);
        vol = vol(:);
        vol(indmask) = resClust.tMaps(:,k);
        vol = reshape(vol,dim(1),dim(2),dim(3));
        spm_write_vol(hdrsave,vol);
        clear vol;
        
    end

    disp('*********')
    disp('Classes determination done')
    disp('*********')
    
end

%% GROUP MAPS THRESHOLDING

if (optfunc.threshmaps == 1)
    
    disp('*****************************************')
    disp('T-MAPS THRESHOLDING...')

    load(fullfile(outdir,'resClust.mat'),'resClust');
    [resClust,AA,numClass] = FMRI_VolThresholding(outdir,resClust,optfunc.thresP,optfunc.typeCorr,optfunc.numVox,maskFile);
    resClust.ThreshMaps = AA;
    resClust.numClass   = numClass;
    resClust.cois       = find(resClust.represent+resClust.unicity > 1.2);
    
    save(fullfile(outdir,'resClust.mat'),'resClust');
    
    % write tMaps
    for k = 1:length(resClust.cois)
        
        hdrsave.fname = fullfile(outdir,['Thres_tMapsClass_' num2str(resClust.cois(k)) '.nii']);
%         vol = zeros(dim);
%         vol = vol(:);
%         vol(indmask) = AA(:,resClust.cois(k));
%         vol = reshape(vol,dim(1),dim(2),dim(3));
        spm_write_vol(hdrsave,AA(:,:,:,resClust.cois(k)));
        clear vol;
        
    end
    
    disp('*********')
    disp('group maps thresholding done')
    disp('*********')

end


%% DEFINE CLUSTERS

if (optfunc.clusters == 1)
    
    disp('*****************************************')
    disp('CLUSTERS...')

    load(fullfile(outdir,'resClust.mat'),'resClust');
    
    for k = 1 : length(resClust.cois)

        coi = resClust.cois(k);

        [maskPeaks,maskROIs,maskB] = FMRI_MapToPeaks(resClust.ThreshMaps(:,:,:,coi),optfunc.sizeVox,optfunc.csize,optfunc.cdist);

        hdrsave.fname = fullfile(outdir,['ThresClus_tMapsClass_' num2str(coi) '.nii']);
        spm_write_vol(hdrsave,maskB);

%         % typeRet='none';
%         typeRet='+90';
%         % typeRet='+180';
%         %typeRet='-90';
% 
%         flipLR=0;
%         %flipLR=1;
%         figure;
%         ned_visu_roi(st_flip_volume(anat,typeRet,flipLR),st_flip_volume(resClust.ThreshMaps(:,:,:,coi),typeRet,flipLR),'jet');

    end
    
    disp('*********')
    disp('clusters done')
    disp('*********')
    
end

%% GROUP ANALYSIS ON CORTICAL SURFACE

if (optfunc.SgroupAna == 1)
    
    disp('*****************************************')
    disp('GROUP ANALYSIS ON CORTICAL SURFACE ...')
    
    fspath    = '/home/global/freesurfer';
    surf      = SurfStatReadSurf([fullfile(fspath,'subjects/fsaverage/surf/lh.white')]);
    fnumleft  = size(surf.tri,1);
    nbleft    = size(surf.coord,2);
    surf      = SurfStatReadSurf([fullfile(fspath,'subjects/fsaverage/surf/rh.white')]);
    fnumright = size(surf.tri,1);
    nbright   = size(surf.coord,2);
    clear surf;

    load(fullfile(outdir,'resClust.mat'),'resClust');
    
    pref_Sica = 'fsaverage_ica_map_';
    thresPval = 0.95;
    thresClus = 100;
    
    % Group maps
    
    [numClass,resClust,SdataHier] = FMRI_GroupAnalysisFromICAMapsOnSurface(resClust,pref_Sica);
    
    save(fullfile(outdir,'resClust.mat'),'resClust');
    save(fullfile(outdir,'resClustSData.mat'),'SdataHier','-v7.3');
    clear SdataHier;
    
    % write tMaps
    for k = 1:numClass
        write_curv(fullfile(outdir,['lh.tMapsClass_' num2str(k)]),resClust.StMaps(1:nbleft,k),fnumleft);
        write_curv(fullfile(outdir,['rh.tMapsClass_' num2str(k)]),resClust.StMaps(nbleft+1:end,k),fnumright);
    end
    
    % Thresholded maps
    
    medwallfile = '/home/renaud/NAS/pierre/MOMIC/Cortical_thick/medial_wall.mat';
    load(medwallfile);
    Mask = ~Mask;
    
    [resClust,AA,numClass] = FMRI_SurfThresholdingAfterVolAna(outdir,resClust,thresPval,Mask);
    resClust.SThreshMaps = AA;
    
    save(fullfile(outdir,'resClust.mat'),'resClust');
    
    % write tMaps
    for k = 1:length(resClust.cois)
        write_curv(fullfile(outdir,['lh.Thres_tMapsClass_' num2str(resClust.cois(k))]),AA(1:nbleft,resClust.cois(k)),fnumleft);
        write_curv(fullfile(outdir,['rh.Thres_tMapsClass_' num2str(resClust.cois(k))]),AA(nbleft+1:end,resClust.cois(k)),fnumright);
    end
    
    % Cluster maps
    
    surflh_file = fullfile(fspath,'subjects/fsaverage/surf/lh.white');
    surfrh_file = fullfile(fspath,'subjects/fsaverage/surf/rh.white');
    % write tMaps
    for k = 1:length(resClust.cois)        
        curv_file = fullfile(outdir,['lh.Thres_tMapsClass_' num2str(resClust.cois(k))]);
        clus_file = fullfile(outdir,['lh.ThresClus_tMapsClass_' num2str(resClust.cois(k))]);
        tmap_file = fullfile(outdir,['lh.ThresMap_tMapsClass_' num2str(resClust.cois(k))]);
        map_file  = fullfile(outdir,['lh.tMapsClass_' num2str(resClust.cois(k))]);
        FMRI_SurfCluster(surflh_file,curv_file,map_file,thresPval,thresClus,clus_file,tmap_file);
               
        curv_file = fullfile(outdir,['rh.Thres_tMapsClass_' num2str(resClust.cois(k))]);
        clus_file = fullfile(outdir,['rh.ThresClus_tMapsClass_' num2str(resClust.cois(k))]);
        tmap_file = fullfile(outdir,['rh.ThresMap_tMapsClass_' num2str(resClust.cois(k))]);
        map_file  = fullfile(outdir,['rh.tMapsClass_' num2str(k)]);
        FMRI_SurfCluster(surfrh_file,curv_file,map_file,thresPval,thresClus,clus_file,tmap_file);
    end
    
    disp('*********')
    disp('GROUP ANALYSIS ON CORTICAL SURFACE')
    disp('*********')
    
end

%% MAPPING MNI VOLUME ON CORTICAL SURFACE

if (optfunc.mapMNI == 1)
    
    load(fullfile(outdir,'resClust.mat'),'resClust');
    
    for k = 1:length(resClust.cois) 
        
        coi = resClust.cois(k);
        
        map_file = fullfile(outdir,['Thres_tMapsClass_' num2str(coi) '.nii']);
        
        curv_file = fullfile(outdir,['lh.Vol_Thres_tMapsClass_' num2str(coi) '.mgh']);
        cmd = sprintf('mri_vol2surf --mov %s --mni152reg --hemi lh --o %s --trgsubject fsaverage --interp trilinear --projfrac 0.5',map_file,curv_file);
        unix(cmd);
        
        curv_file = fullfile(outdir,['rh.Vol_Thres_tMapsClass_' num2str(coi) '.mgh']);
        cmd = sprintf('mri_vol2surf --mov %s --mni152reg --hemi rh --o %s --trgsubject fsaverage --interp trilinear --projfrac 0.5',map_file,curv_file);
        unix(cmd);
        
    end
    
end
