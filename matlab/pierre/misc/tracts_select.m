function Fib = tracts_select(tract, mask)
% usage : FIB = tracts_select(TRACT, MASK)
%
% INPUT :
% -------
%    TRACT   : Fibers structure as obtained with f_readFiber_vtk
%
%    MASK    : Bin mask in NIFTI format.
%
% OUTPUT :
% --------
%    FIB     : Returns all fibbers intersecting the mask
%
% Pierre Besson, July 2009

if nargin ~= 2
   error('Invalid usage');
end

Fib = tract;

Mask = load_nifti(mask);
matrixdim = size(Mask.vol);
voxdim = diag(Mask.vox2ras(1:3,1:3))';
nCells = tract.nFiberNr;
Discard = zeros(nCells, 1);

for idx = 1 : nCells
    xyz = round([tract.fiber(idx).xyzFiberCoord(:,1) ./  voxdim(1) + 1, tract.fiber(idx).xyzFiberCoord(:,2) ./  voxdim(2) + 1, tract.fiber(idx).xyzFiberCoord(:,3) ./  voxdim(3) + 1,]);
    Discard(idx) = sum( Mask.vol(xyz(:, 1) + matrixdim(2).*(xyz(:, 2) - ones(length(xyz), 1)) + (matrixdim(2).*matrixdim(1)) .* (xyz(:, 3) - ones(length(xyz), 1) )));
    % Discard(idx) = Mask.vol(xyz(1, 1) + matrixdim(2).*(xyz(1, 2) - 1) + (matrixdim(2).*matrixdim(1)) .* (xyz(1, 3) - 1 ));
    % Discard(idx) = Mask.vol(xyz(end, 1) + matrixdim(2).*(xyz(end, 2) - 1) + (matrixdim(2).*matrixdim(1)) .* (xyz(end, 3) - 1 )) + Discard(idx);
end

Fib.fiber(Discard==0) = [];
Fib.nFiberNr          = nCells - sum(Discard==0);