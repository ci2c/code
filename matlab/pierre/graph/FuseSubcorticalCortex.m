function FuseSubcorticalCortex(subcort_matrix_dir, cort_matrix_dir, out_path, erase_flag)
% usage: FuseSubcorticalCortex(subcort_matrix_dir, cort_matrix_dir, out_path, [erase_flag])
%
% Create connectivity matrices based on the fusion between a subcortical
% structure and the whole cortex
% 
%  Inputs :
%     subcort_matrix_dir : output directory of the PrepareMatrix function
%                        for the subcortical structure
%
%     cort_matrix_dir    : output directory of the PrepareMatrix function
%                        for the cortex
%
%     out_path           : output directory to store output matrices
%
%  Option :
%     erase_flag         : set 1 if output matrices are to be overwritten.
%                        Default : 0
%
% What is performed :
% Steps performed are similar to PrepareMatrix except that only
% subcortico-subcortical and subcortico-cortical connections are included. 
% Therefore, cortico-cortical connections are discarded.
%
% See also PrepareMatrix, getFastTriangleConnectMat
%
% Pierre Besson @ CHRU Lille, May 2013

if nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

if nargin == 3
    erase_flag = 0;
end

if exist(out_path, 'dir') ~= 7
    mkdir(out_path);
end

% Load surfaces to define some parameters
if exist(fullfile(out_path, 'surface.obj'), 'file') ~= 2 || erase_flag ~= 0
    subcort_surf = cellstr(fullfile(subcort_matrix_dir, 'surface.obj'));
    cort_surf    = cellstr(fullfile(cort_matrix_dir, 'surface.obj'));
    SubCortSurf = SurfStatReadSurf(subcort_surf);
    CortSurf = SurfStatReadSurf(cort_surf);
    Surf = SurfStatReadSurf([subcort_surf, cort_surf]);
    SurfStatWriteSurf(fullfile(out_path, 'surface.obj'), Surf);
else
    Surf = SurfStatReadSurf(fullfile(out_path, 'surface.obj'));
end

% Load triangle selection matrices
if exist(fullfile(out_path, 'TriS.mat'), 'file') ~= 2 || erase_flag ~= 0
    load(fullfile(subcort_matrix_dir, 'TriS.mat'));
    SubCortSel = TriS;
    [n_fiber, n_subcort] = size(SubCortSel);

    load(fullfile(cort_matrix_dir, 'TriS.mat'));
    CortSel = TriS;
    n_cort = size(CortSel, 2);

    ntri = n_subcort + n_cort;
    nvert = length(Surf.coord);

    % Concatenate the selection matrices with the subcortical structure on the left
    Selected = cat(2, SubCortSel, CortSel);
    save(fullfile(out_path, 'TriS.mat'), 'Selected', 'ntri', 'nvert', 'n_subcort', 'n_cort', 'n_fiber');
    clear SubCortSel CortSel TriS;
else
    load(fullfile(out_path, 'TriS.mat'));
end

% Compute triangle connectivity matrix taking into account triangle area
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
    
    TriCMat = double(Selected~=0);
    TriCMat = TriCMat' * TriCMat;
    TriCMat(speye(size(TriCMat)) ~= 0) = 0;
    
    [index_i, index_j, index_k] = find(TriCMat);
    TriCMat = sparse(index_i, index_j, 2 * index_k ./ (A(index_i) + A(index_j)), ntri, ntri);
    
    clear index_i index_j index_k X Y Z Xab Xac Yab Yac Zab Zac N A;
    
    eval(['save ' fullfile(out_path, 'TriCMat.mat') ' TriCMat']);
else
    eval(['load ' fullfile(out_path, 'TriCMat.mat')]);
end

% Get triangle neighbours
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

% Blur the triangle connectivity matrix using 4 iterations
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


