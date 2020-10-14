function G = loadGraph(fname)
% Usage : G = loadGraph(fname)
%
% Load properly a graph structure
%
% Inputs :
%           fname      : path to the graph structure
%
% Output :
%           G          : Loaded graph
%
% See also initGraphRW, saveGraph
%
% Pierre Besson, Oct. 2009

if nargin ~= 1
    error('Invalid usage');
end

Graph = load(fname);
Name = char(fieldnames(Graph));

eval(['G = Graph.' Name ';']);

F = fieldnames(G);
G.g = [];
G.g = graph;
if sum(strcmp(F, 'h'))
    G.h = [];
    G.h = graph;
    set_matrix(G.h, G.Mat ~= 0);
    line_graph(G.g, G.h);
    try
        embed(G.h, G.coord_h);
    end
else
    set_matrix(g, G.Mat ~= 0);
end

try
    embed(G.g, G.coord_g);
end