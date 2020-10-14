function graph2vtk(g, vtk_filename, M, coord_nodes)
% usage: graph2vtk(G, VTK_FILENAME, [M, coord_nodes])
%
% Print graph G in vtk format
%
% Inputs:
%   G                : Graph (N nodes)
%   VTK_FILENAME     : Name of the output
%    Note that the filename must not end with .vtk since 2 files are
%    actually generated: VTK_FILENAME_nodes.vtk and VTK_FILENAME_edges.vtk
%
% Options:
%   M                : NxN connectivity matrix for coloring lines
%   COORD_NODES      : N x 2 or N x 3 matrix of the node coordinates
%
% Pierre Besson, 23 Dec 2008

if nargin < 2 | nargin > 4
    error('Invalid expression');
end

Size = size(g);
Nodes = Size(1);
Nedges = Size(2);

if hasxy(g) == 0 & nargin < 4
    error('Coordinates information missing: hasxy(g) must be 1 or coord_nodes must be passed');
end

if nargin < 4
    coord_nodes = getxy(g);
    coord_nodes = [coord_nodes, zeros(size(coord_nodes, 1), 1)];
else
    if size(coord_nodes, 2) == 2
        coord_nodes = [coord_nodes, zeros(size(coord_nodes, 1), 1)];
    end
end

if nargin < 3
    M = ones(Nodes, Nodes);
end

% Print Nodes
File = fopen(strcat(vtk_filename, '_nodes.vtk'), 'w');
fprintf(File, '# vtk DataFile Version 3.0\n');
fprintf(File, 'graph2vtk_nodes\n');
fprintf(File, 'ASCII\n');
fprintf(File, 'DATASET POLYDATA\n');
fprintf(File, 'POINTS %d float\n', Nodes);
fprintf(File, '%f %f %f\n', coord_nodes');
fprintf(File, 'VERTICES %d %d\n', Nodes, 2.*Nodes);
VERTICES=[ones(Nodes, 1), (0:(Nodes-1))'];
fprintf(File, '%d %d\n', VERTICES');
fclose(File);

% Print edges
Nline = 1; % Edges are ploted using Nline + 1 points
File = fopen(strcat(vtk_filename, '_edges.vtk'), 'w');
fprintf(File, '# vtk DataFile Version 3.0\n');
fprintf(File, 'graph2vtk_edges\n');
fprintf(File, 'ASCII\n');
fprintf(File, 'DATASET POLYDATA\n');
Edges = edges(g);
k = linspace(0, 1, Nline+1);
LK = length(k);
fprintf(File, 'POINTS %d float \n', Nedges .* LK);
for i = 1 : size(Edges, 1)
    Point1 = coord_nodes(Edges(i, 1), :);
    Point2 = coord_nodes(Edges(i, 2), :);
    X = linspace(Point1(1, 1), Point2(1, 1), Nline+1);
    Y = linspace(Point1(1, 2), Point2(1, 2), Nline+1);
    Z = linspace(Point1(1, 3), Point2(1, 3), Nline+1);
    XYZ=[X' Y' Z'];
    fprintf(File, '%f %f %f\n', XYZ');
end
fprintf(File, 'LINES %d %d\n', Nedges, (LK+1) .* Nedges);
for i = 1 : Nedges .* LK
    if mod(i-1, LK) == 0
        fprintf(File, '%d ', LK);
    end
    fprintf(File, '%d ', i-1);
    if mod(i, LK) == 0
        fprintf(File, '\n');
    end
end

fprintf(File, 'POINT_DATA %d\n', Nedges .* LK);
fprintf(File, 'SCALARS connectivity float\n');
fprintf(File, 'LOOKUP_TABLE default\n');
j = 1;
for i = 1 : Nedges .* LK
    fprintf(File, '%f\n', full(M(Edges(j, 1), Edges(j, 2))));
    if mod(i, LK) == 0
        j = j+1;
    end
end
fclose(File);
