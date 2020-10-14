function g = WavFunction(x, Lambda, Alpha, Beta, x1, x2)
% Usage : g = WavFunction(x, Lambda, Alpha, Beta, x1, x2)
%
% Returns spectral graph wavelets function
%
% Default :
%        - Lambda = 1
%        -  Alpha = 1
%        -   Beta = 1
%        -     x1 = 1
%        -     x2 = 2
%
% Pierre Besson, 2010

if nargin ~= 1 && nargin ~=2 && nargin ~=6
    error('Invalid usage');
end

if nargin == 1
    Lambda = 1;
end

if nargin <= 2
    Alpha = 1;
    Beta = 1;
    x1 = 1;
    x2 = 2;
end

A = [x1.^3 x1.^2 x1 1;...
     x2.^3 x2.^2 x2 1;...
     3*x1.^2 2*x1 1 0;...
     3*x2.^2 2*x2 1 0];
 
B = [1;1;Alpha./x1;-Beta./x2];

X = linsolve(A,B);

g = zeros(size(x));

Lx = Lambda .* x;

g(find(Lx<x1)) = x1.^(-Alpha) .* Lx(find(Lx<x1)).^Alpha;
g(find((Lx >= x1) .* (Lx <= x2))) = polyval(X, Lx(find((Lx >= x1) .* (Lx <= x2))));
g(find(Lx>x2)) = x2.^Beta .* Lx(find(Lx>x2)).^(-Beta);