function surf = surfcat(surf, surf2)
% usage : SURF_OUT = surfcat(SURF_IN, SURF_IN2)
% 
% Inputs :
%       SURF_IN   : first input surface as provided by SurfStatReadSurf
%       SURF_IN2  : input surface appended to SURF_IN
%
% Options :
%       SURF_OUT  : concatenation of SURF_in and SURF_IN2
%
% Pierre Besson @ CHRU Lille. July 2011.

if nargin ~= 2
    error('invalid usage');
end

surf2.tri = surf2.tri + length(surf.coord);

surf.tri = [surf.tri; surf2.tri];
surf.coord = [surf.coord, surf2.coord];