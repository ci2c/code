function [T_m, L_max, L_min] = getGraphAverageMat(g)
% Usage : [T_M, L_MAX, L_MIN] = getGraphAverageMat(G)
%
% Returns matrix for computing average sequences at each vertex
%
% Inputs :
%           G          : input connectivity graph
%
% Output :
%           T_M        : Transformation matrix
%           L_MAX      : Max distance between any 2 nodes
%           L_MIN      : Min distance of all max distances
%
% See also initGraph
%
% Pierre Besson, Oct. 2009

if nargin ~= 1
    error('Invalid usage');
end

% Get line graph of g
h = graph;
line_graph(h,g);
% Number of lines
N = size(h);
N = N(1);
% Distance matrix
disp('Computing distance matrix...');
tic;
Dist = [];
Bar = waitbar(0.0, 'Processing');
for i = 1 : N
    Dist = [Dist; dist(h,i)];
    waitbar(i/N, Bar);
%     fprintf('.');
%     if mod(i, 100) == 0
%         fprintf('\n');
%     end
end
delete(Bar);
% fprintf('\n');
L_max = max(Dist(:));
L_min = min(max(Dist, [], 2));
fprintf('Elapsed time : %.2f sec ; Distance max = %d ; min = %d\n', toc, L_max, L_min);

% Define T_M
T_m = sparse(zeros(N, (1+L_max) * N));

% Fill T_M
disp('Filling the matrix...');
tic;
Bar = waitbar(0.0, 'Processing');
for i = 0 : L_max
    Dist_i = sparse((Dist == i));
    S = sum(Dist_i, 2);
    S = ones(size(S)) ./ S;
    S(isnan(S)) = 0;
    S = sparse(diag(S));
    T_m(:, i*N+1:(i+1)*N) = S * Dist_i;
%     fprintf('%2.1f  ', 100*i/(L_max+1));
    waitbar(i/L_max, Bar);
end
% fprintf('\n');
delete(Bar);
fprintf('Completed in %.2f sec\n', toc);
free(h);