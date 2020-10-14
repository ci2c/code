function PrepareMatrix(surf_path, mat_path, out_path, erase_flag)
% usage: PrepareMatrix(surf_path, mat_path, out_path, [erase_flag])
%
% Prepare matrices for further clustering
% 
%  Inputs :
%     surf_path      : path to the surface. If left / right surface used,
%            set surf_path to [{'/path/lh.white'}, {'/path/rh.white'}]
%
%     mat_path       : path to the structure of triangles / fibers selection as
%            returned by getFastTriangleConnectMat
%
%     out_path       : output directory to store output matrices
%
%  Option :
%     erase_flag     : set 1 if output matrices are to be overwritten.
%                        Default : 0
%
% What is performed :
%    1. Compute triangle connectivity matrix
%       -> saved as TriCMat
%    2. Compute triangle neighbours matrix
%       -> saved as TriNeighbours
%    3. Smooth triangle connectivity matrix using 4 iterations
%       -> saved as TriCMatSmooth
%    4. Make it symmetric
%       -> saved as TriCMatSmoothSym
%    5. Convert to vertex fiber selection matrix
%       -> saved as VertexS
%    6. Get vertex neighbours
%       -> saved as VertexNeighbours
%    7. Get vertex fiber density
%       -> saved as VertexDensity
%    8. Get distance across vertices up to 5 hops
%       -> saved as VertexDistance
%    9. Smooth VertexDensity at FWHM = 5 mm, 10 mm and 15 mm
%       -> saved as VertexDensitySmooth
%   10. Compute vertex connectivity matrix taking into account neighbours area
%       -> saved as VertexCMat
%   11. Blur the vertex connectivity matrix using 4 iterations
%       -> saved as VertexCMatSmooth
%   12. Make it symmetric
%       -> saved as VertexCMatSmoothSym
%
% See also getFastTriangleConnectMat
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin == 3
    erase_flag = 0;
end

try
    Surf = SurfStatReadSurf(surf_path);
catch
    error(['cannot read ' surf_path]);
end

try
    eval(['load ' mat_path]);
catch
    error(['cannot load ' mat_path]);
end

if exist(out_path, 'dir') ~= 7
    mkdir(out_path);
end

% Define some parameters
ntri  = size(Surf.tri, 1);
nvert = size(Surf.coord, 2);
nfib = size(C.selected, 1);

% Step 0. Save fused surface as .obj
if exist(fullfile(out_path, 'surface.obj'), 'file') ~= 2 || erase_flag ~= 0
    SurfStatWriteSurf(fullfile(out_path, 'surface.obj'), Surf);
end

% Step 0.2. Save triangle selection matrix
TriS = C.selected;
eval(['save ' fullfile(out_path, 'TriS.mat') ' TriS']);
    

% Step 1. Compute triangle connectivity matrix
% taking into account triangle areas
if exist(fullfile(out_path, 'TriCMat.mat'), 'file') ~= 2 || erase_flag ~= 0
    X = Surf.coord(1,:);
    Y = Surf.coord(2,:);
    Z = Surf.coord(3,:);

    X = X(Surf.tri);
    Y = Y(Surf.tri);
    Z = Z(Surf.tri);

    Xab = (X(:,2) - X(:,1));
    Xac = (X(:,3) - X(:,1));
    Yab = (Y(:,2) - Y(:,1));
    Yac = (Y(:,3) - Y(:,1));
    Zab = (Z(:,2) - Z(:,1));
    Zac = (Z(:,3) - Z(:,1));
    N = cross([Xab Yab Zab], [Xac Yac Zac]);
    A = 0.5 .* sqrt( N(:,1).*N(:,1) + N(:,2).*N(:,2) + N(:,3).*N(:,3) );
    
    TriCMat = double(C.selected~=0);
    TriCMat = TriCMat' * TriCMat;
    TriCMat(speye(size(TriCMat)) ~= 0) = 0;
    TriCMat(speye(size(TriCMat)) ~= 0) = sum(TriCMat); % Diagonal elements are the fiber density at each triangle
    
    [index_i, index_j, index_k] = find(TriCMat);
    TriCMat = sparse(index_i, index_j, 2 * index_k ./ (A(index_i) + A(index_j)), ntri, ntri);
    
    clear index_i index_j index_k X Y Z Xab Xac Yab Yac Zab Zac N A;
    
    eval(['save ' fullfile(out_path, 'TriCMat.mat') ' TriCMat']);
else
    eval(['load ' fullfile(out_path, 'TriCMat.mat')]);
end

% Step 2. Compute triangle neighbours
% Def : two triangles are neighbours if they share 2 points (= 1 edge)
% A triangle is a neighbour to itself
if exist(fullfile(out_path, 'TriNeighbours.mat'), 'file') ~= 2 || erase_flag ~= 0
    tri_id = (1:ntri)';
    tri1   = double(Surf.tri(:,1));
    tri2   = double(Surf.tri(:,2));
    tri3   = double(Surf.tri(:,3));
    
    tri_vert = sparse(tri_id, tri1, ones(size(tri_id)), ntri, nvert) + sparse(tri_id, tri2, ones(size(tri_id)), ntri, nvert) + sparse(tri_id, tri3, ones(size(tri_id)), ntri, nvert);
    TriNeighbours = tri_vert * tri_vert';
    TriNeighbours = TriNeighbours > 1;
    
    clear tri_id tri1 tri2 tri3 tri_vert;
    eval(['save ' fullfile(out_path, 'TriNeighbours.mat') ' TriNeighbours']);
