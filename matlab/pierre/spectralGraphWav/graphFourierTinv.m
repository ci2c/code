function f = graphFourierTinv(M, F)
% Usage : f = graphFourierTinv(M, F)
%
% Returns the inverse graph Fourier Transform of the matrix M (expected to be an
% adjacency matrix) and the vector F (weights assigned to the nodes)
%
%
% Pierre Besson, 2010

if nargin ~= 2
    error('Invalid usage');
end

% 1. Compute Laplacian
L = Laplacian(M);

% 2. Get eigenvectors
[V,D] = eig(L);

% 3. Inverse transform
f = V * F;