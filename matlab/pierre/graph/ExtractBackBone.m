function M_bb = ExtractBackBone(M, nd)
% usage: M_bb = ExtractBackBone(M, [Nd])
%
% Extracts backbone of a graph
%
% Inputs :
%   M          : input connectivity matrix
% Option :
%   Nd         : Final average node degree (defaut: 1)
%
% Output :
%   M_bb       : Connectivity matrix of the graph backbone
%
% Pierre Besson, June 2009

if nargin ~= 1 & nargin ~= 2
    error('Incorrect usage');
end

% temp matrices to replace empty rows / columns
F = find(sum(M)==0);
if ~isempty(F)
    Original_index = double(sum(M)~=0);
    Original_index = (Original_index' * Original_index)~=0;
    Original_size = size(M);
    M(F, :) = [];
    M(:, F) = [];
end

[Tree, Cost] = UndirectedMaximumSpanningTree(M);
M_bb = Tree .* M;
M2 = (~Tree).*M;

if nargin == 2
    if nd < 2
        warning('Nd must be larger than 2');
        return;
    end
    nConnections = round(size(M,1) .* nd - sum(M_bb(:)~=0));
    Thre = sort(M2(:), 'descend');
    Thre = Thre(nConnections+1);
    M_bb = M_bb + (M2 > Thre).*M2;
end

% Put back empty rows / columns
if ~isempty(F)
    M_bb2 = zeros(Original_size);
    M_bb2(Original_index) = M_bb;
    M_bb = M_bb2;
end