else
    load(fullfile(out_path, 'TriNeighbours.mat'));
end

% Step 3. Smooth triangle connectivity matrix using nearest-neighbours
% iterative algorithm, 4 iterations
if exist(fullfile(out_path, 'TriCMatSmooth.mat'), 'file') ~= 2 || erase_flag ~= 0
    Diag = 1./sum(TriNeighbours);
    sV1 = spdiags(Diag', 0, ntri, ntri);
    Vn  = sV1 * TriNeighbours;
    
    % 4 iterations
    TriCMatBlur = TriCMat;
    for i = 1 : 4
        TriCMatBlur = Vn * TriCMatBlur;
    end
    
    TriCMatBlur(sV1~=0) = 0;
    clear sV1 Diag Vn;
    
    isolated_faces = sum(TriCMatBlur) == 0;
    
    eval(['save ' fullfile(out_path, 'TriCMatSmooth.mat') ' TriCMatBlur isolated_faces -v7.3']);
else
    eval(['load ' fullfile(out_path, 'TriCMatSmooth.mat')]);
end

% Step 4. Convert to vertex fiber selection matrix
if exist(fullfile(out_path, 'VertexS.mat'), 'file') ~= 2 || erase_flag ~= 0
    Temp = double(C.selected ~= 0);
    [i, j] = find(Temp);
    tri1 = double(Surf.tri(j, 1));
    tri2 = double(Surf.tri(j, 2));
    tri3 = double(Surf.tri(j, 3));
    VertexSelected = sparse(i, tri1, ones(size(i)), nfib, nvert) + sparse(i, tri2, ones(size(i)), nfib, nvert) + sparse(i, tri3, ones(size(i)), nfib, nvert);
    VertexSelected = double(VertexSelected ~= 0);
    
    clear Temp i j tri1 tri2 tri3
    
    eval(['save ' fullfile(out_path, 'VertexS.mat') ' VertexSelected']);
else
    eval(['load ' fullfile(out_path, 'VertexS.mat')]);
end

% Step 5. Get vertex neighbours
if exist(fullfile(out_path, 'VertexNeighbours.mat'), 'file') ~= 2 || erase_flag ~= 0
    Neigh = [Surf.tri(:,1), Surf.tri(:,2)];
    Neigh = [Neigh; Surf.tri(:,1), Surf.tri(:,3)];
    Neigh = [Neigh; Surf.tri(:,2), Surf.tri(:,3)];
    Neigh = double(Neigh);
    VertexNeighbours = sparse(Neigh(:,1), Neigh(:,2), ones(size(Neigh(:,1))), nvert, nvert);
    
    clear Neigh;
    
    VertexNeighbours = double((VertexNeighbours' + VertexNeighbours)~=0);
    
    eval(['save ' fullfile(out_path, 'VertexNeighbours.mat') ' VertexNeighbours']);
else
    eval(['load ' fullfile(out_path, 'VertexNeighbours.mat')]);
end

% Step 6. Get vertex fiber density
% Di = Nvi / Svi
% Where Di  is the fiber density at vertex i
%       Nvi is the number of fibers at vertex i
%       Svi is the total area of the triangles around vertex i
if exist(fullfile(out_path, 'VertexDensity.mat'), 'file') ~= 2 || erase_flag ~= 0
    X = Surf.coord(1,:);
    Y = Surf.coord(2,:);
    Z = Surf.coord(3,:);

    X = X(Surf.tri);
    Y = Y(Surf.tri);
    Z = Z(Surf.tri);

    Xab = (X(:,2) - X(:,1));
    Xac = (X(:,3) - X(:,1));
    Yab = (Y(:,2) - Y(:,1));
    Yac = (Y(:,3) - Y(:,1));
    Zab = (Z(:,2) - Z(:,1));
    Zac = (Z(:,3) - Z(:,1));
    N = cross([Xab Yab Zab], [Xac Yac Zac]);
    A = 0.5 .* sqrt( N(:,1).*N(:,1) + N(:,2).*N(:,2) + N(:,3).*N(:,3) );
    
    % Compute triangle / vertex membership
    Vid = double([Surf.tri(:,1); Surf.tri(:,2); Surf.tri(:,3)]);
    Tid = repmat((1:ntri)', 3, 1);
    TVm = sparse(Vid, Tid, ones(size(Tid)), nvert, ntri);
    V_area = TVm * A;
    
    clear A X Y Z Xab Xac Yab Yac Zab Zac N Vid Tid TVm;
    
    % Get density
    VertexDensity = (sum(VertexSelected) ./ (sum(VertexNeighbours)-1))';
    VertexDensity = VertexDensity ./ V_area;
    
    eval(['save ' fullfile(out_path, 'VertexDensity.mat') ' VertexDensity V_area']);
else
    eval(['load ' fullfile(out_path, 'VertexDensity.mat')]);
end

% Step 7. Get distance across vertices up to 5
if exist(fullfile(out_path, 'VertDistance.mat'), 'file') ~= 2 || erase_flag ~= 0
    VertDist = distance_bin(VertexNeighbours, 5);
    
    eval(['save ' fullfile(out_path, 'VertDistance.mat') ' VertDist']);
else
    eval(['load ' fullfile(out_path, 'VertDistance.mat')]);
end

% Step 8. Smooth VertexDensity using an iterative neartest neighbours procedure
% at FWHM = 5 mm, 10 mm and 15 mm
% Note : FWHM = 2 .* sqrt(2 .* log(2)) .* SD
% For FS surfaces, SD = sqrt(2 * N / pi), for N = number of iterations
if exist(fullfile(out_path, 'VertexDensitySmooth.mat'), 'file') ~= 2 || erase_flag ~= 0
    V1  = VertDist==1;
    sV1 = sum(V1)';
    
    % N = 7  for FWHM = 5
    VertexDensityBlur5 = VertexDensity;
    for i = 1 : 7
        VertexDensityBlur5 = V1 * VertexDensityBlur5;
        VertexDensityBlur5 = VertexDensityBlur5 ./ sV1;
    end
    
    % N = 28  for FWHM = 10
    VertexDensityBlur10 = VertexDensity;
    for i = 1 : 28
        VertexDensityBlur10 = V1 * VertexDensityBlur10;
        VertexDensityBlur10 = VertexDensityBlur10 ./ sV1;
    end
    
    % N = 64 for FWHM = 15
    VertexDensityBlur15 = VertexDensity;
    for i = 1 : 64
        VertexDensityBlur15 = V1 * VertexDensityBlur15;
        VertexDensityBlur15 = VertexDensityBlur15 ./ sV1;
    end
    
    clear sV1 V1
    
    eval(['save ' fullfile(out_path, 'VertexDensitySmooth.mat') ' VertexDensityBlur5 VertexDensityBlur10 VertexDensityBlur15']);
else
    eval(['load ' fullfile(out_path, 'VertexDensitySmooth.mat')]);
end

% Step 9. Compute vertex connectivity matrix
% taking into account neighbours area
if exist(fullfile(out_path, 'VertexCMat.mat'), 'file') ~= 2 || erase_flag ~= 0
    VertexCMat = VertexSelected' * VertexSelected;
    VertexCMat(speye(nvert,nvert)~=0) = 0;
    
    [i, j, k] = find(VertexCMat);
    updiag = i < j;
    i(updiag) = [];
    j(updiag) = [];
    k(updiag) = [];
    
    VertexCMat = sparse(i, j, 2 * k ./ (V_area(i) + V_area(j)), nvert, nvert);
    VertexCMat = VertexCMat + VertexCMat';
    
    clear updiag i j k
    
    eval(['save ' fullfile(out_path, 'VertexCMat.mat') ' VertexCMat']);
else
    eval(['load ' fullfile(out_path, 'VertexCMat.mat')]);
end

% % Step 10. Blur the vertex connectivity matrix using 4 iterations
% if exist(fullfile(out_path, 'VertexCMatSmooth.mat'), 'file') ~= 2 || erase_flag ~= 0
%     V1   = VertDist==1;
%     Diag = 1./sum(V1);
%     sV1 = spdiags(Diag', 0, nvert, nvert);
%     Vn  = sV1 * V1;
%     
%     % 4 iterations
%     VertexCMatBlur = VertexCMat;
%     for i = 1 : 4
%         VertexCMatBlur = Vn * VertexCMatBlur;
%     end
%     
%     VertexCMatBlur(sV1~=0) = 0;
%     clear sV1 V1 Diag Vn
%     
%     isolated_nodes = sum(VertexCMatBlur) == 0;
%     
%     eval(['save ' fullfile(out_path, 'VertexCMatSmooth.mat') ' VertexCMatBlur isolated_nodes -v7.3']);
% else
%     eval(['load ' fullfile(out_path, 'VertexCMatSmooth.mat')]);
% end
% 
% % Step 11. Compute and save symetric blurred vertex connectivity matrix
% if exist(fullfile(out_path, 'VertexCMatSmoothSym.mat'), 'file') ~= 2 || erase_flag ~= 0
%     VertexCMatBlur = VertexCMatBlur + VertexCMatBlur';
%     VertexCMatBlur = VertexCMatBlur ./ 2;
%     
%     isolated_nodes = sum(VertexCMatBlur) == 0;
%     
%     eval(['save ' fullfile(out_path, 'VertexCMatSmoothSym.mat') ' VertexCMatBlur isolated_nodes -v7.3']);
% else
%     eval(['load ' fullfile(out_path, 'VertexCMatSmoothSym.mat')]);
% end