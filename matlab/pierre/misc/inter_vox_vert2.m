function inter_vox_vert2(Vol, Surf, Vert, fname)
% usage : inter_vox_vert2(VOL, SURF, VERT, FNAME)
% Convert surface label to volume
%
% Inputs :
%   VOL    : Path to the reference volume
%   SURF   : Path to the surface of interest
%   VERT   : Path to the annotation file of interest
%   FNAME  : Name of the output volume

if nargin ~= 4
    help inter_vox_vert
    error('Incorrect use');
end

% Load data
[vertices, faces] = freesurfer_read_surf(Surf);
mri = MRIread(Vol);
[v, label, colortable] = read_annotation(Vert);
Labels = unique(label);

vol = rotate_to_surf(mri.vol);
Size = size(vol);
OutVol = zeros(Size);

Ix = (-Size(1)/2 + 1) : 1 : Size(1)/2;
Iy = -Size(2)/2 : 1 : (Size(2)/2 - 1);
Iz = (-Size(3)/2 + 1) : 1 : Size(3)/2;
LIx = length(Ix);
LIy = length(Iy);
LIz = length(Iz);
LIxO = ones(LIx, 1);
LIyO = ones(LIy, 1);
LIzO = ones(LIz, 1);

for i = 1 : size(vertices, 1)
    C_x = find(abs(LIxO.*vertices(i, 1)-Ix') == min(abs(LIxO.*vertices(i, 1)-Ix')));
    C_y = find(abs(LIyO.*vertices(i, 2)-Iy') == min(abs(LIyO.*vertices(i, 2)-Iy')));
    C_z = find(abs(LIzO.*vertices(i, 3)-Iz') == min(abs(LIzO.*vertices(i, 3)-Iz')));
    OutVol(C_y, C_x, C_z) = find(Labels==label(i));
end

mri.vol = inv_rotate_to_surf(OutVol);
MRIwrite(mri, fname);