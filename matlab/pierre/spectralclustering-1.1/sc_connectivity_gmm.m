function cluster_labels = sc_connectivity_gmm(A, num_clusters, ntrials)
% usage : function cluster_labels = sc_connectivity(A, num_clusters, [ntrials])
%SC Spectral clustering using a sparse similarity matrix (t-nearest-neighbor).
%
%   Input  : A              : N-by-N connectivity matrix
%            num_clusters   : number of clusters
%            ntrials        : number of gmm to perform. Default : 1
%
%   Output : cluster_labels : N-by-1 vector containing cluster labels


%
% Convert the sparse distance matrix to a sparse similarity matrix,
% where S = exp^(-(A^2 / 2*sigma^2)).
% Note: This step can be ignored if A is sparse similarity matrix.
%

if nargin < 3
    ntrials = 1;
end

% n_init = size(A, 1);

% isolated_nodes = sum(A, 2) == 0;
% 
% A(isolated_nodes, :) = [];
% A(:, isolated_nodes) = [];

n = size(A, 1);

%
% Do laplacian, L = D^(-1/2) * S * D^(-1/2)
%
disp('Doing Laplacian...');
D = sum(A, 2) + (1e-10);
D = sqrt(1./D); % D^(-1/2)
if issparse(A)
    D = spdiags(D, 0, n, n);
else
    D = single(diag(D));
end
L = D * A;
clear A;
L = L * D;
clear D;

%
% Do eigendecomposition, if L =
%   D^(-1/2) * S * D(-1/2)    : set 'LM' (Largest Magnitude), or
%   I - D^(-1/2) * S * D(-1/2): set 'SM' (Smallest Magnitude).
%
disp('Performing eigendecomposition...');
if issparse(L)
    OPTS.disp = 0;
    [V, val] = eigs(L, num_clusters, 'LM', OPTS);
    % [V, val] = eigs(L, num_clusters+1, 'LM', OPTS); % TEST
else
    [V, val] = eig(L);
    V = V(:,1:num_clusters);
    % V = V(:,1:num_clusters+1);
end

%
% Do k-means
%
disp('Performing GMM...');
% Normalize each row to be of unit length
sq_sum = sqrt(sum(V.*V, 2)) + 1e-20;
U = V ./ repmat(sq_sum, 1, size(V,2));
clear sq_sum V;
cluster_labels_tmp = [];
centers = [];
Options.MaxIter = 1000;
reg=1e-10;
j = 1;
while j <= ntrials
    try
        gm = gmdistribution.fit(U, num_clusters, 'Replicates', 50, 'Options', Options, 'Regularize',reg);
    catch
        disp('gmdistribution.fit failed: retrying');
        reg=reg*2;
        continue;
    end
    idx = cluster(gm,U);
    cluster_labels_tmp = [cluster_labels_tmp, idx];
    j = j+1;
end

% cluster_labels = zeros(n_init,ntrials);
% cluster_labels(~isolated_nodes, :) = cluster_labels_tmp;
cluster_labels = cluster_labels_tmp;

disp('Finished!');
