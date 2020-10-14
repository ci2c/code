function Connectome = addSubcorticalStruct(Connectome, surf_path, label, names, hemi)
% usage : CONNECTOME = addSubcorticalStruct(CONNECTOME, SURF, LABEL, NAMES [, HEMI])
%
% INPUT :
% -------
%    CONNECTOME        : Connectome structure as provided by
%                         getSurfaceConnectMatrix
%
%    SURF              : surface of the subcortical structure to add
%
%    LABEL             : vector of the surface labels
%
%    NAMES             : name of the segmentations
%
%    HEMI (optional)   : specify the hemisphere, must be 'lh' or 'rh'
%
% OUTPUT :
% --------
%    CONNECTOME        : Connectome structure
%
% See also getSurfaceConnectMatrix
%
% Pierre Besson @ CHRU Lille, July 2011

if nargin ~= 4 && nargin ~= 5
    error('invalid usage');
end

UU = unique(label);
if length(UU) ~= length(names)
    error('number of different labels and names must match');
end

% Load data
surf = SurfStatReadSurf(surf_path);
nROI = length(UU);
fibers = Connectome.fibers;

% Compute triangle ROIs
Triangle_label = getTriangleLabel(surf, label);

tic;
% Computes connectome
j = length(Connectome.region) + 1 ;
for i = 1 : nROI
        if nargin == 5
            Connectome.region(j).hemi = hemi;
        end
        Connectome.region(j).name = char(names{i});
        fprintf(char(names{i}));
        fprintf(['\t \t \t Processing : ', num2str(i), '/', num2str(nROI), '\t Time : ', num2str(toc), ' sec\n']);
        Surf_select = parcellation_select(surf, label == i, Triangle_label == i);
        Temp = distance(mean(Surf_select.coord, 2), Surf_select.coord);
        Temp = find(Temp == min(Temp));
        Connectome.region(j).coord = Surf_select.coord(:, Temp)';
        [fibers_i, selected] = select_fibers_fast2(surf, fibers, label == i, 5);
        Connectome.region(j).selection = selected;
        Connectome.region(j).area = getSurfaceArea(Surf_select);
        j = j+1;
end

[Connectome.M, Connectome.distance, Connectome.areas] = connectome2matrix(Connectome);