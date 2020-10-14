function [S, E] = getComponentSize(g)
% usage: [S, E] = getComponentSize(G)
%
% Return the components size of the graph G
%
% Input:
%   G                : Graph
%
% Output :
%   S                : Vector of the sizes of nodes
%   E                : Vector of the sizes of edges
%
% Pierre Besson @ CHRU Lille, Dec. 2011

if nargin ~= 1
    error('invalid usage');
end

% M = matrix(g);
% n = nv(g);
% indicator = zeros(n,1);
% c = 0;
% 
% while (nnz(indicator)<n)
%     c = c+1;
%     % find first zero entry in indicator
%     i = find(indicator==0);
%     i = i(1);
%     
%     % get i's component
%     ci = component(g,i);
%     
%     indicator(ci) = c;
% end
% 
% u = unique(indicator);
% S = zeros(size(u));
% E = S;
% 
% for i = 1 : length(u)
%     S(i) = sum(indicator==u(i));
%     M2 = M;
%     M2(indicator~=u(i), :) = [];
%     M2(:, indicator~=u(i)) = [];
%     E(i) = sum(M2(:)~=0) / 2;
% end

M = matrix(g);
M = sparse(M);
[S, C] = graphconncomp(M, 'Directed', false);
T = tabulate(C);
S = T(:,2);

u = T(:,1);
E = zeros(size(u));

for i = 1 : length(u)
    M2 = M;
    M2(C~=u(i), :) = [];
    M2(:, C~=u(i)) = [];
    E(i) = sum(M2(:)~=0) / 2;
end