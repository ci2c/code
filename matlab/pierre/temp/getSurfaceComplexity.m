function Comp = getSurfaceComplexity(Surf, Radius)
% usage : COMPLEXITY = getSurfaceComplexity(SURF, RADIUS)
%
% Inputs :
%    SURF   : Cortical surface as provided by SurfStatReadSurf
%    R      : Sphere radius [mm]
%
% Pierre Besson @ CHRU Lille, Feb. 2011

if nargin ~= 2
    error('invalid usage');
end

Nvert = size(Surf.coord, 2);
Disk_area = pi .* Radius.^2;
Comp = zeros(Nvert, 1);

% Compute area of all triangles
X = Surf.coord(1,:);
Y = Surf.coord(2,:);
Z = Surf.coord(3,:);

X = X(Surf.tri);
Y = Y(Surf.tri);
Z = Z(Surf.tri);

Xab = (X(:,2) - X(:,1));
Xac = (X(:,3) - X(:,1));
Yab = (Y(:,2) - Y(:,1));
Yac = (Y(:,3) - Y(:,1));
Zab = (Z(:,2) - Z(:,1));
Zac = (Z(:,3) - Z(:,1));
N = cross([Xab Yab Zab], [Xac Yac Zac]);
A = 0.5 .* sqrt(N(:, 1).^2 + N(:, 2).^2 + N(:, 3).^2) ./ Disk_area;


disp(' ');
disp('Processing...');
Coord = Surf.coord;
Tri = Surf.tri;
for i = 1 : Nvert
    Coord_i = repmat(Coord(:, i), 1, Nvert);
    Dist_i = Coord - Coord_i;
    Dist_i = double(sqrt(Dist_i(1, :).^2 + Dist_i(2, :).^2 + Dist_i(3, :).^2) <= Radius)';
    Dist_i_inner = sum(Dist_i(Tri), 2) > 2;
    Dist_i_outer = sum(Dist_i(Tri), 2) > 0;
    Dist_i_mid = sum(Dist_i(Tri), 2) > 1;
    Comp(i) = (sum(A(Dist_i_inner)) + sum(A(Dist_i_outer)) + sum(A(Dist_i_mid))) ./ 3;
    if mod(i, 5000)==0
        disp([num2str(100*i./Nvert) ' %']);
    end
end

disp('Done.');