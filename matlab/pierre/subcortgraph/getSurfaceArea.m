function A = getSurfaceArea(Surf)
% usage : AREA = getSurfaceArea(SURF)
%
% Input :
%    SURF   : surface structure similar to those provided by
%              SurfStatReadSurf
%
% Output :
%    AREA   : surface area in mm^2
%
% Pierre Besson @ CHRU Lille, July 2011

if nargin ~= 1
    error('invalid usage');
end

X = Surf.coord(1,:);
Y = Surf.coord(2,:);
Z = Surf.coord(3,:);

X = X(Surf.tri);
Y = Y(Surf.tri);
Z = Z(Surf.tri);

Xab = (X(:,2) - X(:,1));
Xac = (X(:,3) - X(:,1));
Yab = (Y(:,2) - Y(:,2));
Yac = (Y(:,3) - Y(:,1));
Zab = (Z(:,2) - Z(:,1));
Zac = (Z(:,3) - Z(:,1));
N = cross([Xab Yab Zab], [Xac Yac Zac]);
A = 0.5 .* sqrt(N(:, 1).^2 + N(:, 2).^2 + N(:, 3).^2);

A = sum(A);