function P_vals = permTest(Group1, Group2, N)
% P_vals = permTest(GROUP1, GROUP2, N)
% Performs permuatation test between Group1 and Group2 (Contrast : Group1 - Group2)
%
% Inputs :
%    GROUP1    : M x M x G1 x J matrix, G1 is the number of subjects in
%                 group 1, J is the number of scales
%
%    GROUP2    : M x M x G2 x J matrix, G2 is the number of subjects in
%                 group 2, J is the number of scales
%
%    N         : Number of permutations
%
% Output :
%    P_VALS    : M x M x J matrix containing p-values at the J scales
%
% Pierre Besson, Sept. 2009

if nargin ~= 3
    error('Invalid usage');
end

if size(Group1, 1) ~= size(Group2, 1)
    error('Matrices sizes must correspond');
end

if size(Group1, 2) ~= size(Group2, 2)
    error('Matrices sizes must correspond');
end


nx = size(Group1, 1);
ny = size(Group1, 2);
G1 = size(Group1, 3);
G2 = size(Group2, 3);

Group1(isnan(Group1)) = 0;
Group2(isnan(Group2)) = 0;

Group1 = reshape(Group1, nx*ny, G1);
Group2 = reshape(Group2, nx*ny, G2);

MeanG1 = mean(Group1, 2);
MeanG2 = mean(Group2, 2);
Diff_inits = MeanG1 - MeanG2;

Group1 = [Group1, Group2];
clear Group2;
P_vals = zeros(nx*ny, 1);
disp('Performs Permutation Test');
tic;
for i = 1 : N
    G = randperm(G1+G2);
    M1 = mean(Group1(:, G(1:G1)), 2);
    M2 = mean(Group1(:, G(G1+1:end)), 2);
    P_vals = P_vals + ((M1 - M2) > Diff_inits);
    if mod(i, 500) == 0
        disp(['Iteration : ', num2str(i), '  Time : ', num2str(toc)]);
    end
end

P_vals = (P_vals + ones(size(P_vals))) ./ N;
P_vals = P_vals .* (MeanG1 ~= 0);
P_vals = reshape(P_vals, nx, ny);