% % Load vertex-wise selection matrices
% if exist(fullfile(out_path, 'VertexS.mat'), 'file') ~= 2 || erase_flag ~= 0
%     load(fullfile(subcort_matrix_dir, 'VertexS.mat'));
%     SubCortSel = VertexSelected;
%     [n_fiber, n_subcort] = size(SubCortSel);
% 
%     load(fullfile(cort_matrix_dir, 'VertexS.mat'));
%     CortSel = VertexSelected;
%     n_cort = size(CortSel, 2);
% 
%     nvert = n_subcort + n_cort;
% 
%     % Concatenate the selection matrices with the subcortical structure on the left
%     Selected = cat(2, SubCortSel, CortSel);
%     save(fullfile(out_path, 'VertexS.mat'), 'Selected', 'nvert', 'n_subcort', 'n_cort', 'n_fiber');
%     clear SubCortSel CortSel VertexSelected;
% else
%     load(fullfile(out_path, 'VertexS.mat'));
% end
% 
% % Compute vertex-wise connectivity matrix taking into account neighbourhood
% % area
% if exist(fullfile(out_path, 'VertexCMat.mat'), 'file') ~= 2 || erase_flag ~= 0
%     load(fullfile(subcort_matrix_dir, 'VertexDensity.mat'));
%     subcort_area = V_area;
%     load(fullfile(cort_matrix_dir, 'VertexDensity.mat'));
%     cort_area = V_area;
%     V_area = [subcort_area; cort_area];
%     VertexCMat = Selected' * Selected;
%     VertexCMat(speye(size(VertexCMat)) ~= 0) = 0;
% 
%     [i, j, k] = find(VertexCMat);
%     updiag = i < j;
%     i(updiag) = [];
%     j(updiag) = [];
%     k(updiag) = [];
% 
%     VertexCMat = sparse(i, j, 2 * k ./ (V_area(i) + V_area(j)), nvert, nvert);
%     VertexCMat = VertexCMat + VertexCMat';
% 
%     clear updiag i j k;
%     save(fullfile(out_path, 'VertexCMat.mat'), 'VertexCMat');
% else
%     load(fullfile(out_path, 'VertexCMat.mat'));
% end
% 
% % Get vertex neighbours
% if exist(fullfile(out_path, 'VertexNeighbours.mat'), 'file') ~= 2 || erase_flag ~= 0
%     Neigh = [Surf.tri(:,1), Surf.tri(:,2)];
%     Neigh = [Neigh; Surf.tri(:,1), Surf.tri(:,3)];
%     Neigh = [Neigh; Surf.tri(:,2), Surf.tri(:,3)];
%     Neigh = double(Neigh);
%     VertexNeighbours = sparse(Neigh(:,1), Neigh(:,2), ones(size(Neigh(:,1))), nvert, nvert);
%     
%     clear Neigh;
%     
%     VertexNeighbours = double((VertexNeighbours' + VertexNeighbours)~=0);
%     
%     save(fullfile(out_path, 'VertexNeighbours.mat'), 'VertexNeighbours');
% else
%     load(fullfile(out_path, 'VertexNeighbours.mat'));
% end
% 
% % Blur the vertex connectivity matrix using 4 iterations and remove
% % cortico-cortical connections
% if exist(fullfile(out_path, 'VertexCMatSmooth.mat'), 'file') ~= 2 || erase_flag ~= 0
%     V1   = VertexNeighbours + double(speye(size(VertexNeighbours)) ~= 0);
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
%     % Clear cortico-cortical connections
%     VertexCMatBlur(n_subcort+1:end, n_subcort+1:end) = 0;
%     
%     isolated_nodes = sum(VertexCMatBlur) == 0;
%     save(fullfile(out_path, 'VertexCMatSmooth.mat'), 'VertexCMatBlur', 'isolated_nodes', '-v7.3');
% else
%     load(fullfile(out_path, 'VertexCMatSmooth.mat'));
% end
% 
% % Compute and save symmetric blurred vertex connectivity matrix
% if exist(fullfile(out_path, 'VertexCMatSmoothSym.mat'), 'file') ~= 2 || erase_flag ~= 0
%     VertexCMatBlur = VertexCMatBlur + VertexCMatBlur';
%     VertexCMatBlur = VertexCMatBlur ./ 2;
%     
%     isolated_nodes = sum(VertexCMatBlur) == 0;
%     
%     save(fullfile(out_path, 'VertexCMatSmoothSym.mat'),  'VertexCMatBlur', 'isolated_nodes', '-v7.3');
% else
%     load(fullfile(out_path, 'VertexCMatSmoothSym.mat'));
% end