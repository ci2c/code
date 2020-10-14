function G = initGraph(Mat_in, Degree)
% Usage : G = initGraph(MAT_IN, [DEGREE])
%
% Create a structure containing useful and necessary informations for graph wavelet
% analysis.
%
% Inputs :
%         MAT_IN      : Input M x M connectivity matrix 
%         DEGREE      : Mean node degree for backbone extraction of the
%               graph from MAT_IN. Default : 4.
%                       If degree < 0, no edge selection performed
%
% Output :
%         G           : Structure with
%
%           G.g        : Connectivity graph
%           G.T_M      : Average transformation matrix
%           G.w        : Weights assigned to each connection
%           G.Mat      : Copy of Mat_in
%           G.L_max    : Maximum shortest distance between any pair of nodes
%           G.L_min    : Minimum of all longest distances
%
% Pierre Besson, Oct. 2009

if (nargin > 2) || (nargin < 1)
    error('Invalid usage');
end

if nargin ~= 2
    Degree = 4;
end

%% Copy Mat_in
G.Mat = Mat_in;

%% Create g and h
disp('Initialize graph...')
G.g=graph;
if Degree > 0
    disp('Extracting backbone matrix');
    M_backbone = ExtractBackBone(G.Mat, Degree);
else
    M_backbone = Mat_in;
end
set_matrix(G.g, M_backbone ~= 0);

%% Set weights list
G.w = getWeightsList(G.g, G.Mat);

%% Get T_M, L_max and L_min
[G.T_M G.L_max G.L_min] = getGraphAverageMat(G.g);