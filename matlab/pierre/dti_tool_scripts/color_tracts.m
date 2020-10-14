function tract_out = color_tracts(tract_in)
% usage : TRACT_OUT = color_tracts(TRACT_IN)
% 
% Input :
%        TRACT_IN       : raw colorless tracts
%
% Output :
%        TRACT_OUT      : colored tracts
%
% Pierre Besson @ CHRU Lille, May 2011
%
% see also SAVE_SURFACE_VTK, SAVE_TRACT_VTK

if nargin ~= 1
    error('invalid usage');
end

tract_out = tract_in;

lengths = double(cat(1, tract_in.fiber.nFiberLength));
lengths = [0; cumsum(lengths)];

% Calculate colors
XYZ = cat(1, tract_in.fiber.xyzFiberCoord);
directions = XYZ - circshift(XYZ, -1);
norm_directions = sqrt(directions(:,1) .* directions(:,1) + directions(:,2) .* directions(:,2) + directions(:,3) .* directions(:,3));
norm_directions = repmat(norm_directions, 1, 3);
directions = directions ./ norm_directions;

RGB = round(255 * directions);

RGB(lengths(2:end), :) = RGB(lengths(2:end)-1, :);

% Loop to reconstruct fibers
for i = 1 : tract_in.nFiberNr
    tract_out.fiber(i).rgbPointColor = abs(RGB(lengths(i)+1 : lengths(i+1), :));
    whole_fiber_direction = tract_out.fiber(i).xyzFiberCoord(end, :) - tract_out.fiber(i).xyzFiberCoord(1, :);
    whole_fiber_norm = sqrt(whole_fiber_direction(1, 1) .* whole_fiber_direction(1, 1) + whole_fiber_direction(1, 2) .* whole_fiber_direction(1, 2) + whole_fiber_direction(1, 3) .* whole_fiber_direction(1, 3));
    whole_fiber_norm = repmat(whole_fiber_norm, 1, 3);
    whole_fiber_direction = whole_fiber_direction ./ whole_fiber_norm;
    tract_out.fiber(i).rgbFiberColor = abs(round(255 * whole_fiber_direction));
end