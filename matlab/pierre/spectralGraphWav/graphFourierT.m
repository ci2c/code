function F = graphFourierT(M, f)
% Usage : F = graphFourierT(M, f)
%
% Returns the graph Fourier Transform of the matrix M (expected to be an
% adjacency matrix) and the vector f (weights assigned to the nodes)
%
% If f not provided, 1 is assigned to each node
%
% Pierre Besson, 2010

if nargin ~= 1 && nargin ~= 2
    error('Invalid usage');
end

if nargin == 1
    f = ones(size(M, 1), 1);
end

% 1. Compute Laplacian
L = Laplacian(M);

% 2. Get eigenvectors
[V,D] = eig(L);

% 3. Sum
F = V' * f;