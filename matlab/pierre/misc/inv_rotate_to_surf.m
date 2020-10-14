function vol = inv_rotate_to_surf(invol)
%function vol = inv_rotate_to_surf(invol)

% vol = flipdim(invol, 2);
% vol = flipdim(vol, 1);
% vol = permute(vol, [3 2 1]);

vol = permute(invol, [3 2 1]);
vol = flipdim(vol, 1);
vol = flipdim(vol, 2);