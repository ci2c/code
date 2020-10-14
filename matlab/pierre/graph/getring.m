function N_list = getring(g, v_in, dist_max, dist_min);
% Usage: N_LIST = getring(G, V_IN, DIST_MAX, [DIST_MIN])
%
% Inputs:
%      G               : Input graph
%      V_IN            : Input vertex to search ring neighbors
%      DIST_MAX        : Returns all neighbours K such as 
%                 dist(V_IN, K) <= DIST_MAX
% Option
%     DIST_MIN         : Returns all neighbours K such as
%                 dist(V_IN, K) <= DIST_MAX & dist(V_IN, K) > DIST_MIN
%
% Outputs:
%     N_LIST                : List of nodes included in the ring
%
% Do not input the line graph, it will be calculated within this function
%
% Pierre Besson, December 2008

if nargin ~= 4 & nargin ~=3
    error('Invalid expression');
end

Dist = dist(g, v_in);

if nargin == 4
    N_list = find(Dist > dist_min & Dist <= dist_max)';
else
    N_list = find(Dist <= dist_max)';
end