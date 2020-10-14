function [Matrix, Length, Areas] = connectome2matrix(Connectome)
% Usage : [MATRIX, LENGTH, AREAS] = connectome2matrix(CONNECTOME)
%
% Input :
%    CONNECTOME : Structure as returned by getSurfaceConnectMatrix
%
% Output :
%    MATRIX     : weighted connectivity matrix
%    LENGTH     : mean fiber bundles length
%    AREAS      : mean ROI pairwise area
%
% See also getSurfaceConnectMatrix
%
% Pierre Besson, 2010

if nargin ~= 1
    error('invalid usage');
end

if nargout ~=3
    error('invalid usage');
end

% Get unweighted connectivity matrix
Connections = double(cat(2, Connectome.region.selection));
Connections = Connections' * Connections;

% Construct areas weights matrix
Areas = cat(1, Connectome.region.area);
Areas = repmat(Areas, 1, length(Areas));
Areas = (Areas+Areas')./2;
nRoi = size(Areas, 1);

% Get fiber bundles mean length
Length = zeros(nRoi);
C = tril(Connections, -1);
[i,j] = find(C~=0);
All_length = cat(1, Connectome.fibers.fiber.nFiberLength);
for k = 1 : length(i)
    S_ij = Connectome.region(i(k)).selection .* Connectome.region(j(k)).selection;
    Length(i(k),j(k)) = mean(All_length(S_ij~=0));
end

Length = Length + Length';

Matrix = Connections ./ (Length + Areas);
Matrix(eye(nRoi)~=0) = 0;