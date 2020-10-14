function saveGraph(G, fname)
% Usage : saveGraph(G, fname)
%
% Save properly a graph structure
%
% Inputs :
%           G          : input graph structure
%           fname      : root name of the output (without .m or any other
%                         extension)
%
% See also initGraphRW, loadGraph
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Invalid usage');
end

if hasxy(G.g)
    G.coord_g = getxy(G.g);
end

try size(G.h);
    if hasxy(G.h)
        G.coord_h = getxy(G.h);
    end
end

% Save the structure
eval( ['save ' fname ' G'] );