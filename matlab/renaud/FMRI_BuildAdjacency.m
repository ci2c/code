function [A,I] = FMRI_BuildAdjacency(mask,neig)

% function [A,I] = ned_build_adjacency(mask,neig)
% 
% Computes the adjacency matrix of voxels within a region of interest in a
% 3D volume.
%
% INPUTS
% mask    (3D array) binary mask of one 3D-region of interest (1s inside,
%         0s outside)
% neig    (integer value, if not specified = 26) definition of 3D-connexity (possible value 26)
%
% OUTPUTS
% A         (2D array) Adjacency matrix of voxels inside the mask. Order of the voxels
%           is given by I.
% I         (vector) list of linear index of voxels inside the region of
%           interest in array mask.
%


% On teste s'il y a une ou plusieurs regions
nb_regions = max(mask(:));

% Default inputs
if nargin == 1
    neig = 6;
end

if nb_regions > 1
    
    for num_r = 1:nb_regions
        [A_tmp,I_tmp] = ned_build_adjacency(mask==num_r,neig);
        A{num_r} = A_tmp;
        I{num_r} = I_tmp;
    end
    
else
    
    % On recherche les indices lineaires et les coordonnees 3D des voxels du masque
    I = find(mask(:));
    N = length(I);
    [nx,ny,nz] = size(mask);
    [coordx,coordy,coordz] = ind2sub(size(mask),I);
    coord = [coordx,coordy,coordz];
    
    if neig == 26
        % On cree un vecteur decxyz contenant les decalages possibles entre les coordonnees des neigins.
        dec = [0,1,-1];
        num = 1;
        for i = 1:3
            for j = 1:3
                for k = 1:3
                    decxyz(num,:) = [dec(i),dec(j),dec(k)];
                    num = num + 1;            
                end
            end
        end
        decxyz = decxyz(2:27,:);
    elseif neig == 6
        decxyz = [1 0 0;-1 0 0; 0 1 0; 0 -1 0; 0 0 1; 0 0 -1];        
    end
    
    long_neig = length(decxyz);
    % on genere un vecteur v contenant 26 1 puis 26 2 puis ... 26 length(I)
    v = 1/length(decxyz):1/length(decxyz):N;
    v = ceil(v);
    
    % On cree la matrice des neigins
    neigx = ones([long_neig 1])*coord(:,1)' + decxyz(:,1)*ones([1 N]);
    neigy = ones([long_neig 1])*coord(:,2)' + decxyz(:,2)*ones([1 N]);
    neigz = ones([long_neig 1])*coord(:,3)' + decxyz(:,3)*ones([1 N]);
    
    neig = [neigx(:) neigy(:) neigz(:)];
    %on vire les neigins hors du volume
    in_vol = (neigx(:)>0)&(neigx(:)<=nx)&(neigy(:)>0)&(neigy(:)<=ny)&(neigz(:)>0)&(neigz(:)<=nz);
    garde = in_vol;
    garde(in_vol) = mask(sub2ind(size(mask),neigx(in_vol),neigy(in_vol),neigz(in_vol)));
    
    % On cree la matrice d'adjacence
    I1 = I(v);
    I2 = sub2ind(size(mask),neig(garde,1),neig(garde,2),neig(garde,3));
    I1 = I1(garde);
    diagx = (1:nx*ny*nz)';
    I1 = [diagx;I1];
    I2 = [diagx;I2];
    
    A = sparse(I1,I2,ones(size(I1)),nx*ny*nz,nx*ny*nz);
    A = A(I,I);
    
end
