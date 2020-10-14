function D=distance_bin(G, max_dist)
%DISTANCE_BIN       Distance matrix
%
%   D = distance_bin(A, [max_dist]);
%
%   The distance matrix contains lengths of shortest paths between all
%   pairs of nodes. An entry (u,v) represents the length of shortest path 
%   from node u to node v. The average shortest path length is the 
%   characteristic path length of the network.
%
%   Input:      A,      binary directed/undirected connection matrix
%
%   Option: max_dist,   does not evaluate distance above max_dist
%
%   Output:     D,      distance matrix
%
%   Notes: 
%       Lengths between disconnected nodes are set to Inf.
%       Lengths on the main diagonal are set to 0.
%
%   Algorithm: Algebraic shortest paths.
%
%
%   Mika Rubinov, UNSW, 2007-2010.
%   Pierre Besson : Optimisation for sparse matrix and add max_dist option

if nargin == 1
    max_dist = inf;
end

size_G = size(G, 1);
D=speye(length(G));
n=1;
nPATH=G;                        %n-path matrix
L=(nPATH~=0);                   %shortest n-path matrix

while (find(L,1) && n <= max_dist);
    D=D+n.*L;
    n=n+1;
    nPATH=nPATH*G;
    [i, j, k] = find(nPATH);
    i2 = i + size_G * (j-1);
    L = sparse(i,j, (k~=0) .* (D(i2)==0), size_G, size_G);
    % L=(nPATH~=0).*(D==0);
end

if nargin == 1
    D(~D)=inf;                      %disconnected nodes are assigned d=inf;
    D=D-speye(length(G));
end

if ~issparse(G)
    D = full(D);
end