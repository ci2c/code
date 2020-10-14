function [X, Y, Z] = coord1Dto3D(N, nx, ny, nz)
% usage : [X, Y, Z] = coord1Dto3D(N, nx, ny, nz)
%
% Converts 1D index to 3D coordinates
%
% Inputs : 
%    N         : index number
%    nx        : x table size
%    ny        : y table size
%    nz        : z table size
%
% Outputs :
%   X Y Z      : 3D coordinates in the table

if nargin ~= 4
    error('invalid usage');
end

Z = ceil(N ./ (nx*ny));
T = mod(N, nx*ny);
T(T==0) = nx*ny;
Y = ceil(T ./ nx);
X = N - nx*ny*(Z-1) - nx*(Y-1);