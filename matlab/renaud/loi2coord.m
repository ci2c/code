function coord = loi2coord(hdr,idx,sx,sy)

% Computes the 3D coordinates of the voxels in a region of interest of a 3D volume.
%
% coord = loi2coord(hdr,idx,sx,sy)
%
% INPUTS
% rois      (structure) a rois type structure (see
%           ~/documentation/lsn_Objects_description.rtf).
%
% OUTPUTS
% coord     (2D matrix) coord(i,:) is the 3D coordinate of
%           the centroid of the ith region.
%

sxy = sx*sy;
for k = 1:length(idx)

    cz = floor(idx(k)/sxy);
    
    if( rem(idx(k),sxy)==0 )
        cz = cz-1;        
    end
    
    ind = idx(k)-sxy*cz;
    cy  = floor(ind/sx);
    
    if(rem(ind,sx)==0)
        cy = cy-1;
    end
    
    cx = ind-cy*sx;
        
    coordx(k,1) = cx;
    coordy(k,1) = cy+1;
    coordz(k,1) = cz+1;
    
end
rot        = hdr.mat(1:3,1:3);
trans      = hdr.mat(1:3,4);
mean_coord = mean([coordx coordy coordz],1)';
coord(1,:) = (rot * mean_coord + trans)';
