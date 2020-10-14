function [Mh, n_att_h, e_att_h] = getSubGraph(Mg, n_att, e_att)
% usage : [Mh, n_att_h, e_att_h] = getSubGraph(Mg, n_att, e_att)
%
% Inputs :
%        Mg      : input graph connectivity matrix (binary or weight)
%                    composed of N nodes and E edges
%
%        n_att   : input nodes attributes (set [] if none)
%                    N x 1 vector or structure of N x 1 vectors
%                    If several vectors found in the structure, takes
%                    intersection of non-zeros values : a node is kept is
%                    all numeric values are non-zero and all non-numeric
%                    values are not empty
%
%        e_att   : input edges attributes (set [] if none)
%                    E x 1 vector or structure of E x 1 vectors
%                    If several vectors found in the structure, takes
%                    intersection of non-zeros values : an edge is kept is
%                    all numeric values are non-zero and all non-numeric
%                    values are not empty
%
% Outputs :
%        Mh      : output graph matrix
%        n_att_h : output nodes attributes
%        e_att_h : output edges attributes
%
% Discard nodes and edges of G where n_att or e_att is zero
%
% See also graph2gml
%
% Pierre Besson @ CHRU Lille, Mar. 2012

if nargin ~=1 && nargin ~=2 && nargin ~= 3
    error('invalid usage');
end

N = size(Mg, 1);
is_sym = Mg - Mg';
if sum(is_sym(:)) == 0
    mat_mask = tril(Mg);
    symflag = 1;
else
    symflag = 0;
end

E = sum(mat_mask(:) ~= 0);
[i_g,j_g] = find(mat_mask);
edge_list = i_g + (N - 1) * j_g;

% if they are structures, get nodes and edges field
if isstruct(n_att)
    n_field_names = fieldnames(n_att);
    n_field_N     = length(n_field_names);
    n_mask = zeros(N, 1);
    for i = 1 : n_field_N
        Temp = n_att.(char(n_field_names(i)));
        if isnumeric(Temp)
            n_mask = n_mask + double(Temp == 0);
        else
            n_mask = n_mask + double(strcmp(Temp, ''));
        end
    end
else
    if isnumeric(n_att)
        n_mask = n_att == 0;
    else
        n_mask = strcmp(n_att, '');
    end
end

if isstruct(e_att)
    e_field_names = fieldnames(e_att);
    e_field_N     = length(e_field_names);
    e_mask = zeros(E, 1);
    for i = 1 : e_field_N
        Temp = e_att.(char(e_field_names(i)));
        if isnumeric(Temp)
            e_mask = e_mask + double(Temp == 0);
        else
            e_mask = e_mask + double(strcmp(Temp, ''));
        end
    end
else
    if isnumeric(e_att)
        e_mask = e_att == 0;
    else
        e_mask = strcmp(e_att, '');
    end
end

Mh = zeros(size(Mg));
Mh(mat_mask(:)~=0) = e_mask == 0;
Mh = Mh + Mh';

% Remove unconnected nodes in Mh
rm_node_list = sum(Mh) == 0;
Mh(rm_node_list, :) = [];
Mh(:, rm_node_list) = [];

% Remove useless connections linking unconnected nodes in e_att
if isstruct(e_att)
    for i = 1 : e_field_N
        Temp = e_att.(char(e_field_names(i)));
        Temp( e_mask == 1 ) = [];
        e_att.(char(e_field_names(i))) = Temp;
    end
else
    e_att( e_mask == 1 ) = [];
end

% Remove useless node in n_att
if isstruct(n_att)
    for i = 1 : n_field_N
        Temp = n_att.(char(n_field_names(i)));
        Temp(rm_node_list) = [];
        n_att.(char(n_field_names(i))) = Temp;
    end
else
    n_att(rm_node_list) = [];
end

% Remove text associated to node with node's weight == 0
n_mask(rm_node_list) = [];
if isstruct(n_att)
    for i = 1 : n_field_N
        Temp = n_att.(char(n_field_names(i)));
        if ~isnumeric(Temp)
            Temp(n_mask==1) = {' '};
            n_att.(char(n_field_names(i))) = Temp;
        end
    end
end

n_att_h = n_att;
e_att_h = e_att;