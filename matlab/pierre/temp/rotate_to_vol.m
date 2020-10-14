function surf = rotate_to_vol(insurf, mri)
%function surf = rotate_to_vol(insurf, mri)

% vol = permute(invol, [3 2 1]);
% vol = flipdim(vol, 1);
% vol = flipdim(vol, 2);

surf = insurf;

surf.coord(1,:) = surf.coord(1,:) - mri.c_r;
surf.coord(2,:) = surf.coord(2,:) - mri.c_a;
surf.coord(3,:) = surf.coord(3,:) + mri.c_s;