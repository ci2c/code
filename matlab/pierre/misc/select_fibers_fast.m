function [tracts, selected] = select_fibers_fast(Surf, tracts, label, thre)
% 
% function [tracts_out, selected] = select_fibers_fast(Surf, tracts, label, thre)
%
% Inputs :
%      Surf          : surface structre as returned by SurfStatReadSurf
%      tracts        : tracts structure as provided by f_readFiber*
%      label         : vector of vertices of interest (binary)
%      thre          : distance threshold (default : 0.8)
%
% Output :
%       tracts_out   : fiber structure intersecting the label
%       selected     : vector of selected fibers id
% 
% Pierre Besson, 2010

if nargin ~= 3 & nargin ~= 4
    error('invalid usage');
end

if nargin < 4
    thre = 0.8;
end

tracts_orig = tracts; % Just for debugging
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


Nfiber = size(tracts.fiber, 2);
Nfiber_original = Nfiber;
To_keep = zeros(Nfiber, 1);
xyzFibers = cat(1, tracts.fiber.xyzFiberCoord);
ids = cat(1, tracts.fiber.id);

%% Keep fibers inside the box
BOOL = isin3Dbox(xyzFibers', BOX);
To_keep = unique(ids(BOOL));
To_keep = ismember(unique(ids), To_keep);
clear BOOL;
tracts.fiber(To_keep==0) = [];
Nfiber = size(tracts.fiber, 2);
tracts.nFiberNr = Nfiber;
clear Temp Lkeep NFiber xyzFibers ids;
tracts_orig = tracts; % Just for debugging

%% Keep fibers whose surf-fib distance < thre
XYZ = cat(1, tracts.fiber.xyzFiberCoord)';
ids = cat(1, tracts.fiber.id);
% Loop on ids
To_discard = zeros(size(ids));
Unique_ids = unique(ids);
Index = 1 : 200 : length(Unique_ids);
% disp('Processing...');
% progress('init', 'Processing...');
parfor i = 1 : length(Index)
    try
        Select = ismember(ids, Unique_ids(Index(i):Index(i+1)));
    catch
        Select = ismember(ids, Unique_ids(Index(i):end));
    end
    xyz = XYZ(:, Select);
    bb = sum(xyz .* xyz, 1);
    ab = Coords' * xyz;
    %D = sum(sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab)) < thre);
    Temp = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));
    D = sum(Temp < thre);
    To_discard(Select) = D==0;
%     fprintf([num2str(round(100*i ./ length(Index))), '%% ']);
%     progress(i ./ length(Index), num2str(100*i ./ length(Index)));
end
% fprintf('\n');
% progress('close');
To_keep = unique(ids(To_discard==0));
To_keep = ismember(unique(ids), To_keep);
tracts.fiber(To_keep==0) = [];
Nfiber = size(tracts.fiber, 2);
tracts.nFiberNr = Nfiber;
tracts_orig = tracts;

%% Check if fibers cross triangles
% disp('Processing...');
% progress('init', 'Processing...');
To_discard = zeros(Nfiber, 1);
parfor i = 1 : Nfiber
    To_discard(i) = check_cross_surface(tracts.fiber(i).xyzFiberCoord, Surf_select)==0;
%     fprintf([num2str(round(100*i ./ Nfiber)), '%% ']);
%     progress(i ./ Nfiber, num2str(100*i ./ Nfiber));
end
% fprintf('\n');
% progress('close');

%% Output data
tracts.fiber(To_discard~=0) = [];
tracts.nFiberNr = size(tracts.fiber, 2);
selected = zeros(Nfiber_original, 1);
selected(unique(cat(1, tracts.fiber.id))) = 1;    