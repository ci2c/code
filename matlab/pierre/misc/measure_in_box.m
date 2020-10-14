function Vals = measure_in_box(Box, V)
% usage : VALUES = measure_in_box(BOX, V);
%
% INPUTS :
% -------
%    BOX               : Box coordinates as provided by spar_to_box
%    V                 : Image path or structure
%
% OUTPUT :
% --------
%    VALUES            : Vector of the values inside the box
%
% See also spar_to_box
%
% Pierre Besson @ CHRU Lille, Mar. 2012

if nargin ~= 2
    error('invalid usage');
end

if ischar(V)
    V = spm_vol(V);
end

[Y, XYZ] = spm_read_vols(V);

% get normals (outside orientation)
N1 = cross(Box(:,2)-Box(:,1), Box(:,3)-Box(:,1)); % Ref : Box(:,1)
N2 = cross(Box(:,1)-Box(:,5), Box(:,7)-Box(:,5)); % Ref : Box(:,5)
N3 = cross(Box(:,5)-Box(:,6), Box(:,8)-Box(:,6)); % Ref : Box(:,6)
N4 = cross(Box(:,6)-Box(:,2), Box(:,4)-Box(:,2)); % Ref : Box(:,2)
N5 = cross(Box(:,5)-Box(:,1), Box(:,2)-Box(:,1)); % Ref : Box(:,1)
N6 = cross(Box(:,4)-Box(:,3), Box(:,7)-Box(:,3)); % Ref : Box(:,3)

% repmats
N1 = repmat(N1, 1, size(XYZ, 2));
N2 = repmat(N2, 1, size(XYZ, 2));
N3 = repmat(N3, 1, size(XYZ, 2));
N4 = repmat(N4, 1, size(XYZ, 2));
N5 = repmat(N5, 1, size(XYZ, 2));
N6 = repmat(N6, 1, size(XYZ, 2));

R1 = repmat(Box(:,1), 1, size(XYZ, 2));
R2 = repmat(Box(:,5), 1, size(XYZ, 2));
R3 = repmat(Box(:,6), 1, size(XYZ, 2));
R4 = repmat(Box(:,2), 1, size(XYZ, 2));
R5 = repmat(Box(:,1), 1, size(XYZ, 2));
R6 = repmat(Box(:,3), 1, size(XYZ, 2));

% Select point wrt normals product
in_box = (double(dot(N1, XYZ-R1) < 0)) .* double((dot(N2, XYZ-R2) < 0)) .* double((dot(N3, XYZ-R3) < 0)) .* double((dot(N4, XYZ-R4) < 0)) .* double((dot(N5, XYZ-R5) < 0)) .* double((dot(N6, XYZ-R6) < 0));

% return values of Y within the box
Vals = Y(in_box(:)==1);