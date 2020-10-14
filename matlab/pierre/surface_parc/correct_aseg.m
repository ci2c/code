function correct_aseg(labels, colortable, offset, path_white, path_pial, aseg_vol);
% usage : correct_aseg(labels, colortbale, offset, path_white_surf, path_pial_surf, aseg_vol);
%
% Inputs :
%    labels           : labels assigned to vertices
%    colortable       : colortable associated to labels annotation
%    offset           : value of the first volume ROI
%    path_white_surf  : path to white surf
%    path_pial_surf   : path to pial surf
%    aseg_vol         : path to aseg volume to correct
%
% Pierre Besson @ CHRU Lille, Jun 2012

if nargin ~= 6
    error('invalid usage');
end

V_aseg = spm_vol(aseg_vol);

surf_w = SurfStatReadSurf(path_white);
surf_w = surf_to_ras_nii(surf_w, aseg_vol);
surf_p = SurfStatReadSurf(path_pial);
surf_p = surf_to_ras_nii(surf_p, aseg_vol);
nb_vert = length(surf_w.coord);

[Y_aseg, XYZ] = spm_read_vols(V_aseg);
Y_aseg = round(Y_aseg);
% [Y_rib, XYZ] = spm_read_vols(V_rib);
if ~isempty(strfind(path_white, '/lh.'))
    % left hemisphere
    Y_rib = (Y_aseg > 1000) .* (Y_aseg <= 1035) + (Y_aseg > 11100) .* (Y_aseg <= 11175);
else
    % right hemisphere
    Y_rib = (Y_aseg > 2000) .* (Y_aseg <= 2035) + (Y_aseg > 12100) .* (Y_aseg <= 12175);
end

Y_aseg_corr = Y_aseg;

index_rib = find(Y_rib~=0);
L_rib = length(index_rib);

% Exclude Medial Wall for classification
Medial_wall = find(strcmp(colortable.struct_names, 'Medial_wall'));
Medial_wall = colortable.table(Medial_wall, end);
Medial_wall = labels == Medial_wall;

% progress('init');
for i = 1 : L_rib
    if mod(i, 4000) == 0
        % progress(i/L_rib, sprintf('Done %.2f', 100*i/L_rib));
        disp(['Done ', num2str(100*i/L_rib, '%.2f')]);
    end
    Coord_ref = repmat(XYZ(:, index_rib(i)), 1, nb_vert);
    Dist_w = sum( (surf_w.coord - Coord_ref) .* (surf_w.coord - Coord_ref));
    Dist_p = sum( (surf_p.coord - Coord_ref) .* (surf_p.coord - Coord_ref));
    Dist = Dist_w + Dist_p;
    Dist(Medial_wall) = inf;
    Y_aseg_corr(index_rib(i)) = find(labels(find(Dist == min(Dist), 1, 'first')) == colortable.table(:,end)) + offset;
end
% progress('close');

spm_write_vol(V_aseg, Y_aseg_corr);