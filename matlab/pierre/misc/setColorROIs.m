function output_vector = setColorROIs(surface_path, annot_path, annot_name, connectome, input_vector, output_vtk)
% Usage : OUTPUT_VECTOR = setColorROIs( SURFACE_PATH, ANNOT_PATH, ANNOT_NAME, ...
%                                       CONNECTOME, INPUT_VECTOR
%                                       [, OUTPUT_VTK])
%
% Color a parcellated surface with ROI features
% 
% Inputs :
%       SURFACE_PATH     : path to the directory containing the surfaces ('lh.pial' and 'rh.pial')
%       ANNOT_PATH       : path to the directory containing annotation files (N ROIs)
%       ANNOT_NAME       : name of the annotation files to use 
%                              (i.e. aparc.500_test.annot)
%       CONNECTOME       : path to the Connectome.mat file
%       INPUT_VECTOR     : N x K x M table of the ROI features to plot on
%                              surface
%       (Option)
%           OUTPUT_VTK   : print the colored surface in a VTK file
%
% Output :
%       OUTPUT_VECTOR    : N_vertex x K x M table of ROIs features mapped on
%                              surface
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 5 & nargin ~= 6
    error('invalid usage');
end

% Load stuffs
try
    surf_lh = strcat(surface_path, '/lh.pial');
    surf_rh = strcat(surface_path, '/rh.pial');
    Surf = SurfStatReadSurf([{surf_lh}, {surf_rh}]);
catch
    error('Can not load surface');
end

try
    lh_annot = strcat(annot_path, '/lh.', annot_name);
    rh_annot = strcat(annot_path, '/rh.', annot_name);
    [vertices_lh, label_lh, colortable_lh] = read_annotation(lh_annot);
    [vertices_rh, label_rh, colortable_rh] = read_annotation(rh_annot);
catch
    error('Can not load annot file');
end


try
    eval(['load ' connectome]);
catch
    error('Can not load connectome');
end

% Loop on ROIs
output_vector = zeros(size([label_lh; label_rh], 1), size(input_vector, 2), size(input_vector, 3));
Lh = length(label_lh);
label_lh = [label_lh; zeros(size(label_rh))];
label_rh = [zeros(Lh, 1); label_rh];

for i = 1 : length(Connectome.region)
    if ~isempty(findstr(Connectome.region(i).name, 'lh'))
        for j = 1 : length(colortable_lh.struct_names)
            if ~isempty(strfind(Connectome.region(i).name, char(colortable_lh.struct_names(j))))
                output_vector(label_lh == colortable_lh.table(j, end), :, :) = repmat(input_vector(i, :, :), [size(output_vector(label_lh == colortable_lh.table(j, end), :), 1), 1, 1]);
                break;
            end
        end
    else
        if ~isempty(findstr(Connectome.region(i).name, 'rh'))
            for j = 1 : length(colortable_rh.struct_names)
                if ~isempty(strfind(Connectome.region(i).name, char(colortable_rh.struct_names(j))))
                    output_vector(label_rh == colortable_rh.table(j, end), :, :) = repmat(input_vector(i, :, :), [size(output_vector(label_rh == colortable_rh.table(j, end), :), 1), 1, 1]);
                    break;
                end
            end
        end
    end
end

if nargin == 6
    disp('Save VTK surface...');
    truc.feature = output_vector;
    save_surface_vtk(Surf, output_vtk, 'BINARY', truc);
end