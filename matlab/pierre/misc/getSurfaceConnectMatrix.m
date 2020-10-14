function Connectome = getSurfaceConnectMatrix(surf_lh_path, surf_rh_path, annot_lh_path, annot_rh_path, stats_lh_path, stats_rh_path, fibers_path)
% usage : CONNECTOME = getSurfaceConnectMatrix(SURF_lh, SURF_rh, ANNOT_lh, ANNOT_rh, STATS_lh, STATS_rh, FIBERS)
%
% INPUT :
% -------
%    SURF_lh           : Path to left hemisphere surface
%
%    SURF_rh           : Path to right hemisphere surface
%
%    ANNOT_lh          : Path to left hemisphere segmentation
%
%    ANNOT_rh          : Path to right hemisphere segmentation
%
%    STATS_lh          : Path to left hemisphere ROI statistics
%
%    STATS_rh          : Path to right hemisphere ROI statistics
%
%    FIBERS            : Path to MedINRIA .fib fibers
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% Pierre Besson @ CHRU Lille, December 2010

if nargin ~= 7
    error('invalid usage');
end

% Load data
surf_lh = SurfStatReadSurf(surf_lh_path);
surf_rh = SurfStatReadSurf(surf_rh_path);
[vertices, label_lh, colortable_lh] = read_annotation(annot_lh_path);
[vertices, label_rh, colortable_rh] = read_annotation(annot_rh_path);


% Compute triangle ROIs
Triangle_label_lh = getTriangleLabel(surf_lh, label_lh);
Triangle_label_rh = getTriangleLabel(surf_rh, label_rh);

% Load fibers
if strfind(fibers_path, '.fib')
    disp('MedINRIA fibers');
    fibers = f_readFiber_vtk_bin(fibers_path);
    fibers = tracts_flip_x(tracts_flip_y(fibers));
else
    if strfind(fibers_path, 'FTR.mat')
        disp('dti tool fibers');
        fibers = FTRtoTracts(fibers_path);
    else
        if strfind(fibers_path, '.tck')
            disp('mrtrix fibers');
            fibers = f_readFiber_tck(fibers_path);
        else
            error('unrecognized fibers type');
        end
    end
end

Areas_lh = textread(stats_lh_path, '%s', 'commentstyle', 'shell');
Areas_rh = textread(stats_rh_path, '%s', 'commentstyle', 'shell');
nROI_lh = size(Areas_lh, 1) ./ 10;
nROI_rh = size(Areas_rh, 1) ./ 10;

tic;
% Computes connectome
j = 1;
for i = 1 : size(colortable_lh.table, 1)
    F = find(strcmp(Areas_lh, colortable_lh.struct_names(i)));
    if ~isempty(F)
        Connectome.region(j).hemi = 'lh';
        Connectome.region(j).name = colortable_lh.struct_names{i};
        fprintf(colortable_lh.struct_names{i});
        fprintf(['\t \t \t Processing : ', num2str(j), '/', num2str(nROI_lh), '\t Time : ', num2str(toc), ' sec\n']);
        Surf_select = parcellation_select(surf_lh, label_lh==colortable_lh.table(i, end), Triangle_label_lh==colortable_lh.table(i, end));
%         save_surface_vtk(Surf_select, strcat('surface_', colortable_lh.struct_names{i}, '_lh.vtk'));
        % Connectome.region(j).coord = median(Surf_select.coord, 2)';
        Temp = distance(mean(Surf_select.coord, 2), Surf_select.coord);
        Temp = find(Temp == min(Temp));
        Connectome.region(j).coord = Surf_select.coord(:, Temp)';
        [fibers_i, selected] = select_fibers_fast2(surf_lh, fibers, label_lh==colortable_lh.table(i, end), 5);
        Connectome.region(j).selection = selected;
        Connectome.region(j).area = str2double(char(Areas_lh(F+2)));
%         if fibers_i.nFiberNr > 0
%             save_tract_vtk(fibers_i, strcat(colortable_lh.struct_names{i}, '_lh.vtk'));
%         end
        j = j + 1;
    end
end

for i = 1 : size(colortable_rh.table, 1)
    F = find(strcmp(Areas_rh, colortable_rh.struct_names(i)));
    if ~isempty(F)
        Connectome.region(j).hemi = 'rh';
        Connectome.region(j).name = colortable_rh.struct_names{i};
        fprintf(colortable_rh.struct_names{i});
        fprintf(['\t \t \t Processing : ', num2str(j), '/', num2str(nROI_rh + nROI_lh), '\t Time : ', num2str(toc), ' sec\n']);
        Surf_select = parcellation_select(surf_rh, label_rh==colortable_rh.table(i, end), Triangle_label_rh==colortable_rh.table(i, end));
%         save_surface_vtk(Surf_select, strcat('surface_', colortable_rh.struct_names{i}, '_rh.vtk'));
        % Connectome.region(j).coord = median(Surf_select.coord, 2)';
        Temp = distance(mean(Surf_select.coord, 2), Surf_select.coord);
        Temp = find(Temp == min(Temp));
        Connectome.region(j).coord = Surf_select.coord(:, Temp)';
        [fibers_i, selected] = select_fibers_fast2(surf_rh, fibers, label_rh==colortable_rh.table(i, end), 5);
        Connectome.region(j).selection = selected;
        Connectome.region(j).area = str2double(char(Areas_rh(F+2)));
%         if fibers_i.nFiberNr > 0
%             save_tract_vtk(fibers_i, strcat(colortable_rh.struct_names{i}, '_rh.vtk'));
%         end
        j = j + 1;
    end
end

Connectome.fibers = fibers;