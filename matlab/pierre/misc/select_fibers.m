function [tracts, selected] = select_fibers(Surf, tracts, label, thre)
% 
% function [tracts_out, selected] = select_fibers(Surf, tracts, label, thre)
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

Coords = Surf.coord(:, label~=0);
Surf_select = parcellation_select(Surf, label~=0);
aa = sum(Coords.*Coords,1);

% Determine the box coordinates around Coord
BOX = zeros(3, 2);
BOX(1,1) = min(Coords(1, :));
BOX(1,2) = max(Coords(1, :));
BOX(2,1) = min(Coords(2, :));
BOX(2,2) = max(Coords(2, :));
BOX(3,1) = min(Coords(3, :));
BOX(3,2) = max(Coords(3, :));


Nfiber = size(tracts.fiber, 2);
To_discard = ones(Nfiber, 1);

progress('init', 'Processing...');
for N = 1 : Nfiber
    % Check if at least one point of the fiber is inside the box
    FiberCoord = tracts.fiber(N).xyzFiberCoord';
    if isin3Dbox(FiberCoord, BOX)
        bb = sum(FiberCoord.*FiberCoord, 1);
        ab = Coords'*FiberCoord;
        D = sqrt(abs(repmat(aa',[1 size(bb,2)]) + repmat(bb,[size(aa,2) 1]) - 2*ab));
        if (min(D(:)) < thre)
            To_discard(N) = ~check_cross_surface(FiberCoord', Surf_select);
            progress(N ./ Nfiber, num2str(100*N./Nfiber));
            continue;
        end
    end  
end
progress('close');

tracts.fiber(To_discard~=0) = [];
tracts.nFiberNr = tracts.nFiberNr - sum(To_discard);
selected = To_discard~=0;