function M = gauss_graph(g, v, S, K)
% usage: M = gauss_graph(G, V, S, K)
%
% G : graph
% V : vertex center of the gaussian
% S : Std. dev.
% K : constant factor
%
% Pierre Besson, Jan 2009

if nargin ~= 4
    error('Invalid expression');
end

Mbin = matrix(g);
M = zeros(size(Mbin));
h = graph;
line_graph(h, g);
L = sortrows(edges(g));
Dist = dist(h, v);

for k = 0 : max(Dist)
    G = K .* exp(-(k*k) ./ (2 .* S * S));
    Lk = find(Dist == k);
    for j=1 : length(Lk)
        M(L(Lk(j), 1), L(Lk(j), 2)) = G;
        M(L(Lk(j), 2), L(Lk(j), 1)) = G;
    end
end

free(h);