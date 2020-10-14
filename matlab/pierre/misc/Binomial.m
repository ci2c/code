function N = Binomial(n, k)
% Usage : N = Binomial(n, k)
%
% Computes (n)
%          (k)

if nargin ~= 2
    error('Incorrect use')
end


if k > n
    N = 0;
else
    N = factorial(n) ./ (factorial(k).*factorial(n-k));
end