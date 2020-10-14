function [maskPeaks,maskROIs,maskB] = FMRI_MapToPeaks(tMap,sizeVox,csize,cdist)

% usage : [maskPeaks,maskROIs] = FMRI_MapToPeaks(tMap,sizeVox,csize,cdist)
%
% Inputs :
%    tMap          : 3d matrix
%    sizeVox       : voxels dimensions (matrix 1x3)
%
% Defaults :
%    csize         : cluster size
%    cdist         : minimum distance between 2 clusters
%
% Output :
%    maskPeaks     : structure of clustering results
%    maskROIs      : thresholded maps
%    numClass      : number of classes
%
% Renaud Lopes @ CHRU Lille, Feb 2013

[nx,ny,nz]         = size(tMap);
opt_conn.type_neig = 26;
opt_conn.thre_size = 0;
maskC              = Find_connex_roi(tMap>0,opt_conn);
nbC                = max(unique(maskC));

maskB = maskC(:);
for k = 1:nbC
    ind=find(maskC==k);
    if(length(ind)<csize)
        maskB(ind)=0;
    end
end
maskB = reshape(maskB,nx,ny,nz);

if nbC == 0
    maskPeaks = [];
    maskROIs  = [];
    return
end

maskPeaks = zeros(size(tMap(:)));
maskROIs  = zeros(size(tMap(:)));
countROI  = 1;

for numC = 1:nbC
    
    mask = maskC == numC;
    
    while sum(mask(:)==1)>=csize
        
        A        = FMRI_BuildAdjacency(mask>0);
        tMap_tmp = tMap(:);
        tMap_tmp(mask(:)==0) = 0;
        [m,JJ]   = max(tMap_tmp)
        maskPeaks(JJ) = countROI;
        mask_tmp = maskPeaks == countROI;
        mask_tmp = mask_tmp(mask(:)>0);
        tMap_tmp = tMap_tmp(mask(:)>0);
        while sum(mask_tmp)<csize
            I = find(mask_tmp>0);
            tMap_tmp(I) = 0;
            indVox = [];
            for pp = 1:length(I)
                J = find(A(I(pp),:)>0);
                indVox = [indVox J];
            end
            indVox = unique(indVox);
            [MM,K] = max(tMap_tmp(indVox));

            if isempty(MM)||MM==0
                break
            else
                mask_tmp(indVox(K))=1;
                if (mod(sum(mask_tmp),10) == 0)
                    %fprintf('%d ',sum(mask_tmp));
                end
            end
        end
        
        if sum(mask_tmp)<csize
            
            M = zeros(size(mask));
            M = M(:);
            M(mask(:)) = mask_tmp;
            mask(M>0) = 0;
            
        else
            
            maskROIs(mask(:)>0) = mask_tmp.*countROI;
            maskTmp = reshape(maskROIs,nx,ny,nz);
            mask(maskTmp>0) = 0;
            maskC(maskTmp>0) = 0;
                        
            [x,y,z] = ind2sub([nx,ny,nz],JJ);
            x = x*sizeVox(1);
            y = y*sizeVox(2);
            z = z*sizeVox(3);           
            [XX,YY,ZZ] = ndgrid((1:nx).*sizeVox(1),(1:ny).*sizeVox(2),(1:nz).*sizeVox(3)); 
            D = sqrt((XX-x).^2+(YY-y).^2+(ZZ-z).^2);
            maskD = D<cdist; 
            mask(maskD) = 0;
            maskC(maskD) = 0;
            disp(strcat('ROI #',num2str(countROI)))
            countROI = countROI + 1;
            
        end
        
    end
    
end

maskPeaks = reshape(maskPeaks,nx,ny,nz);
maskROIs  = reshape(maskROIs,nx,ny,nz);
