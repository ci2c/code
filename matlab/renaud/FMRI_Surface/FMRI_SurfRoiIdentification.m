function [vert_max,vert_surf,cg_surf,vert_vert,cg_vert,name_max,name_vert,name_surf] = FMRI_SurfRoiIdentification(surf,clus_map,tmap,parc_map)

if ~ isstruct(surf)
    surf = SurfStatReadSurf({surf});
end

if ~ isnumeric(clus_map)
    clus_map = SurfStatReadData(clus_map);
end

if ~ isnumeric(tmap)
    tmap = SurfStatReadData(tmap);
end

if nargin < 4
    parc_map = '/home/global/freesurfer/subjects/fsaverage/label/lh.aparc.a2009s.annot';
end

[parc, parc_label, colortable] = read_annotation(parc_map);

c = surf.coord;
f = surf.tri;

if size(c,2) ~= 3, c=c'; end
if size(f,2) ~= 3, f=f'; end
if size(clus_map,2) ~= 1, clus_map=clus_map(:); end
if size(tmap,2) ~= 1, tmap=tmap(:); end

% Loop over number of rois

nbroi = max(clus_map);

cg_surf   = zeros(nbroi,3);
cg_vert   = zeros(nbroi,3);
vert_surf = zeros(nbroi,1);
vert_vert = zeros(nbroi,1);
vert_max  = zeros(nbroi,1);

for n = 1:nbroi
    
    disp(n)
    
    ind = find(clus_map==n);
    
    % maxima
    [maxi,I] = max(tmap(ind));
    vert_max(n,1) = ind(I);
    name_max{n,1} = colortable.struct_names{find(colortable.table(:,5)==parc_label(ind(I)))};
    
    % Le centre de gravité des vertices
    coord = c(ind,:);
    cg_vert(n,:) = mean(coord);
    
    tokeep = [];
    for k = 1:length(ind)
        tokeep = [tokeep; find(f(:,1)==ind(k))];
        tokeep = [tokeep; find(f(:,2)==ind(k))];
        tokeep = [tokeep; find(f(:,3)==ind(k))];
    end
    tokeep = unique(tokeep);

    facetokeep = f(tokeep,:);
    
    % coordinates of triangle nodes
    p = c(facetokeep(:,1),:);
    q = c(facetokeep(:,2),:);
    r = c(facetokeep(:,3),:);

    % vectors of two sides of triangles
    pq = p-q;
    pr = p-r;

    % face area: .5*sqrt(   |a|^2*|b|^2 - (a.b)^2    ) 
    % where a=pq, b=pr and (a.b) means dot product
    face2area = .5*sqrt(sum(pq.^2,2).*sum(pr.^2,2)-sum(pq.*pr,2).^2);

    % P étant un volume possedant des faces et des vertices
    centre = zeros(size(facetokeep,1),3);
    
    % le centroide de chaque triangle
    centre = (p+q+r)./3;

    % le centre de gravité de la surface

    % La surface est constituée de triangles c'est le barycentre (pondéré) des barycentres. La pondération est l'aire de chaque triangle.
    % Polygon.Centroid = somme { Triangle.centroid * Triangle.area } / somme {
    % Triangle.area }
    
    for k=1:3
        cg_surf(n,k)=sum(centre(:,k).*face2area(:))/sum(face2area(:));
    end

    % Vertex corresponding to gravity center

    diffmins  = 500;
    diffminv  = 500;

    for k = 1:length(ind)

        tmp = norm(cg_surf(n,:)-c(ind(k),:));
        if tmp < diffmins
            diffmins = tmp;
            vert_surf(n,1) = ind(k);
        end

        tmp = norm(cg_vert(n,:)-c(ind(k),:));
        if tmp < diffminv
            diffminv = tmp;
            vert_vert(n,1) = ind(k);
        end

    end
    
    name_vert{n,1} = colortable.struct_names{find(colortable.table(:,5)==parc_label(vert_vert(n,1)))};
    name_surf{n,1} = colortable.struct_names{find(colortable.table(:,5)==parc_label(vert_surf(n,1)))};
    
end
