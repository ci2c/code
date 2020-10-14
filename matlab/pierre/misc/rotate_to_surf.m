function vol = rotate_to_surf(invol)
%function vol = rotate_to_surf(invol)

vol = flipdim(invol, 2);
vol = flipdim(vol, 1);
vol = permute(vol, [3 2 1]);