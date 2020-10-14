function [Hedge, Gedge, Pre, Post] = computeEdgeMat(h)
% Usage: [Hedge, Gedge, Pre, Post] = computeEdgeMat(h)
%
% Input :  h   : refinement filter of a compactly supported orthonormal
%                wavelet family. It can be a wavelet name compatible with
%                wfilters
% Output : Hedge   : Left edge scaling filter
%          Gedge   : Left edge wavelet filter
%          Pre     : Preconditioning matrix
%          Post    : Postconditioning matrix
% 
% See also: WFILTERS

if nargin ~= 1
    error('Must specify refinement filter')
end

if nargout ~= 4
    error('Invalid expression')
end

if isstr(h)
    [fh, fg] = wfilters(h);
    h = fliplr(fh) .* sqrt(2);
end

if size(h, 1) > size(h, 2)
    h=h';
end
N = length(h) ./ 2;

% STEP 0. Define T - OK
%Meyer
% K=2*N-1;
% T=eye(K);

% % Cohen
K=N;
T = zeros(K, 2*N-1);
for k = 0 : (N-1)
    %for l = 0 : (2*N-2)
    for l = 1 - N : 2*N-2+(1-N)
        K1 = N-k-1;
        L = N-l-1;
        if L >= K1
            T(k+1, l+1-(1-N)) = Binomial(L, K1);
        end
    end
end

% STEP 1. Define H - OK
H = zeros(2*N-1, 4*N-2);

for k = 1-N : N-1
    for l = 1-N : 3*N-2
        try
            H(k+N, l+N) = h(l - 2*k + N) ./ sqrt(2);
        catch
            H(k+N, l+N) = 0;
        end
    end
end


% STEP 2. Define Lambda - OK
H1 = H(:, 1:(2*N-1));
H2 = H(:, (end - (2*N - 2)):end);
Lambda = zeros(2*N-1, 2*N-1);
H1n=eye(size(H1));

n=1;
e=1;
while e > 1E-32
    L_temp = Lambda;
    Lambda = Lambda + H1n * H2 * H2' * H1n';
    H1n = H1n * H1;
    n=n+1;
    e = max(abs(L_temp(:) - Lambda(:)));
end

Lext = [Lambda, zeros(size(Lambda)); zeros(size(Lambda)), eye(size(Lambda))];

% STEP 3. Define Lambda2
Lambda2 = T*Lambda*T';

% STEP 4. Define A - OK
A = inv(chol(Lambda2, 'lower'));

% STEP 5. Compute Hedge
Dx = K+2*N-1 - size(A, 1);
Dy = K+2*N-1 - size(A, 2);
Aext = [A, zeros(size(A, 1), Dy); zeros(Dx, size(A, 2)), eye(Dx,Dy)];

Dx = K+2*N-1 - size(T, 1);
Dy = 4*N-2 - size(T, 2);
Text = [T, zeros(size(T, 1), Dy); zeros(Dx, size(T, 2)), eye(Dx,Dy)];

I2 = eye(K + 2*N-1);
Text2 = Text\I2;

Hedge = A*T*H*Text2*inv(Aext);

% STEP 6. Compute Ghalf
C = Hedge'*Hedge;
I2 = eye(size(C));
C = I2 - C;
Ghalf = C(1:N, 1:3*N-1);

% STEP 7. Compute Ghalf & U
C2 = Ghalf(:, N+1:2:3*N-1);

[L, U, P] = lu(sparse(inv(C2)), 0.0);

% STEP 8. Inner product
Lambdaw = U*Ghalf*Ghalf'*U';

% STEP 9. Cholesky decomposition
B = inv(chol(Lambdaw, 'lower'));

% STEP 10. Define Gedge
Gedge = full(B*U*Ghalf);

% STEP. 11 Compute Pre and Post
V = T(1:N, N:(2*N-1));
Pre = inv(V*A);
Post = V*A;