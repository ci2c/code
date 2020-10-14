function EV = getEigenVectors(M, n_eig)
% usage : EV = getEigenVectors(M, n_eig)
% Inputs :
%   M     : input connectivity matrix
%   n_eig : number of eigenvectors desired
% Ouput  :
%   EV    : eigenvectors

if nargin ~= 2
    error('invalid usage');
end

n = size(M, 1);
D = sum(M, 2) + (1e-10);
D = sqrt(1./D);
D = spdiags(D, 0, n, n);
L = D * M;
clear M;
L = L * D;
clear D;

OPTS.disp = 0;
[EV, val] = eigs(L, n_eig, 'LM', OPTS);