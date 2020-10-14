function L = Laplacian_gpu(M, normalization)
% Usage : L = Laplacian_gpu(M, [normalization])
%
% Returns the continuous Laplacian of the matrix M (expected to be an
% adjacency matrix)
%
% Option :
%  normalization      : 0 if false (default)
%                       1 if true
%
%
% Pierre Besson, 2010

if nargin ~= 1 && nargin ~= 2
    error('Invalid usage');
end

if nargin == 1
    normalization = 0;
end

M = gpuArray(M);

if normalization == 0
    D = gpuArray( diag(sum(M)) );
    L = gather(D - M);
else
    D = gpuArray( diag(sum(M).^(-1/2)) );
    M = M * D;
    M = D * M;
    L = eye(size(D)) - gather(M);
%     L = eye(size(D)) - diag(sum(M,2).^(-1/2)) * M * diag(sum(M,2).^(-1/2));
    L(isnan(L)) = 0;
end
