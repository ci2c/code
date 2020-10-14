function plotGraph3d(G, vtk_name, Mat_in, Coord)
% Usage: plotGraph3d(G, VTK_NAME, [MAT, COORD])
%
% Plot 3D graph, z coordinate is the signal intensity
%
% Inputs:
%     G              : Input connectivity graph or graph structure
%     VTK_NAME       : Basename of output VTK file (No .vtk extension)
%     MAT            : 
%              * Should be a M x M Connectivity matrix is G is a connectivity matrix;
%              * Should be a N x 1 Weights vector otherwise.
%            Set MAT to [] if you don't use it.
%     COORD          : N x 2 list of 2D coordinates. If not provided,
%                       coordinates are assigned.
%
% See also initGraphRW
%
% Pierre Besson, Nov. 2009

if (nargin < 2) && (nargin > 4)
    error('Invalid usage');
end

if isstruct(G)
    try S = size(G.h);
        Connectivity_graph = 1;
    catch
        Connectivity_graph = 0;
    end
    
    if Connectivity_graph
        
        if (nargin == 2) || (isempty(Mat_in))
            W = G.W;
            Mat = G.Mat;
        end
        
        if (nargin > 2) && (~isempty(Mat_in))
            if (size(Mat_in, 1) == S(1)) && (size(Mat_in, 2) == S(1))
                Mat = Mat_in;
                W = getWeightsList(G.h, Mat);
            else
            error('Size of MAT_IN invalid. MAT_IN must be a square connectivity matrix since G is a connectivity graph');
            end
        end
        
        if (nargin < 4) 
            if ~hasxy(G.h)
                warning('G has no embedded coordinates and COORD not provided. Assigning coordinates to G, this may be time consuming !');
                mdsxy(G.h);
                Coord = getxy(G.h);
            else
                Coord = getxy(G.h);
            end
        end
        
        graph2vtk(G.h, vtk_name, Mat, Coord);
        
        line_graph(G.g,G.h);
        S = size(G.g);
      
        M_g = matrix(G.g);
        [row, col] = find(M_g ~= 0);
        index = (row - 1) .* S(1) + col;
        Mat_l = zeros(S(1));
        Mat_l(index) = (W(row) + W(col)) ./ 2;
        
        if nargin == 4
                E = sortrows(edges(G.h));
                Coord_g = (Coord(E(:,1), :) + Coord(E(:,2), :)) ./ 2;
        else
            if hasxy(G.g)
                Coord_g = getxy(G.g);
            else
                warning('G has no embedded coordinates and COORD not provided. Assigning coordinates to G, this may be time consuming !');
                mdsxy(G.g);
                Coord_g = getxy(G.g);
            end
        end

        graph2vtk(G.g, [vtk_name '_line_graph'], Mat_l, Coord_g);
        if size(Coord, 2) == 2
           graph2vtk(G.g, [vtk_name '_line_graph_3D'], Mat_l, [Coord_g W]);
        end
        
    else
        S = size(G.g);
        M_g = matrix(G.g);
        
        if nargin == 2
            W = G.W;
        else
            if (size(Mat_in, 1) == S(1)) && (size(Mat_in, 2) == 1)
                W = Mat_in;
            else
                error('Size of MAT_IN invalid');
            end
        end
        
        [row, col] = find(M_g ~= 0);
        index = (row - 1) .* S(1) + col;
        Mat = zeros(S(1));
        Mat(index) = (W(row) + W(col)) ./ 2;
        
        if nargin < 4
            warning('G has no embedded coordinates and COORD not provided. Assigning coordinates to G, this may be time consuming !');
            mdsxy(G.g);
            Coord = getxy(G.g);
        end
        
        graph2vtk(G.g, vtk_name, Mat, Coord);
        if size(Coord, 2) == 2
            graph2vtk(G.g, [vtk_name '_3D'], Mat, [Coord W]);
        end
        
    end
else
    S = size(G);
    
    if nargin == 2
        M_g = matrix(G);
        if ~hasxy(G)
            warning('G has no embedded coordinates and COORD not provided. Assigning coordinates to G, this may be time consuming !');
            mdsxy(G);
            Coord = getxy(G);
        else
            Coord = getxy(G);
        end
        graph2vtk(G, vtk_name, M_g, Coord);
    end
    
    if (nargin < 4)
        if hasxy(G)
            Coord = getxy(G);
        else
            warning('G has no embedded coordinates and COORD not provided. Assigning coordinates to G, this may be time consuming !');
            mdsxy(G);
            Coord = getxy(G);
        end
    end
    
    if nargin >= 3
        if size(Mat_in, 2) == 1

            if size(Mat_in, 1) ~= S(1)
                error('Size of MAT_IN invalid');
            end

            M_g = matrix(G);
            [row, col] = find(M_g ~= 0);
            index = (row - 1) .* S(1) + col;
            Mat = zeros(S(1));
            Mat(index) = (Mat_in(row) + Mat_in(col)) ./ 2;
            
            graph2vtk(G, vtk_name, Mat, Coord);
            if size(Coord, 2) == 2
                graph2vtk(G, [vtk_name '_3D'], Mat, [Coord Mat_in]);
            end

        else
            if (size(Mat_in, 1) ~= S(1)) && (size(Mat_in, 2)~=S(1))
                error('Size of MAT_IN invalid');
            end
            graph2vtk(G, vtk_name, Mat_in, Coord);
            
            W = getWeightsList(G, Mat_in);
            h = graph;
            line_graph(h,G);
            S = size(h);
            Coord_h = getxy(h);
            M_h = matrix(h);
            [row, col] = find(M_h ~= 0);
            index = (row - 1) .* S(1) + col;
            Mat = zeros(S(1));
            Mat(index) = (W(row) + W(col)) ./ 2;

            graph2vtk(h, [vtk_name '_line_graph'], Mat, Coord_h);
            if size(Coord, 2) == 2
                graph2vtk(h, [vtk_name '_line_graph_3D'], Mat, [Coord_h W]);
            end
            free(h);
        end
    end
end