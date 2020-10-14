function [tracts, selected] = select_fibers_triangle(tri, tracts, thre, xyzFibers, ids)
% 
% function [tracts_out, selected] = select_fibers_triangle(tri, tracts, [thre, XYZ, ids])
%
% Inputs :
%      tri           : surface structre of a single triangle as returned by
%                        extract_triangle
%      tracts        : tracts structure as provided by f_readFiber*
%
% Options :
%      thre          : distance threshold (default : 0.3)
%      XYZ           : fibers coordinates (must be provided with ids)
%      ids           : fibers ids (must be provided with XYZ)
%
% Output :
%       tracts_out   : fiber structure intersecting the triangle
%       selected     : vector of selected fibers id
% 
% Pierre Besson @ CHRU Lille, Feb. 2013

if nargin ~= 2 && nargin ~= 3 && nargin ~= 5
    error('invalid usage');
end

if nargin < 3
    thre = 0.5;
end

if nargin < 4
    ids = cat(1, tracts.fiber.id);
    xyzFibers = cat(1, tracts.fiber.xyzFiberCoord);
end
    
Coords = tri.coord;
aa = sum(Coords.*Coords,1);
orig_nfibers = tracts.nFiberNr;

%% Determine the box coordinates around Coord
c_a = sqrt( sum((tri.coord(:,2) - tri.coord(:,1)) .^ 2) );
c_b = sqrt( sum((tri.coord(:,3) - tri.coord(:,1)) .^ 2) );
c_c = sqrt( sum((tri.coord(:,3) - tri.coord(:,2)) .^ 2) );
s_half = (c_a + c_b + c_c) / 2;
S_tri = sqrt( s_half * (s_half - c_a) * (s_half - c_b) * (s_half - c_c) );
Radius = single((c_a * c_b * c_c) ./ (4 * S_tri) + thre);
Center = single(mean(tri.coord, 2));
BOOL = ~logical(fast_dist_thresh_multi_single(xyzFibers, Center, Radius, ids, tracts.nFiberNr));
tracts.fiber(BOOL) = [];
tracts.nFiberNr = size(tracts.fiber, 2);
clear xyzFibers ids;

%% Keep fibers whose surf-fib distance < thre
XYZ = cat(1, tracts.fiber.xyzFiberCoord)';
ids = cat(1, tracts.fiber.id);
Is_consecutive = (1 : length(ids))';
fiberEnd = cat(1, tracts.fiber.nFiberLength);
fiberEnd = cumsum(single(fiberEnd));
Is_fiberEnd = zeros(length(ids), 1);
Is_fiberEnd(fiberEnd) = 1;
Is_fiberEnd = circshift(Is_fiberEnd + 2 .* circshift(Is_fiberEnd, 2), -1); % 1 for end of fibers ; 2 for starting point
clear fiberEnd;

% Loop on ids
To_discard = zeros(size(ids));
Unique_ids = unique(ids);
Index = 1 : 200 : length(Unique_ids);
for i = 1 : length(Index)-1
    Select = ismember(ids, Unique_ids(Index(i):(Index(i+1)-1)));
    xyz = XYZ(:, Select);
    bb = sum(xyz .* xyz, 1);
    ab = Coords' * xyz;
    Temp = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab)) < thre;
    D = sum(Temp ~= 0);
    To_discard(Select) = D==0;
end

% Last loop here (i=length(Index))
if ~isempty(Index)
    i = length(Index);
    Select = ismember(ids, Unique_ids(Index(i):end));
    xyz = XYZ(:, Select);
    bb = sum(xyz .* xyz, 1);
    ab = Coords' * xyz;
    Temp = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab)) < thre;
    D = sum(Temp ~= 0);
    To_discard(Select) = D==0;
end
%

XYZ(:, To_discard ~=0) = [];
ids(To_discard ~=0) = [];
Is_consecutive(To_discard ~= 0) = [];
Is_fiberEnd(To_discard ~= 0) = [];

%% Clear single points
uIds = unique(ids);
To_discard = zeros(size(ids));
for i = 1 : length(uIds)
    if sum(ids == uIds(i)) < 2
        To_discard(ids == uIds(i)) = 1;
    end
end
XYZ(:, To_discard ~=0) = [];
ids(To_discard ~=0) = [];
Is_consecutive(To_discard ~= 0) = [];
Is_fiberEnd(To_discard ~= 0) = [];

%% Check if fibers cross triangles
uIds = unique(ids);
Is_crossing = zeros(size(uIds));
Index = 1 : 5 : length(uIds);
for i = 1 : length(Index)-1
    Select = ismember(ids, uIds(Index(i) : Index(i+1)-1));
    Is_crossing(Index(i) : Index(i+1)-1) = raySurfaceIntersection2(XYZ(:, Select == 1)', tri.coord(:, tri.tri(:, 1))', tri.coord(:, tri.tri(:, 2))', tri.coord(:, tri.tri(:, 3))', ids(Select==1), Is_consecutive(Select==1), Is_fiberEnd(Select==1));
end

% Last loop here
if ~isempty(Index)
    i=length(Index);
    Select = ismember(ids, uIds(Index(i) : end));
    Is_crossing(Index(i) : end) = raySurfaceIntersection2(XYZ(:, Select == 1)', tri.coord(:, tri.tri(:, 1))', tri.coord(:, tri.tri(:, 2))', tri.coord(:, tri.tri(:, 3))', ids(Select==1), Is_consecutive(Select==1), Is_fiberEnd(Select==1));
end

%% Output data
Is_crossing = ismember(unique(cat(1, tracts.fiber.id)), uIds(Is_crossing~=0));
tracts.fiber(Is_crossing==0) = [];
tracts.nFiberNr = size(tracts.fiber, 2);
selected = zeros(orig_nfibers, 1);
selected(unique(cat(1, tracts.fiber.id))) = 1;