function G = initGraphRW(Mat_in, W_list, Min_selection, Kapa, L_s)
% Usage : G = initGraphRW(MAT_IN, [WEIGHTS, MIN_SELECTION, KAPA, L_s])
%
% Create a structure containing useful and necessary informations for graph random walk wavelet
% analysis.
%
% Inputs :
%         MAT_IN         : M x M connectivity matrix
%
% Option :
%         WEIGHTS        : M x 1 vector. In case WEIGHTS are assigned to
%             the nodes. IF provided, wavelet analysis performed on
%             measurements at nodes, NOT at edges. Set WEIGHTS to [] in
%             case of connectivity graph
%         MIN_SELECTION  : Number of times a node has to be at least
%             selected (default : 100)
%         KAPA           : Smoothness parameter (default : 1)
%
% Output :
%         G           : Structure with
%
%           G.g        : Connectivity graph
%           G.Mat      : Copy of MAT_IN
%           G.W        : Copy of WEIGHTS if provided
%           G.rand_w   : Weight sequence along random walk
%           G.rand_e   : Edge (or node if WEIGHTS given) sequence of the random walk
%           G.M_select : Number of time each edge (or node if WEIGHTS given) was selected
%
% See also plotGraph3d, saveGraph, loadGraph, copyGraph
%
% Pierre Besson, Oct. 2009

if (nargin > 5) || (nargin < 1)
    error('Invalid usage');
end

if nargin < 3
    Min_selection = 100;
end

if nargin < 4
    Kapa = 1;
end
    

%% Copy Mat_in
G.Mat = Mat_in;

%% Create g
%disp('Initialize graph...')
G.g=graph;
if (nargin > 1) && (max(size(W_list)) > 0)
    set_matrix(G.g, Mat_in ~= 0);
    S = size(G.g);
    if length(W_list) == S(1)
        G.W = W_list;
    else
        error('Length of WEIGHTS should match the number of nodes');
    end
else
    G.h=graph;
    set_matrix(G.h, Mat_in ~= 0);
    line_graph(G.g, G.h);
    G.W = getWeightsList(G.h, Mat_in);
end

%% Get random walk TO ADAPT TO G
disp('Constructing random walk...');
tic;
try
    L_s;
catch
    L_s = 1;
end
[G.rand_w, G.rand_e, G.M_select] = graph_random_walk(G, Min_selection, Kapa, L_s);
toc