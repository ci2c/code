function W = getWeightsList(g, Mat_in)
% Usage : W = getWeightsList(G, MAT_IN)
%
% Returns weight assigned to each edge as a 1 X E vector
%
% Inputs :
%           G          : Input connectivity graph
%           MAT_IN     : Connectivity matrix
%
% Output :
%           W          : Weights list
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Invalid usage');
end

M = size(Mat_in, 1);
Edges = sortrows(edges(g));
Edges = Edges(:, 1) + M * (Edges(:,2) - 1);
W = Mat_in(Edges);