function Mat = Weights2Mat(g, W)
% Usage : MAT = Weights2Mat(G, W)
%
% Returns MAT filled with the weights vector W
%
% Inputs :
%           G          : Input connectivity graph
%           W          : Weights list
%
% Output :
%           MAT        : Connectivity matrix filled with Ws
%
% Pierre Besson, Oct. 2009

if nargin ~= 2
    error('Invalid usage');
end

Edges = sortrows(edges(g));
M = size(g);
M = M(1);
Mat = zeros(M,M);
Edges = Edges(:, 1) + M * (Edges(:,2) - 1);
Mat(Edges) = W;
Mat = Mat + Mat';