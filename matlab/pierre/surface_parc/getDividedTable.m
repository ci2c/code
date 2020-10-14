function [label_out, colortable_out] = getDividedTable(in_annot, surf_ref, subdiv, color_LUT)
% usage : [label_out, colortable_out] = getDividedTable(in_annot, surf_ref, subdiv, color_LUT)
%
% Inputs :
%    in_annot         : path to input .annot to divide
%    surf_ref         : path to reference surface to cut (usually sphere)
%    subdiv           : average size of sub-division (in vertices)
%    color_LUT        : N x 5 color LUT, N > number of ROI after division
%
% Pierre Besson @ CHRU Lille, Jun 2012

if nargin ~= 4
    error('invalid usage');
end

[vertices, label_in, colortable_in] = read_annotation(in_annot);
surf = SurfStatReadSurf(surf_ref);

label_out = zeros(size(label_in));
colortable_out.struct_names = {};
colortable_out.table = [];

big_table = [color_LUT, color_LUT(:,1) + color_LUT(:,2)*2^8 + color_LUT(:,3)*2^16];
big_table_line = 1;

for i = 1 : length(colortable_in.struct_names)
    Name = char(colortable_in.struct_names{i});
    if (strcmp(Name, 'Unknown') == 0) && (strcmp(Name, 'Medial_wall') == 0)
        Coord = surf.coord(:, label_in == colortable_in.table(i, end));
        nb_div = max(round(length(Coord) ./ subdiv), 1);
        IDX = kmeans(Coord', nb_div, 'MaxIter', 10000, 'distance', 'cityblock')';
        label_out(label_in == colortable_in.table(i, end)) = big_table(big_table_line + IDX - 1, end);
        for j = 1 : nb_div
            Name_out = [Name, '_div', num2str(j, '%.4d')];
            colortable_out.struct_names = cat(1, colortable_out.struct_names, Name_out);
            BT1 = big_table(big_table_line, 1);
            BT2 = big_table(big_table_line, 2);
            BT3 = big_table(big_table_line, 3);
            BT4 = big_table(big_table_line, 4);
            Table_out = [BT1 BT2 BT3 0 BT4];
            colortable_out.table = cat(1, colortable_out.table, Table_out);
            big_table_line = big_table_line + 1;
        end
    else
        label_out(label_in == colortable_in.table(i, end)) = big_table(big_table_line, 4);
        colortable_out.struct_names = cat(1, colortable_out.struct_names, Name);
        BT1 = big_table(big_table_line, 1);
        BT2 = big_table(big_table_line, 2);
        BT3 = big_table(big_table_line, 3);
        BT4 = big_table(big_table_line, 4);
        Table_out = [BT1 BT2 BT3 0 BT4];
        colortable_out.table = cat(1, colortable_out.table, Table_out);
        big_table_line = big_table_line + 1;
    end
end


colortable_out.numEntries = length(colortable_out.struct_names);
colortable_out.orig_tab = 'none';