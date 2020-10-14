function PlotFilters(ftype)
% Usage : PlotFilters(ftype)
%  Computes Hedge & Gedge of wavelet type ftype

if nargin ~= 1
    error('Incorrect use')
end

%%%
[phi, psi, xval] = wavefun(ftype, 10);
N = (xval(end) - xval(1) + 1) ./ 2;
xval = xval - N ./ 2;
phihalf = phi;
phihalf(xval < 0) = [];
Ninter = (length(xval) - 1) ./ (2 .* N);

% Define A & T
T = zeros(N, 2*N-1);
for k = 0 : (N-1)
    for l = 1 - N : 2*N-2+(1-N)
        K1 = N-k-1;
        L = N-l-1;
        if L >= K1
            T(k+1, l+1-(1-N)) = Binomial(L, K1);
        end
    end
end
[LO_D, HI_D] = WFILTERS(ftype);
h = flipdim(LO_D, 2) .* sqrt(2);
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
H1 = H(:, 1:(2*N-1));
H2 = H(:, (end - (2*N - 2)):end);
Lambda = zeros(2*N-1, 2*N-1);
H1n=eye(size(H1));
for n = 1 : 100000
    Lambda = Lambda + H1n * H2 * H2' * H1n';
    H1n = H1n * H1;
end
Lext = [Lambda, zeros(size(Lambda)); zeros(size(Lambda)), eye(size(Lambda))];
Lambda2 = T*Lambda*T';
A = inv(chol(Lambda2, 'lower'));

D = A*T;

Hleft = [];

for k = 1 : N
    hleft = zeros(1, (size(D, 2)+1) .* length(phihalf));
    %gleft = zeros(size(Hleft));
    for l = 1 : size(D, 2)
        Phi_l = [zeros(1, l-1), phihalf];
        Phi_l = [Phi_l, zeros(1, length(hleft) - length(Phi_l))];
        hleft = hleft + Phi_l .* D(k, l);
        %gleft 
    end
    Hleft = setfield(Hleft, ['k' int2str(k)], hleft);
    %Gleft = setfield(Gleft, ['k' int2str(k)], gleft);
end

%%%
disp('OK ?!');