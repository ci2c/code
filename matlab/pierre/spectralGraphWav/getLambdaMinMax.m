function [lambda_min, lambda_max] = getLambdaMinMax(M, f)
% Usage : [lambda_min, lambda_max] = getLambdaMinMax(M, f)
%
% Returns the scale boundaries
%
% Pierre Besson @ CHRU Lille, July 2011

if nargin ~= 2
    error('Invalid usage');
end

% 1. Compute Laplacian
L = Laplacian(M);

% 2. Get eigenvectors
[V,D] = eig(L);

% 3. Fourier Transform
F = V' * f;

% 4. Filtering
% Computes scale boundaries
K = 5;
lambda_max = max(D(:));
lambda_min = lambda_max ./ K;