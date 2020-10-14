function W = SpectralGraphWavelet(M, f, J, lambda_min, lambda_max)
% Usage : W = SpectralGraphWavelet(M, f, J, [lambda_min, lambda_max])
%
% Returns the wavelet coefficients of the SGWT
%
% Pierre Besson, 2010

if nargin ~= 3 && nargin ~= 5
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
K = 50;
x2 = 2;
if nargin < 5
    lambda_max = max(D(:));
    lambda_min = lambda_max ./ K;
end
Scales = logspace(log10(x2 ./ lambda_min), log10(x2 ./ lambda_max), J);
L = diag(D);
% Wc = zeros(size(f, 1), size(f, 2), J);
Wc = 0; % temp to save space

for k = 1 : size(f, 2)
    j = 1;
    for i = Scales
        g = WavFunction(i.*L);
        hold on, plot(L, g)
%         Wc(:, k, j) = V * (g.*F(:,k));
        j = j + 1;
    end
end

h = ScaFunction(L, max(g), lambda_min);
hold on, plot(L, h, 'r');
h = repmat(h, 1, size(f, 2));
Sc = V * (h.*F);

W.wc = Wc;
W.sc = Sc;