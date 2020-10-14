function Mat = clusters2mat(Clusters, Neighbours)
% usage : MAT = clusters2mat(CLUSTERS, [Neighbours])
% Converts clustering vector to clustering matrix
%
%   Input  : 
%      CLUSTERS      : N x K vector of clusters
%
%   Option :
%      NEIGHBOURS    : vertex-wise neighbours matrix
%
%   Output : 
%      MAT           : N x N sparse matrix of clusters. 
%           if K = 1, MAT(i,j) = 1 if i and j
%                     belong to the same cluster; MAT(i,j) = 0 otherwise.
%           if K > 1, MAT(i,j) = #(i and j are in the same cluster) / K
%
% Pierre Besson @ CHRU Lille, Dec. 2012

if nargin ~= 1 && nargin ~= 2
    error('invalid usage');
end

% Mat = zeros(length(Clusters));
N = size(Clusters, 1);
K = size(Clusters, 2);
n_class = max(Clusters(:));

if nargin == 2
    Neighbours = tril(Neighbours, -1);
    nzmax = sum(Neighbours(:));
    Mat = sparse([], [], [], N, N, nzmax);
else
    Mat = sparse(N,N);
end

for j = 1 : K
    for i = 1 : n_class
        i_index = find(Clusters(:,j) == i);
        Temp = sparse(i_index, ones(size(i_index)), ones(size(i_index)), N, 1);
        Temp = Temp * Temp';
        Temp = tril(Temp, -1);
        if nargin == 2
            Temp = Temp .* Neighbours;
        end
        Mat = Mat + Temp;
    end
end

Mat = Mat ./ K;