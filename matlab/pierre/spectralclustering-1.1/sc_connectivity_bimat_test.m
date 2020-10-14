function [cluster_labels, objective_value] = sc_connectivity_bimat_test(A, B, num_clusters, ratio, ntrials, ev_flag)
% usage : [cluster_labels, objective_value] = sc_connectivity_bimat_test(A, B, num_clusters, [ratio, ntrials, ev_flag])
%SC Spectral clustering using a sparse similarity matrix (t-nearest-neighbor).
%
%   Input  : A               : N-by-N connectivity matrix
%                              or N-by-V eigenvector matrix
%            B               : N-by-N neighbour matrix
%                              or N-by-V eigenvector matrix
%            num_clusters    : number of clusters
%            ratio           : M-by-1 vector of ratios of B injected in A. Default : 0.5
%                              M-by-2 matrix. The first coloumn indicates
%                              the number of eigenvectors of A to include,
%                              the second column the number of egeinvectors
%                              of B ton include. The sum of the two columns
%                              must be equal to num_clusters
%            ntrials         : number of kmeans to perform. Default : 1
%            ev_flag         : set to false if A and B are connectivity
%                                matrices
%                              set to true if A and B are eigenvector
%                              matrices or if size(A, 1) ~= size(A, 2)
%                              default : false
%
%   Output : cluster_labels  : N-by-ntrials-by-M table containing cluster labels
%            objective_value : ntrials-by-M table containing final kmean
%                               objective value

%
% Convert the sparse distance matrix to a sparse similarity matrix,
% where S = exp^(-(A^2 / 2*sigma^2)).
% Note: This step can be ignored if A is sparse similarity matrix.
%

if nargin < 6
    ev_flag = false;
end

if (size(A, 2) ~= size(A, 1)) || (size(B,2) ~= size(B,1))
    ev_flag = true;
end

if nargin < 5
    ntrials = 1;
end

if nargin < 4
    ratio = 0.5;
end

if size(ratio, 2) == 1
    if (min(ratio) < 0) || (max(ratio) > 1)
        error('invalid ratio. Must be between 0 and 1');
    end
else
    if (min(ratio(:)) < 0) || (max(ratio(:)) > num_clusters)
        error('invalid ratio. Must be between 0 and num_clusters');
    end
end

n_ratio = size(ratio, 1);

if size(ratio, 2) == 1
    ratio_max = max(ratio);
    ratio_min = min(ratio);

    num_vec_A_max = round((1-ratio_min) .* num_clusters);
    Temp = round((1-ratio_max) .* num_clusters);
    num_vec_B_max = num_clusters - Temp;
else
    check_ratio = sum(ratio, 2);
    if sum(check_ratio ~= num_clusters) ~= 0
        error('The sum of every lines of ratio must be equal to num_clusters');
    end
    num_vec_A_max = max(ratio(:,1));
    num_vec_B_max = max(ratio(:,2));
end

n_init = size(A, 1);

if ~istrue(ev_flag)
    isolated_nodes = sum(A, 2) == 0;

    A(isolated_nodes, :) = [];
    A(:, isolated_nodes) = [];

    B(isolated_nodes, :) = [];
    B(:, isolated_nodes) = [];
end

n = size(A, 1);

if ~istrue(ev_flag)
    %
    % Do laplacian, L = D^(-1/2) * S * D^(-1/2)
    %
    disp('Doing Laplacian...');
    D = sum(A, 2) + (1e-10);
    D = sqrt(1./D); % D^(-1/2)
    D = spdiags(D, 0, n, n);
    L = D * A * D;
    Db = sum(B, 2) + (1e-10);
    Db = sqrt(1./Db); % D^(-1/2)
    Db = spdiags(Db, 0, n, n);
    Lb = Db * B * Db;
    clear D A Db B;

    %
    % Do eigendecomposition, if L =
    %   D^(-1/2) * S * D(-1/2)    : set 'LM' (Largest Magnitude), or
    %   I - D^(-1/2) * S * D(-1/2): set 'SM' (Smallest Magnitude).
    %
    disp('Performing eigendecomposition...');
    OPTS.disp = 0;
    [V, val] = eigs(L, num_vec_A_max, 'LM', OPTS);
    [Vb, valb] = eigs(Lb, num_vec_B_max, 'LM', OPTS);
else
    V = A;
    Vb = B;
end

%
% Do k-means
%
cluster_labels_tmp = zeros(n, ntrials, n_ratio);
objective_value = zeros(ntrials, n_ratio);
% disp('Performing kmeans...');
% Normalize each row to be of unit length
% sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
% sq_sumb = sqrt(sum(Vb.*Vb, 2)) + 1e-20;
% Ua = V ./ repmat(sq_sum, 1, num_vec_A_max);
% Ub = Vb ./ repmat(sq_sumb, 1, num_vec_B_max);
% clear sq_sum V sq_sumb Vb;

for j = 1 : n_ratio
    if size(ratio, 2) == 1
        num_vec_A = round((1-ratio(j)) .* num_clusters);
        num_vec_B = num_clusters - num_vec_A;
    else
        num_vec_A = ratio(j, 1);
        num_vec_B = ratio(j, 2);
    end
    % Normalization
    VV = [V(:, 1:num_vec_A), Vb(:, 1:num_vec_B)];
    sq_sum = sqrt(sum(VV .* VV, 2)) + 1e-20;
    U = VV ./ repmat(sq_sum, 1, num_vec_A+num_vec_B);
    
    for i = 1 : ntrials
        [cluster_labels_tmp(:, i, j), objective_value(i,j)] = k_means(U, [], num_clusters);
    end
end

if ~istrue(ev_flag)
    cluster_labels = zeros(n_init,ntrials,n_ratio);
    cluster_labels(~isolated_nodes, :, :) = cluster_labels_tmp;
else
    cluster_labels = cluster_labels_tmp;
end

% disp('Finished!');
