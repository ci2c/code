function V = nz_mean(M1)
% usage : M = nz_mean(MAT)
%
% MAT   : N x L matrix
%
% Returns V = mean(MAT, 2) only for non-zero elements

V = sum(M1, 2) ./ sum(M1~=0, 2);
V(~isfinite(V)) = 0;