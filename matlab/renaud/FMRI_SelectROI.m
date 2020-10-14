function resClust = FMRI_SelectROI(epipath,subjectlist,infolder,resClust,sizeVox,csize,cdist)

resClust.roi = [];
prefix = 'wcs';
nsubj  = length(subjectlist);

for k = 1:nsubj
    
    datapath = fullfile(epipath,subjectlist{k},infolder,'RawEPI');
    
    DirImg = dir(fullfile(datapath,[prefix '*.nii']));

    FileList = [];
    for j = 1:length(DirImg)
        FileList = [FileList;fullfile(datapath,[DirImg(j).name])];
    end
    
    datafiles{k} = FileList;
    
end
clear FileList;

%data = FMRI_PreprocessTimeCourse(epipath,nsess,'sar',resClust.maskB);

delete([epipath filesep 'nedica' filesep 'Classes' filesep 'COI' filesep '*_roi.nii']);
delete([epipath filesep 'nedica' filesep 'Classes' filesep 'COI' filesep '*_peak.nii']);

FileList = SurfStatListDir(fullfile(epipath,'nedica','Classes','COI','Thres_tMaps*.nii'));

for k = 1:length(FileList)
    
    disp(['COI: ' num2str(k)]);
    
    hdr_tmap = spm_vol(FileList{k});
    tMap     = spm_read_vols(hdr_tmap);
    rot      = hdr_tmap.mat(1:3,1:3);
    trans    = hdr_tmap.mat(1:3,4);

    [maskPeaks,maskROIs] = FMRI_MapToPeaks(tMap,sizeVox,csize,cdist);

    nbrois            = max(unique(maskROIs));
    resClust.roi{k}.N = nbrois;
    
    if(nbrois>0)
        
        % Save result images 
        indext = findstr(FileList{k},'.');
        hdr_tmap.fname = [FileList{k}(1,1:indext-1) '_roi' FileList{k}(1,indext:end)];
        spm_write_vol(hdr_tmap,maskROIs);
        hdr_tmap.fname = [FileList{k}(1,1:indext-1) '_peak' FileList{k}(1,indext:end)];
        spm_write_vol(hdr_tmap,maskPeaks);
        
        % Mean time courses of BOLD signal and mean time course of ICA
        % components.
        resClust.roi{k}.Comp     = zeros(nsubj,size(resClust.timeCourses,1));
        resClust.roi{k}.meanBold = [];
        %resClust.roi{k}.meanBold = zeros(nbrois,size(resClust.timeCourses,1),nsess);
        
        to_keep  = find(resClust.maskB(:)>0);
        maskROIs = maskROIs(:);
        maskROIs = maskROIs(to_keep);
        maskROIs = st_1Dto3D(maskROIs,resClust.maskB);
        
        % Time courses of ROIs
        for j = 1:nsubj
            
            ind = find( resClust.P((j-1)*resClust.nbCompSica+1:j*resClust.nbCompSica) == k );
            if length(ind)>0
                timeComps = resClust.timeCourses(:,(j-1)*resClust.nbCompSica+1:j*resClust.nbCompSica);
                timeComps = timeComps(:,ind)';
                timeComps = mean(timeComps,1);
                resClust.roi{k}.Comp(j,:) = timeComps;
            end
            
            [courbes_R,decours] = FMRI_ReadNiftiTc(maskROIs,datafiles{j},1);
            decours = st_normalise(decours);
            resClust.roi{k}.meanBold{j} = decours; 
            
        end
        
        % name of ROIs
        for nr = 1:nbrois
            resClust.roi{k}.nameRoi{nr} = ['C' num2str(k) '_' num2str(nr)];
        end
        
        % peaks coordinates (voxel)
        tmp     = maskPeaks(:);
        ind     = find(tmp>0);
        val     = tmp(ind);
        [Y,I]   = sort(val);
        ind     = ind(I);       
        [x,y,z] = ind2sub(size(maskPeaks),ind);
        resClust.roi{k}.coord = [x y z];
        
        % peaks coordinates (mm)
        coord_mm = zeros(nbrois,3);
        for j = 1:nbrois
            coord_mm(j,:) = (rot * resClust.roi{k}.coord(j,:)' + trans)' ;
        end
        resClust.roi{k}.coord_mm = coord_mm;    
    end
               
end

clear data maskROIs maskPeaks;
