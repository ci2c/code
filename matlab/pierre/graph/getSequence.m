function S = getSequence(h, V, v_in);
% Usage: S = getSequence(H, V, v_in)
%
% Inputs:
%      H               : Input graph with measurements at nodes (edge
%                        matrix)
%      V               : Connectivity at edges : V(edge_n) = connectivity at
%      edge n
%      v_in            : Input edge to search ring neighbors
%
% Return mean connectivity about V_IN as a function of distance
%
% Pierre Besson, January 2009

if nargin ~= 3
    error('Invalid usage')
end

Dist = dist(h, v_in);
Dist(Dist==inf) = -1;

S = [];

for k = 0 : max(Dist)
    List = find(Dist == k)';
    S = [S, mean(V(List))];
end