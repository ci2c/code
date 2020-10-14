function cluster_labels = sc_connectivity_fcm(A, num_clusters, ntrials)
% usage : function cluster_labels = sc_connectivity(A, num_clusters, [ntrials])
%SC Spectral clustering using a sparse similarity matrix (t-nearest-neighbor).
%
%   Input  : A              : N-by-N connectivity matrix
%            num_clusters   : number of clusters
%            ntrials        : number of kmeans to perform. Default : 1
%
%   Output : cluster_labels : N-by-num_clusters vector containing cluster
%              membership value

%
% Convert the sparse distance matrix to a sparse similarity matrix,
% where S = exp^(-(A^2 / 2*sigma^2)).
% Note: This step can be ignored if A is sparse similarity matrix.
%

if nargin < 3
    ntrials = 1;
end

n_init = size(A, 1);

isolated_nodes = sum(A, 2) == 0;

A(isolated_nodes, :) = [];
A(:, isolated_nodes) = [];

n = size(A, 1);

%
% Do laplacian, L = D^(-1/2) * S * D^(-1/2)
%
disp('Doing Laplacian...');
D = sum(A, 2) + (1e-10);
D = sqrt(1./D); % D^(-1/2)
D = spdiags(D, 0, n, n);
L = D * A * D;
clear D A;

%
% Do eigendecomposition, if L =
%   D^(-1/2) * S * D(-1/2)    : set 'LM' (Largest Magnitude), or
%   I - D^(-1/2) * S * D(-1/2): set 'SM' (Smallest Magnitude).
%
disp('Performing eigendecomposition...');
OPTS.disp = 0;
[V, val] = eigs(L, num_clusters, 'LM', OPTS);

%
% Do k-means
%
disp('Performing kmeans...');
% Normalize each row to be of unit length
sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
U = V ./ repmat(sq_sum, 1, num_clusters);
clear sq_sum V;
% cluster_labels_tmp = [];
% for i = 1 : ntrials
%     cluster_labels_tmp = [cluster_labels_tmp, k_means(U, [], num_clusters)];
% end

[centers, Class, obj_fcl] = fcm(U, num_clusters);

cluster_labels = zeros(n_init,ntrials);
cluster_labels(~isolated_nodes, :) = cluster_labels_tmp;

disp('Finished!');