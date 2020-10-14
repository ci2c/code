function L = Laplacian(M, normalization)
% Usage : L = Laplacian(M, [normalization])
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

% D = zeros(size(M));
% D(eye(size(D)) ~= 0) = sum(M);
% 
% if normalization == 0
%     L = D - M;
% else
%     L = eye(size(D)) - diag(sum(M,2).^(-1/2)) * M * diag(sum(M,2).^(-1/2));
%     L(isnan(L)) = 0;
% end

if normalization == 0
    D = diag(sum(M));
    L = D - M;
else
    D = diag(sum(M).^(-1/2));
    M = M * D;
    M = D * M;
    L = eye(size(D)) - M;
    L(isnan(L)) = 0;
end