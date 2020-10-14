function [tracts, selected] = select_fibers_fast2(Surf, tracts, label, thre, xyzFibers, ids)
% 
% function [tracts_out, selected] = select_fibers_fast2_gpu(Surf, tracts, label, [thre, XYZ, ids])
%
% Inputs :
%      Surf          : surface structre as returned by SurfStatReadSurf
%      tracts        : tracts structure as provided by f_readFiber*
%      label         : vector of vertices of interest (binary)
%
% Options :
%      thre          : distance threshold (default : 3)
%      XYZ           : fibers coordinates
%      ids           : fibers ids
%
% Output :
%       tracts_out   : fiber structure intersecting the label
%       selected     : vector of selected fibers id
% 
% Pierre Besson, 2010

if nargin ~= 3 && nargin ~= 4 && nargin ~= 5 && nargin ~= 6
    error('invalid usage');
end

if nargin < 4
    thre = 3;
end

Orig_ids = cat(1, tracts.fiber.id);
Surf_select = parcellation_select(Surf, label~=0);
Coords = Surf_select.coord;
clear Surf;
aa = sum(Coords.*Coords,1);

%% Determine the box coordinates around Coord
BOX = zeros(3, 2);
BOX(1,1) = min(Coords(1, :))-2;
BOX(1,2) = max(Coords(1, :))+2;
BOX(2,1) = min(Coords(2, :))-2;
BOX(2,2) = max(Coords(2, :))+2;
BOX(3,1) = min(Coords(3, :))-2;
BOX(3,2) = max(Coords(3, :))+2;

%% Keep fibers inside the box
if nargin < 5
xyzFibers = cat(1, tracts.fiber.xyzFiberCoord);
ids = cat(1, tracts.fiber.id);
else
    if nargin < 6
        ids = cat(1, tracts.fiber.id);
    end
end
BOOL = isin3Dbox(xyzFibers', BOX);
To_keep = ismember(unique(ids), unique(ids(BOOL)));
clear BOOL;
tracts.fiber(To_keep==0) = [];
tracts.nFiberNr = size(tracts.fiber, 2);
clear xyzFibers ids;

%% Keep fibers whose surf-fib distance < thre
XYZ = cat(1, tracts.fiber.xyzFiberCoord)';
ids = cat(1, tracts.fiber.id);
Is_consecutive = (1 : length(ids))';
fiberEnd = cat(1, tracts.fiber.nFiberLength);
fiberEnd = cumsum(fiberEnd);
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
    Is_crossing(Index(i) : Index(i+1)-1) = raySurfaceIntersection2(XYZ(:, Select == 1)', Surf_select.coord(:, Surf_select.tri(:, 1))', Surf_select.coord(:, Surf_select.tri(:, 2))', Surf_select.coord(:, Surf_select.tri(:, 3))', ids(Select==1), Is_consecutive(Select==1), Is_fiberEnd(Select==1));
end

% Last loop here
if ~isempty(Index)
    i=length(Index);
    Select = ismember(ids, uIds(Index(i) : end));
    Is_crossing(Index(i) : end) = raySurfaceIntersection2(XYZ(:, Select == 1)', Surf_select.coord(:, Surf_select.tri(:, 1))', Surf_select.coord(:, Surf_select.tri(:, 2))', Surf_select.coord(:, Surf_select.tri(:, 3))', ids(Select==1), Is_consecutive(Select==1), Is_fiberEnd(Select==1));
end

%% Output data
Is_crossing = ismember(unique(cat(1, tracts.fiber.id)), uIds(Is_crossing~=0));
tracts.fiber(Is_crossing==0) = [];
tracts.nFiberNr = size(tracts.fiber, 2);
selected = ismember(unique(Orig_ids), unique(cat(1, tracts.fiber.id)));