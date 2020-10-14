function tracts = FTRtoTracts(FTRmat)
%
% usage : TRACTS = FTRtoTracts(FTRmat)
%
%   Input :
%        FTRmat        : FTR matrix (i.e. '/path/to/yourData_FTR.mat')
%
%   Output :
%        TRACTS        : our standard tracts structure
%
%	See also f_readFiber_vtk_bin
%
% Pierre Besson @ CHRU Lille, May 2011

if nargin ~= 1
    error('invalid usage');
end

try
    eval(['load ', FTRmat]);
catch
    error('can not load FTRmat');
end

Nfibers = length(curveSegCell);

% Allocate memory
tracts.fiber(Nfibers).xyzFiberCoord          = NaN;
tracts.fiber(Nfibers).nFiberLength           = NaN;
tracts.fiber(Nfibers).rgbFiberColor          = rand(1,3);
tracts.fiber(Nfibers).rgbPointColor          = rand(1,3);
tracts.fiber(Nfibers).nSelectFiberStartPoint = 0;
tracts.fiber(Nfibers).nSelectFiberEndPoint   = NaN;
tracts.fiber(Nfibers).id                     = NaN;

% Fill structure
tracts.nImgWidth = NaN;
tracts.nImgHeight = NaN;
tracts.nImgSlices = NaN;
tracts.fPixelSizeWidth = vox(1);
tracts.fPixelSizeHeight = vox(2);
tracts.fSliceThickness = vox(3);
tracts.nFiberNr = Nfibers;

for i = 1 : Nfibers
    Coordinates = (hMatrix * [curveSegCell{i}-ones(size(curveSegCell{i}, 3)) ones(size(curveSegCell{i}, 1), 1)]')';
    % Coordinates = (hMatrix * [curveSegCell{i} ones(size(curveSegCell{i}, 1), 1)]')';
    % Try flipping Y
    Coordinates(:, 2) = -Coordinates(:, 2);
    %
    % Try flipping X
    Coordinates(:, 1) = -Coordinates(:, 1);
    %
    tracts.fiber(i).xyzFiberCoord = Coordinates(:, 1:3);
    tracts.fiber(i).nFiberLength = size(curveSegCell{i}, 1);
    tracts.fiber(i).nSelectFiberStartPoint = 0;
    tracts.fiber(i).nSelectFiberEndPoint = tracts.fiber(i).nFiberLength - 1;
    tracts.fiber(i).id = repmat(i, tracts.fiber(i).nFiberLength, 1);
    
    % Fill up with garbage values
    tracts.fiber(i).rgbPointColor = 255*ones(size(tracts.fiber(i).xyzFiberCoord));
    tracts.fiber(i).rgbFiberColor = 255*ones(1, 3);
end

% Check if there are fibers subsets
if ~isempty(fiber)
    Temp = tracts;
    tracts = [];
    tracts.all = Temp;
    for i = 1 : size(fiber, 1)
        fiberName = fiber{i}.name;
        tracts.(fiberName) = tracts.all;
        all_fibers = 1 : Nfibers;
        all_fibers(fiber{i}.curveID) = [];
        tracts.(fiberName).fiber(all_fibers) = [];
        tracts.(fiberName).nFiberNr = length(fiber{i}.curveID);
    end
end