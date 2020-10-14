function InterpSurf2Vol(FS, parcname)
% Usage : InterpSurf2Vol(FS, PARCNAME)
%
% Interpolate Surface Labels (white surface) to Volume Labels
%
% Inputs :
%   FS         : Path to FreeSurfer output directory 
%                   (i.e. SUBJECTS_DIR/subject/)
%   PARCNAME   : Name of annotation 
%                   (example : 'aparc.a2005s.annot')
%
% Pierre Besson, 2010

if nargin ~= 2
    error('Invalid usage');
end

% Load data
Path = strcat(FS, '/surf/lh.white');
Surf_lh = SurfStatReadSurf(Path);
Path = strcat(FS, '/surf/rh.white');
Surf_rh = SurfStatReadSurf(Path);

Path = strcat(FS, '/label/lh.', parcname);
[v, label_left, colortable_left] = read_annotation(Path);
Path = strcat(FS, '/label/rh.', parcname);
[v, label_right, colortable_right] = read_annotation(Path);

Path = strcat(FS, '/dti/Matrix/lh.white_rib.mgz');
Mask_lh = MRIread(Path);
Path = strcat(FS, '/dti/Matrix/rh.white_rib.mgz');
Mask_rh = MRIread(Path);

% vol_lh = rotate_to_surf(Mask_lh.vol);
% vol_rh = rotate_to_surf(Mask_rh.vol);

vol_lh = Mask_lh.vol;
vol_rh = Mask_rh.vol;

Size = size(Mask_lh.vol);

[Y, X, Z] = ndgrid(-Size(1)/2 + 1 : Size(1)/2,  -Size(2)/2 : Size(2)/2 - 1, -Size(3)/2 + 1 : Size(3)/2);

F_lh = find(vol_lh~=0);
F_rh = find(vol_rh~=0);

I_lh = griddatan([Surf_lh.coord(1,:)', Surf_lh.coord(2,:)', Surf_lh.coord(3,:)'], label_left, [X(F_lh), Y(F_lh), Z(F_lh)], 'nearest');
I_rh = griddatan([Surf_rh.coord(1,:)', Surf_rh.coord(2,:)', Surf_rh.coord(3,:)'], label_right, [X(F_rh), Y(F_rh), Z(F_rh)], 'nearest');

Out_lh = zeros(Size);
Out_rh = zeros(Size);

Out_lh(F_lh) = I_lh;
Out_rh(F_rh) = I_rh;

% Mask_lh.vol = inv_rotate_to_surf(Out_lh);
Mask_lh.vol = Out_lh;
Path = strcat(FS, '/dti/Matrix/lh.white_parcellate.mgz');
MRIwrite(Mask_lh, Path);
% Mask_rh.vol = inv_rotate_to_surf(Out_rh);
Mask_rh.vol = Out_rh;
Path = strcat(FS, '/dti/Matrix/rh.white_parcellate.mgz');
MRIwrite(Mask_rh, Path);