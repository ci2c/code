% %% Launch_VolICAcluster
outdir = '/home/fatmike/renaud/tep_fog/freesurfer/results';
fsdir  = '/home/fatmike/renaud/tep_fog/freesurfer';
subjlist = {'DELA';'PETI';'DEBA';'POCH';'DAMB';'BOND';'VASS';'DETH';'DENI';'ALIB';'MARQ';'BETT';'GORE';'DUMO';'BAUD';'LEFE';'BRAN';'LOUG';'ANDR';'SAEL';'RUCH';'VAND'};
nbsubjg1 = 11;
nbsubjg2 = 11;
maskFile = fullfile(fsdir,'g1',subjlist{1},'resting','wepi_mask.nii');

datalist  = {};
for k = 1 : nbsubjg1    
    datalist{k} = fullfile(fsdir,'g1',subjlist{k},'resting','ica_40_vol_sm');       
    NormEpi4D{k} = fullfile(fsdir,'g1',subjlist{k},'resting','wsvraepi_4D.nii'); 
end
for k = 1 : nbsubjg2    
    datalist{nbsubjg1+k} = fullfile(fsdir,'g2',subjlist{nbsubjg1+k},'resting','ica_40_vol_sm');      
    NormEpi4D{nbsubjg1+k} = fullfile(fsdir,'g2',subjlist{nbsubjg1+k},'resting','wsvraepi_4D.nii'); 
end

% pref_ica           = 'wica_map_';  
% optvol.hierclus   = 1;
% optvol.groupmaps  = 1;
% optvol.threshmaps = 1;
% optvol.clusters   = 1;
% optvol.SgroupAna  = 0;
% optvol.mapMNI     = 0;
% optvol.thresP     = 0.05;
% optvol.typeCorr   = 'FDR';
% optvol.numVox     = 10;
% optvol.clusC      = 30;
% optvol.sizeVox    = [3 3 3];
% optvol.csize      = 30;
% optvol.cdist      = 30;
% 
% % if(exist(outvol,'dir'))
% %     cmd = sprintf('rm -rf %s',outvol);
% %     unix(cmd);
% % end
% % cmd = sprintf('mkdir %s',outvol);
% % unix(cmd);
% 
% FMRI_VolClusteringICAMaps(datalist,subjlist,OutVol,pref_ica,optvol,maskFile);

%% Launch_VolStatsMaps
dataroot_tmp = '/home/notorious/users/renaud/volunteers_1000connectome/beijing/results/male/vol/clusAll_sm';
dataroot_tepfog = '/home/fatmike/renaud/tep_fog/freesurfer/OutVol';
mapFile = 'Thres_tMapsClass_';
SeuilCorr = 0.2;

index_tmp = [2 3 4 5 6 7 8 9 10 11 14 15 16 17 19 20 23 24 25 27 28 33];
index_tepfog = [1 2 3 4 5 6 8 10 11 13 30 31 34 35 44 45 46 47 49];

nb_tmp = size(index_tmp,2);
nb_tepfog = size(index_tepfog,2);

VectorTmpPath = {};
VectorTepFogPath = {};
MapTemp = [];
MapClus = [];
TMaps_4D = [];
maskPeaks = [];
maskROIs = [];
maskB = [];

% Lecture et stockage des volumes 3D des templates
for k = 1 : nb_tmp
    VectorTmpPath{k,1} = fullfile(dataroot_tmp,[mapFile num2str(index_tmp(k)) '.nii']);
    V_tmp = spm_vol(VectorTmpPath{k,1});
    V_tmp_read = spm_read_vols(V_tmp);
    MapTemp(k,:) = V_tmp_read(:);
    clear V_tmp V_tmp_read;    
end

% Lecture et stockage des volumes 3D des composantes indépendantes
for j = 1 : nb_tepfog
    VectorTepFogPath{j,1} = fullfile(dataroot_tepfog,[mapFile num2str(index_tepfog(j)) '.nii']);   
    V_tepfog = spm_vol(VectorTepFogPath{j,1});
    V_tepfog_read = spm_read_vols(V_tepfog);
    MapClus(j,:) =  V_tepfog_read(:);
    clear V_tepfog V_tepfog_read;   
end
 
% Calcul de la matrice de corrélation entre la matrice des composantes
% indépendantes et celle des templates
C = corr(MapClus',MapTemp');

% Recherche de la corrélation max de chaque template avec une composante
% indépendante
[OutMax,I] = max(C,[],1);

% Index unique des composantes indépendantes ayant la corrélation max avec
% les templates
I_Thres = unique(I(find(OutMax>0.2)));

% Construction de la matrice 4D des CI ayant la corrélation max avec
% les templates et extraction des maskRois pour chaque volume 3D
for m = 1 : size(I_Thres,2)
    TMaps = spm_vol(VectorTepFogPath{I_Thres(m),1});
    TMaps_4D(:,:,:,m) = spm_read_vols(TMaps);
    [maskPeaks(:,:,:,m),maskROIs(:,:,:,m),maskB(:,:,:,m)] = FMRI_MapToPeaks(TMaps_4D(:,:,:,m),[3 3 3 ],30,30);
end


%% Organisation of the NOI structure
[nx,ny,nz] = size(maskROIs(:,:,:,1));
sizeVox = [3 3 3];
listFiles  = {};

% Definition of the structure NOI
for NumNk = 1 : size(maskROIs,4)
%     NOI(NumNk).nameNk = ['Network',num2str(NumNk)];
    for NumRoi = 1 : max(unique(maskROIs(:,:,:,NumNk)))
%         NOI(NumNk).ROI(NumRoi).label = ['ROI',num2str(NumRoi)];
          NOI.Network(NumNk).ROI(NumRoi).label = ['ROI',num2str(NumRoi)];
          [x,y,z] = ind2sub([nx,ny,nz],find(maskROIs(:,:,:,NumNk)==NumRoi));   
           x = x.*sizeVox(1);
           y = y.*sizeVox(2);
           z = z.*sizeVox(3);
          NOI.Network(NumNk).ROI(NumRoi).coord3D = [x y z];
          clear x y z          
    end
end

% Definition of times courses associated to each ROI of each Network for each patient
for subj = 1 : length(subjlist)   
    Database(subj).name = subjlist{subj};
    for NumNk = 1 : size(maskROIs,4)
        [courbes_R,decours]=st_read_analyze_tc(maskROIs(:,:,:,NumNk),NormEpi4D{subj},'',1,0);
        for NumRoi = 1 : max(unique(maskROIs(:,:,:,NumNk)))
            Database(subj).Network(NumNk).ROI(NumRoi).decours = decours(:,NumRoi);
        end
        clear courbes_R decours
    end
end     
    
% decours = st_detrend_array(decours,2);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% function data_d = st_detrend_array(data,pow)
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % On effectue la regression
% nt = size(data,1);
% for i = 0:pow
%     X(:,i+1) = ((1:nt)').^i;
% end
% % - calcul des betas
% beta = (pinv(X'*X)*X')*data;
% 
% % - calcul des residus
% data_d = data - X*beta;
% %%%%%%%%%%%%%%% fin st_detrend_array %%%%%%%%%%%%%%%%%%%%