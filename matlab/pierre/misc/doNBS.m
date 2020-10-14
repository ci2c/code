function [P, distrib, initial_cluster_size] = doNBS(g, initial_p, data_path, threshold, inc_tag)
% usage: [P, DISTRIB, INITIAL_CLUSTER_SIZE] = doNBS(G, INITIAL_P, DATA_PATH [, THRESHOLD, INCREASE_TAG])
%
% Returns the cluster-wise p-value and the cluster size distribution
%
% Inputs :
%   G                : Graph
%   INITIAL_P        : Vector of initial group difference p values
%   DATA_PATH        : Path to permutation matrices (may include wildcard)
%
% Option :
%   THRESHOLD        : p-value threshold used for clustering. Default : 0.0075
%   INCREASE_TAG     : Set 1 if you look for connectivity increase instead
%                      of decrease. Default : 0
%
% Outputs :
%   P                : Cluster-wise p-values
%   DISTRIB          : Distribution of permutation cluster sizes
%   INITIAL_C_SIZE   : Size of the biggest cluster of initial testing
%
% Pierre Besson @ CHRU Lille, Jan. 2012

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

if nargin == 3
    threshold = 0.0075;
end

if nargin < 5
    inc_tag = 0;
end

Matrices_path = SurfStatListDir(data_path);
N = size(Matrices_path, 1);

distrib = zeros(N, 1);
Mg = matrix(g);
Mask = tril(Mg, -1);
g2 = graph;
M2_init = zeros(size(Mg));

% Get initial cluster size
M2 = M2_init;
M2(Mask(:)) = (initial_p.C + 1) ./ (initial_p.N + 1);
M2 = M2 + M2';
if inc_tag == 0
    set_matrix(g2, double(M2 < threshold) .* double(M2 ~= 0));
else
    set_matrix(g2, double(M2 > 1-threshold) .* double(M2 ~= 0));
end
[S, E] = getComponentSize(g2);
initial_cluster_size = max(E);

% progress('init');
for i = 1 : N
    % progress(i/N, sprintf('Processing : %d / %d',i, N));
    eval(['load ', char(Matrices_path(i))]);
    try
        M2 = M2_init;
        M2(Mask(:)) = (Perm.C + 1) ./ (Perm.N + 1);
        M2 = M2 + M2';
        if inc_tag == 0
            set_matrix(g2, double(M2 < threshold) .* double(M2 ~= 0));
        else
            set_matrix(g2, double(M2 > 1-threshold) .* double(M2 ~= 0));
        end
        [S, E] = getComponentSize(g2);
        distrib(i) = max(E);
    catch
        distrib(i) = NaN;
    end
end
% progress('close');

P = (sum(distrib > initial_cluster_size) + 1) ./ (sum(~isnan(distrib)) + 1);