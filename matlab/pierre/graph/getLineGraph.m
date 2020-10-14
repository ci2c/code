function V = getLineGraph(g, M);
% Usage: V = getLineGraph(G, M);
%
% Inputs:
%      G               : graph with measurements at edges
%      M               : Connectivity matrix associated to G with continuous
%                        values
%
% Return coresponding edge graph and vector V such as V(n_edge) is the
% connectivity at edge n_edge
%
% Pierre Besson, January 2009

if nargin ~= 2
    error('Invalid usage');
end

Edges = sortrows(edges(g));
nbEdges = length(Edges);

V = zeros(nbEdges, 1);

for k = 1 : nbEdges
    V(k) = M(Edges(k, 1), Edges(k, 2));
end