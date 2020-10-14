function BOOLEAN = check_cross_surface2(Line, Surf, IDs, Is_consecutive, Is_fiberEnd)
% 
% function BOOLEAN = check_cross_surface2(line, Surf, IDs, Is_consecutive, Is_fiberEnd)
%
% Inputs :
%      Line          : N x 3 3D coordinates of one fiber
%                         (i.e. Fib.fiber(k).xyzFiberCoord)
%      Surf          : triangulated surface
%      IDs           : Fiber IDs
%
% Output :
%       BOOLEAN      : returns boolean vector ; 1 if the fiber actually crosses the surface
% 
% Pierre Besson @ CHRU Lille, december 2010

if nargin ~= 5
    error('invalid usage');
end

BOOLEAN = raySurfaceIntersection2(Line, Surf.coord(:, Surf.tri(:, 1))', Surf.coord(:, Surf.tri(:, 2))', Surf.coord(:, Surf.tri(:, 3))', IDs, Is_consecutive, Is_fiberEnd) ~= 0;