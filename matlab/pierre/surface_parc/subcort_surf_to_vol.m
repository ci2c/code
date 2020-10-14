function subcort_surf_to_vol(struc_ribbon, outvol, surf, annot, out_ct);
% usage : subcort_surf_to_vol(STRUCT_RIBBON, OUTVOL, SURF, ANNOT, OUT_CT);
%
% Inputs :
%    STRUCT_RIBBON     : Path to outer ribbon volume of the structure of
%                         interest (.nii RAS)
%    OUTVOL            : Path to output volume, i.e. '/out/volume.nii'
%    SURF              : Path to the surface model of the structure of
%                        interest or surface structure as provided by
%                        SurfStatReadSurf
%    ANNOT             : Path to the parcellation scheme .annot
%    OUT_CT            : Path to output colortable .ctab
%
% Pierre Besson @ CHRU Lille, Aug 2012

if nargin ~= 5
    error('invalid usage');
end

if ischar(surf)
    surf = SurfStatReadSurf(surf);
end

% Read data
surf_ras = surf_to_ras_nii(surf, struc_ribbon);
nb_vert = length(surf_ras.coord);
[vertices, label, colortable] = read_annotation(annot);
V = spm_vol(struc_ribbon);
[Y, XYZ] = spm_read_vols(V);

% Interpolate volume
Y_out = zeros(size(Y));
index_rib = find(Y~=0);
L_rib = length(index_rib);

progress('init');
for i = 1 : L_rib
    if mod(i, 1000) == 0
        progress(i/L_rib, sprintf('Done %.2f', 100*i/L_rib));
    end
    Coord_ref = repmat(XYZ(:, index_rib(i)), 1, nb_vert);
    Dist = sum( (surf_ras.coord - Coord_ref) .* (surf_ras.coord - Coord_ref));
    Y_out(index_rib(i)) = find(label(find(Dist == min(Dist), 1, 'first')) == colortable.table(:,end));
end
progress('close');

V.fname = outvol;
V.dt(1) = 16;
spm_write_vol(V, Y_out);

% Print LUT
fid = fopen(out_ct, 'w');
for i = 1 : length(colortable.struct_names)
    fprintf(fid, '%d\t %s\t %d \t %d \t %d \t 0\n', i, [colortable.struct_names{i}], colortable.table(i,1), colortable.table(i,2), colortable.table(i,3));
end
fclose(fid);