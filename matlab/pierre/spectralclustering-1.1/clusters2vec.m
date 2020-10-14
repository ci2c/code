function Mat = clusters2vec(Clusters)
% usage : V = clusters2vec(CLUSTERS)
% Converts clustering ID vectors to binary clustering vectors
%
%   Input  : 
%      CLUSTERS      : N x K vector of C clusters
%
%   Output : 
%      V             : N x (K*C) sparse matrix of binary vectors.
%          ex. : V(230, 2) = 1 if the 230-th vertex belongs to the 2-nd
%                              cluster
%
% Pierre Besson @ CHRU Lille, Apr. 2013

if nargin ~= 1
    error('invalid usage');
end

N = size(Clusters, 1);
K = size(Clusters, 2);
n_class = max(Clusters(:));
Mat = [];

% for j = 1 : K
%     for i = 1 : n_class
%         i_index = find(Clusters(:,j) == i);
%         Temp = sparse(i_index, ones(size(i_index)), ones(size(i_index)), N, 1);
%         Mat = cat(2, Mat, Temp);
%     end
% end

for j = 1 : K
    [i_index, j_index, k_index] = find(Clusters(:,j));
    for ii = 1 : n_class
        Index = k_index == ii;
        SIndex = sum(Index);
        Temp = sparse(i_index(Index), ones(SIndex, 1), ones(SIndex, 1), N, 1);
        Mat = cat(2, Mat, Temp);
    end
end