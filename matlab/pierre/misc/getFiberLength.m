function fiber_length = getFiberLength(coordinates)
%
% usage : FIBER_LENGTH = getFiberLength(COORDINATES)
%
%   Input :
%        COORDINATES     : N x 3 coordinates table
%
%   Output :
%        FIBER_LENGTH    : fiber length
%
%	See also f_readFiber_vtk_bin, f_readFiber_tck, FTRtoTracts
%
% Pierre Besson @ CHRU Lille, June 2011

if nargin ~= 1
    error('invalid usage');
end

coordinates = coordinates - circshift(coordinates, -1);
coordinates = sqrt(sum(coordinates.^2, 2));

fiber_length = sum(coordinates(1:end-1));