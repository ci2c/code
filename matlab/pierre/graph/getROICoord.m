function Coord = getROICoord(fpath, Subj, parcellation, Connectome)
% Usage : COORD = getROICoord(FPATH, SUBJ, PARC, CONNECTOME)
%
% Return coordinates vectors of the CoG of the ROIs
%
% Inputs :
%    FPATH        : FS path. Equivalent to FreeSurfer SUBJECTS_DIR
%    SUBJ         : Name of the subject
%    PARC         : Name of the parcellation file. Ex : 'aparc.annot'
%    CONNECTOME   : Connectome structure as provided by
%                    getSurfaceConnectMatrix
%
% Output :
%    COORD        : nROI x 3 coordinates matrix
%
% See also getSurfaceConnectMatrix
%
% Pierre Besson @ CHRU Lille, 2011

if nargin ~= 4
    error('Invalid use');
end

% define paths
annot_lh_path = strcat(fpath, '/', Subj, '/label/lh.', parcellation);
annot_rh_path = strcat(fpath, '/', Subj, '/label/rh.', parcellation);
surf_lh_path = strcat(fpath, '/', Subj, '/surf/lh.white');
surf_rh_path = strcat(fpath, '/', Subj, '/surf/rh.white');

% load data
surf_lh = SurfStatReadSurf(surf_lh_path);
surf_rh = SurfStatReadSurf(surf_rh_path);
[vertices, label_lh, colortable_lh] = read_annotation(annot_lh_path);
[vertices, label_rh, colortable_rh] = read_annotation(annot_rh_path);

% Compute triangle ROIs
Triangle_label_lh = getTriangleLabel(surf_lh, label_lh);
Triangle_label_rh = getTriangleLabel(surf_rh, label_rh);

Coord = [];
for i = 1 : size(Connectome.region, 2)
    if ~isempty(findstr(Connectome.region(i).name, 'lh'))
        Name = Connectome.region(i).name(4:end);
        Name(Name == ' ') = [];
        F = find(strcmp(colortable_lh.struct_names, Name));
        Surf_select = parcellation_select(surf_lh, label_lh==colortable_lh.table(F, end), Triangle_label_lh==colortable_lh.table(F, end));
        % Coord = [Coord; median(Surf_select.coord, 2)'];
        Temp = distance(mean(Surf_select.coord, 2), Surf_select.coord);
        Temp = find(Temp == min(Temp));
        Coord = [Coord; Surf_select.coord(:, Temp)'];
    else
        if ~isempty(findstr(Connectome.region(i).name, 'rh'))
            Name = Connectome.region(i).name(4:end);
            Name(Name == ' ') = [];
            F = find(strcmp(colortable_rh.struct_names, Name));
            Surf_select = parcellation_select(surf_rh, label_rh==colortable_rh.table(F, end), Triangle_label_rh==colortable_rh.table(F, end));
            % Coord = [Coord; median(Surf_select.coord, 2)'];
            Temp = distance(mean(Surf_select.coord, 2), Surf_select.coord);
            Temp = find(Temp == min(Temp));
            Coord = [Coord; Surf_select.coord(:, Temp)'];
        else
            Coord = [Coord; NaN NaN NaN];
        end
    end
end