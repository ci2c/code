function BOOLEAN = check_cross_surface(Line, Surf)
% 
% function BOOLEAN = check_cross_surface(line, Surf)
%
% Inputs :
%      Line          : N x 3 3D coordinates of one fiber
%                         (i.e. Fib.fiber(k).xyzFiberCoord)
%      Surf          : triangulated surface
%
% Output :
%       BOOLEAN      : returns 1 if the fiber actually crosses the surface
% 
% Pierre Besson @ CHRU Lille, december 2010

if nargin ~= 2
    error('invalid usage');
end

BOOLEAN = raySurfaceIntersection(Line, Surf.coord(:, Surf.tri(:, 1))', Surf.coord(:, Surf.tri(:, 2))', Surf.coord(:, Surf.tri(:, 3))') ~= 0;