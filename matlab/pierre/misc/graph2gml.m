function graph2gml(g, gml_filename, n_att, e_att)
% usage: graph2gml(G, GML_FILENAME, [NODES_ATTRIBUTES, EDGES_ATTRIBUTES])
%
% Print graph G in GML format
%
% Inputs:
%   G                : Graph (N nodes, V edges)
%   GML_FILENAME     : Name of the output
%
% Options:
%   NODES_ATTRIBUTES : Attributes for nodes.
%               N_A.attr1 = N x 1 table of attibutes
%   EDGES_ATTRIBUTES : Attiributes for edges
%               E_A.attr1 = V x 1 table of attributes
%
% Pierre Besson, Feb. 2012

if nargin ~= 2 && nargin ~= 3 && nargin ~= 4
    error('invalid usage');
end

% Get edges and open output file
[n_nodes, n_edges] = size(g);
Mg = matrix(g);
[i, j] = find(tril(Mg));
Edges = [i,j];
fid = fopen(gml_filename, 'w');
fprintf(fid, 'graph [\n');
fprintf(fid, '  name "graph powered by PBTB" \n');

% Print Nodes attribute
fields = fieldnames(n_att);
n_fields = length(fields);
for node = 1 : n_nodes
    fprintf(fid, '  node [\n');
    fprintf(fid, '  id %d\n', node);
    for F = 1 : n_fields
        if ischar(n_att.(char(fields(F))))
            fprintf(fid, '  %s "', char(fields(F)));
            String=n_att.(char(fields(F)))(node, :);
            String(String==' ')=[];
            fprintf(fid, ' %s', String);
            fprintf(fid, '"\n');
        else
            if strcmp( class(n_att.(char(fields(F)))), 'double') || strcmp( class(n_att.(char(fields(F)))), 'single')
                fprintf(fid, '  %s', char(fields(F)));
                fprintf(fid, ' %f', n_att.(char(fields(F)))(node, :));
                fprintf(fid, '\n');
            else
                if strcmp( class(n_att.(char(fields(F)))), 'logical') || strcmp( class(n_att.(char(fields(F)))), 'int8') || strcmp( class(n_att.(char(fields(F)))), 'uint8') || strcmp( class(n_att.(char(fields(F)))), 'int16') || strcmp( class(n_att.(char(fields(F)))), 'uint16') || strcmp( class(n_att.(char(fields(F)))), 'int32') || strcmp( class(n_att.(char(fields(F)))), 'uint32') || strcmp( class(n_att.(char(fields(F)))), 'int64') || strcmp( class(n_att.(char(fields(F)))), 'uint64')
                    fprintf(fid, '  %s', char(fields(F)));
                    fprintf(fid, ' %d', n_att.(char(fields(F)))(node, :));
                    fprintf(fid, '\n');
                else
                    if iscell( n_att.(char(fields(F))) )
                        fprintf(fid, '  %s "', char(fields(F)));
                        String = n_att.(char(fields(F))){node};
                        String(String==' ')=[];
                        fprintf(fid, ' %s', String);
                        fprintf(fid, '"\n');
                    else
                        warning(['Field ' char(fields(F)) ' unrecognized']);
                    end
                end
            end
        end
    end
    fprintf(fid, '  ]\n');
end



% Print Edges attribute
fields = fieldnames(e_att);
n_fields = length(fields);
for edge = 1 : n_edges
    fprintf(fid, '  edge [\n');
    fprintf(fid, '  source %d\n', Edges(edge, 1));
    fprintf(fid, '  target %d\n', Edges(edge, 2));
    for F = 1 : n_fields
        if ischar(e_att.(char(fields(F))))
            fprintf(fid, '  %s "', char(fields(F)));
            String = e_att.(char(fields(F)))(edge, :);
            String(String==' ')=[];
            fprintf(fid, ' %s', String);
            fprintf(fid, '"\n');
        else
            if strcmp( class(e_att.(char(fields(F)))), 'double') || strcmp( class(e_att.(char(fields(F)))), 'single')
                fprintf(fid, '  %s', char(fields(F)));
                fprintf(fid, ' %f', e_att.(char(fields(F)))(edge, :));
                fprintf(fid, '\n');
            else
                if strcmp( class(e_att.(char(fields(F)))), 'logical') || strcmp( class(e_att.(char(fields(F)))), 'int8') || strcmp( class(e_att.(char(fields(F)))), 'uint8') || strcmp( class(e_att.(char(fields(F)))), 'int16') || strcmp( class(e_att.(char(fields(F)))), 'uint16') || strcmp( class(e_att.(char(fields(F)))), 'int32') || strcmp( class(e_att.(char(fields(F)))), 'uint32') || strcmp( class(e_att.(char(fields(F)))), 'int64') || strcmp( class(e_att.(char(fields(F)))), 'uint64')
                    fprintf(fid, '  %s', char(fields(F)));
                    fprintf(fid, ' %d', e_att.(char(fields(F)))(edge, :));
                    fprintf(fid, '\n');
                else
                    if iscell( e_att.(char(fields(F))) )
                        fprintf(fid, '  %s "', char(fields(F)));
                        String=e_att.(char(fields(F))){node};
                        String(String==' ') = [];
                        fprintf(fid, ' %s', String);
                        fprintf(fid, '"\n');
                    else
                        warning(['Field ' char(fields(F)) ' unrecognized']);
                    end
                end
            end
        end
    end
    fprintf(fid, '  ]\n');
end



fprintf(fid, ']');
fclose(fid);