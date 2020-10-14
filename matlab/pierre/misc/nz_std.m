function V = nz_std(M1)
% usage : M = nz_std(MAT)
%
% MAT   : N x L matrix
%
% Returns V = std(MAT, 2) only for non-zero elements

if nargin ~=1
    error('invalid usage');
end

xbar = nz_mean(M1);
x = bsxfun(@minus, M1, xbar);
x(M1==0) = 0;
x(~isfinite(x)) = 0;


V = sqrt(sum(x.^2, 2) ./ (sum(x~=0, 2) - 1));