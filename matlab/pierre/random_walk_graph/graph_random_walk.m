function [Rand_walk, Rand_nodes, M_select] = graph_random_walk(G, Min_selection, Kapa, L_s)
% Usage: [Rand_walk, Rand_nodes, M_select] = graph_random_walk(G, MIN_SELECTION, KAPA, L_s)
%
% Inputs:
%     G                : Input graph structure 
%     MIN_SELECTION    : Minimal edge selection (usually > 5)
%     KAPA             : Smoothness parameter (usually 1)
%
% Output:
%     Rand_walk        : 1D sequence of the measurements along the walk
%     Rand_nodes       : Sequence of the nodes the walk went though
%     M_select         : Number of times each node was selected
%
% See also: initGraphRW, loadGraphRW, plotGraph3d
%
% Pierre Besson, Nov. 2009

if nargin ~= 4
    error('Invalid usage');
end

% Preallocating
Rand_walk = zeros(2^19, 1);
Rand_nodes = zeros(2^19, 1);
V = size(G.g);
V = V(1);
POW2 = 2.^(1:40);

% Initialization
W = G.W;
M_select = zeros(V, 1);
V0 = randint(1,1,[1 V]);
V00 = V0;

% Loop
i=1;
while 1
    L = G.g(V0);
    try
        Prob = exp(-Kapa .* (M_select(L) - max(M_select(L))));
        N = randsample(L, 1, true, Prob);
    catch
        V00 = V0;
        V0 = L;
        continue;
    end
    % if (N ~= V00)
    I_min = max(i-L_s, 1);
    if (sum(Rand_nodes(I_min:i-1)==N) == 0)
        Rand_walk(i) = W(N);
        Rand_nodes(i) = N;
        M_select(N) = M_select(N) + 1;
        if ((sum(POW2 == i)) && (min(M_select) >= Min_selection))
            break;
        end
        i = i+1;
        V00 = V0;
        V0 = N;
    else
        V00 = V0;
        V0 = N;
    end
end
Rand_walk = Rand_walk(1:i);
Rand_nodes = Rand_nodes(1:i);