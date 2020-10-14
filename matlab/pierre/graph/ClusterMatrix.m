function ClusterMatrix(matrix_path, n_cluster, n_rep, out_path,  erase_flag)
% usage: ClusterMatrix(matrix_path, n_cluster, n_rep, out_path, [erase_flag])
%
% Cluster vertex-wise connectivity matrix in N_CLUSTER clusters using N_REP
% repetitions
% 
%  Inputs :
%     matrix_path    : path to the directory containing the outputs of
%                        PrepareMatrix
%
%     n_cluster      : number of desired clusters
%
%     n_rep          : number of desired repetition
%
%     out_path       : path to the output directory
%
%  Option :
%     erase_flag     : set 1 if output matrices are to be overwritten.
%                        Default : 0
%
% What is performed :
%    1. Load data (VertexCMatSmooth.mat)
%    2. Cluster the data using spetral decomposition and k-means clustering
%    algorithm
%    3. Save the final clusters in a vector fashion using clusters2vec
%     --> clusters_N_CLUSTER_N_REP
%
% See also PrepareMatrix, clusters2vec
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin == 4
    erase_flag = 0;
end

if exist(out_path, 'dir') ~= 7
    mkdir(out_path);
end

if exist(fullfile(out_path, ['clusters_', num2str(n_cluster), '_', num2str(n_rep), '.mat']), 'file') ~= 2 || erase_flag ~= 0
    % Compute Laplacian matrix
    if exist(fullfile(out_path, 'laplacian.mat'), 'file') ~= 2
        disp('Compute Laplacian');
        eval(['load ' fullfile(matrix_path, 'VertexCMatSmoothSym.mat')]);
        VertexCMatBlur(isolated_nodes, :) = [];
        VertexCMatBlur(:, isolated_nodes) = [];
        n = size(VertexCMatBlur, 1);
        D = sum(VertexCMatBlur, 2) + (1e-10);
        D = sqrt(1./D); % D^(-1/2)
        D = spdiags(D, 0, n, n);
        L = D * VertexCMatBlur;
        clear VertexCMatBlur;
        L = L * D;
        clear D;
        eval(['save ', fullfile(out_path, 'laplacian.mat L -v7.3')]);
    else
        disp('Load Laplacian');
        eval(['load ', fullfile(out_path, 'laplacian.mat')]);
    end
    
    % Extracts first 100 eigenvectors
    if exist(fullfile(out_path, 'eigs.mat'), 'file') ~= 2
        disp('Compute eigenvectors');
        OPTS.disp = 0;
        [V, val] = eigs(L, 100, 'LM', OPTS);
        clear L val;
        eval(['save ', fullfile(out_path, 'eigs.mat V -v7.3')]);
    else
        disp('Load eigenvectors');
        clear L;
        eval(['load ', fullfile(out_path, 'eigs.mat')]);
    end
    
    % Perform k-means
    V = V(:, 1:n_cluster);
    sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
    U = V ./ repmat(sq_sum, 1, n_cluster);
    clear sq_sum V;
    cluster_labels = [];
    for i = 1 : n_rep
        cluster_labels = [cluster_labels, k_means(U, [], n_cluster)];
    end
    cluster_mat = clusters2vec(cluster_labels);
    eval(['save ', fullfile(out_path, ['clusters_', num2str(n_cluster), '_', num2str(n_rep), '.mat cluster_labels cluster_mat -v7.3'])]);
else
    % eval(['load ', fullfile(out_path, ['clusters_', num2str(n_cluster), '_', num2str(n_rep), '.mat'])]);
    disp('step done.');
end
