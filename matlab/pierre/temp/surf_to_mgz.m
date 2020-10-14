function surf = surf_to_mgz(insurf, mgz)
%function surf = surf_to_mgz(insurf, mgz)
%
%  insurf   : Path to surface or surface structure as given by SurfStatReadSurf
%  mgz      : Path to a .mgz image
%
% Pierre Besson @ CHR Lille, Oct 2013

if nargin ~= 2
    error('invalid usage');
end

mri = MRIread(mgz);

surf.tri   = insurf.tri;
surf.coord = insurf.coord;

% surf.coord(1,:) = surf.coord(1,:) - 128.5 + mri.c_r;
% surf.coord(2,:) = surf.coord(2,:) - 128.5 + mri.c_a;
% surf.coord(3,:) = surf.coord(3,:) - 128.5 + mri.c_s;

surf.coord(1,:) = surf.coord(1,:) + 128.5 + mri.c_r;
surf.coord(2,:) = surf.coord(2,:) + 128 + mri.c_a;
surf.coord(3,:) = surf.coord(3,:);