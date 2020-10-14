function [resClust,AA,numClass] = FMRI_VolThresholding(sesspath,resClust,thresP,typeCorr,numVox,maskFile)

% usage : [resClust,AA,numClass] = FMRI_VolThresholding(sesspath,resClust,thresP,typeCorr,numVox,maskFile)
%
% Inputs :
%    sesspath      : path to data
%    resClust      : structure of clustering results
%    thresP        : threshold value for pvalue (FDR correction)
%    typeCorr      : type of correction (BONF - FDR - UNC)
%    numVox        : minimum size of clusters
%    maskFile      : mask file
%
% Output :
%    resClust      : structure of clustering results
%    AA            : thresholded maps
%    numClass      : number of classes
%
% Renaud Lopes @ CHRU Lille, Feb 2013

if nargin ~= 6
    error('invalid usage');
end

hdrmask = spm_vol(maskFile);
mask    = spm_read_vols(hdrmask);
indmask = find(mask(:)>0);

P            = resClust.P;
opt          = resClust.optClust;  
opt.thresP   = thresP;
opt.typeCorr = typeCorr;
opt.numVox   = numVox;
resClust     = setfield(resClust,'optClust',opt);

if isfield(resClust,'tMaps')
    tMaps_pos = resClust.tMaps;
else
    disp(['Warning -- No tMaps'])
    return
end
numClass = size(tMaps_pos,2);
for pp = 1:numClass
    I             = find(P==pp);
    sizeClust(pp) = length(I);
end

nsubj = round(length(resClust.contrib)/resClust.nbCompSica);

[nx ny nz] = size(mask);
tMaps = zeros(nx,ny,nz,size(tMaps_pos,2));
tMaps = reshape(tMaps,nx*ny*nz,size(tMaps_pos,2));
for k = 1 : size(tMaps_pos,2)
    tMaps(indmask,k) = tMaps_pos(:,k);
end
tMaps = reshape(tMaps,nx,ny,nz,size(tMaps_pos,2));

if nsubj == 1
    
    disp('single run - use individual z-score maps - z-score > 2 and extension > 5 voxels')
    for pp=1:numClass
        mask_pos(:,:,:,pp) = tMaps(:,:,:,pp) > 2;
        opt_conn.type_neig = 26;
        opt_conn.thre_size = 5;
        [mask_pos2(:,:,:,pp),taille_pos{pp}] = niak_find_connex_roi(mask_pos(:,:,:,pp),opt_conn);
        
        tMaps_pos_v(:,pp) = reshape(tMaps(:,:,:,pp),[nx*ny*nz 1]);
        mask_pos2_v(:,pp) = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
        tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;
    end
    AA = reshape(tMaps_pos_v,[nx ny nz numClass]);
    
else
    
    for pp=1:numClass
        
        if strcmp(typeCorr,'BONF')
            
            nu = sum(sum(sum(mask>0)));
            thresTcorr = thresP/nu;
            p_pos(:,:,:,pp) = (1-spm_Tcdf(tMaps(:,:,:,pp),sizeClust(pp)));
            mask_pos(:,:,:,pp) = p_pos(:,:,:,pp) < thresTcorr;
            
        elseif strcmp(typeCorr,'FDR')
            
            V = spm_vol(fullfile(sesspath,['tMapsClass_' num2str(pp) '.nii']));
            %d = spm_read_vols(V);
            thresTcorr = spm_uc_FDR(thresP,[1 sizeClust(pp)],'T',1,V);
            mask_pos(:,:,:,pp) = tMaps(:,:,:,pp) > thresTcorr;
            
        elseif strcmp(typeCorr,'UNC')
            
            p_pos(:,:,:,pp) = (1-spm_Tcdf(tMaps(:,:,:,pp),sizeClust(pp)));
            mask_pos(:,:,:,pp) = p_pos(:,:,:,pp) < thresP;
            
        end
        if length(unique(mask_pos(:,:,:,pp)))>1
            
            opt_conn.type_neig = 26;
            opt_conn.thre_size = numVox;
            [mask_pos2(:,:,:,pp),taille_pos{pp}] = Find_connex_roi(mask_pos(:,:,:,pp),opt_conn);

            tMaps_pos_v(:,pp) = reshape(tMaps(:,:,:,pp),[nx*ny*nz 1]);
            mask_pos2_v(:,pp) = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
            tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;
            
        else
            
            mask_pos2(:,:,:,pp) = double(mask_pos(:,:,:,pp));
            taille_pos{pp} = [];
            tMaps_pos_v(:,pp) = reshape(tMaps(:,:,:,pp),[nx*ny*nz 1]);
            mask_pos2_v(:,pp) = reshape(mask_pos2(:,:,:,pp),[nx*ny*nz 1]);
            tMaps_pos_v(squeeze(mask_pos2_v(:,pp))==0,pp) = 0;
            
        end
        

    end
    AA = reshape(tMaps_pos_v,[nx ny nz numClass]);
        
end
