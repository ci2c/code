function tracts = f_readFiber_vtk_bin_mask(filename,mask)
%
% function tracts = f_readFiber_vtk_bin_table(filename,matrixdim,voxdim, mask)
%
% filename : A vtk polydata file, with any extension (i.e. vtk or fib). So
%            far it has been tested successfully with MedINRIA .fib files,
%            files written by ParaView and .vtk files written by
%            MincFibreTrack.
%
% mask : A NIFTI file containing binary mask for fiber selection
%
%	See also tracTubes_DTIstudio_selection, f_readFiber
%
% Luis Concha, BIC. June, 2008.
% Edited by Pierre Besson July 2009.

% Debug
dbstop if error

fid = fopen(filename,'r');
[fname, mode, mformat] = fopen(fid);


% if nargin < 3
%    matrixdim = [128 128 54];
%    voxdim    = [2.5 2.5 2.5];
% end

Mask = load_nifti(mask);
matrixdim = size(Mask.vol);
voxdim = diag(Mask.vox2ras(1:3,1:3))';

% Obtain header info, which is in ASCII
while 1 
   tline = fgetl(fid);
   disp(tline)
   if regexpi(tline,'POINTS')
      matches = regexpi(tline,'POINTS\s(\d*)\s(.*)','tokens'); 
      nPoints = str2num(matches{1}{1});
      type    = matches{1}{2};
      break
   end
end

% Get the points, notice the big-endiannes.
point_data   = single(fread(fid,nPoints.*3,[type '=>single'],'ieee-be')); % big endian!
point_data   = reshape(point_data,3,nPoints)';
blank        = fgetl(fid);
keyword      = fgetl(fid);  % Here's where vtk stores the number of lines that exist; it's in ASCII
matches      = regexpi(keyword,'LINES\s(\d*)\s(\d*)','tokens');
      nCells = str2num(matches{1}{1});
      nSize  = str2num(matches{1}{2});
disp(['There are ' num2str(nCells) ' cells.'])
cell_data    = fread(fid,nSize,'int','ieee-be'); % this one is big endian!

fclose(fid);


% pre allocate some memory
disp('Allocating memory');
tracts.fiber(nCells).xyzFiberCoord          = NaN;
tracts.fiber(nCells).nFiberLength           = NaN;
tracts.fiber(nCells).rgbFiberColor          = rand(1,3);
tracts.fiber(nCells).nSelectFiberStartPoint = 0;
tracts.fiber(nCells).nSelectFiberEndPoint   = NaN;

    
% Organize the points corresponding to each line.    
idx = 0;
pos = 1;
offset = 0;
Discard = zeros(nCells, 1);
while 1
    idx = idx+1;
    if idx > nCells, break, end;
    nV        = cell_data(pos);
    start     = pos + 1;
    stop      = pos + nV;
    try
        fIdxs = cell_data(start:stop);
    catch
        disp('error');
        disp([idx nV start stop]);
        continue
    end
    pos       = stop +1;
    
    fIdxs     = fIdxs +1;  % add the matlab offset
    
    
    % Populate the tracts structure with this line indices, using the
    % xyz coordinates of the corresponding points.
    tracts.fiber(idx).xyzFiberCoord          = point_data(fIdxs,:);
    tracts.fiber(idx).nFiberLength           = length(fIdxs);
    tracts.fiber(idx).rgbFiberColor          = rand(1,3);
    tracts.fiber(idx).nSelectFiberStartPoint = 0;
    tracts.fiber(idx).nSelectFiberEndPoint   = length(fIdxs)-1;
    
    xyz = point_data(fIdxs,:);
    xyz = round([xyz(:,1)./ voxdim(1) + 1, xyz(:,2)./ voxdim(2) + 1, xyz(:,3)./ voxdim(3) + 1]);
    Discard(idx) = sum( Mask.vol(xyz(:, 1) + matrixdim(2).*(xyz(:, 2) - ones(length(xyz), 1)) + (matrixdim(2).*matrixdim(1)) .* (xyz(:, 3) - ones(length(xyz), 1) )));
    % Discard(idx) = Mask.vol(xyz(1, 1) + matrixdim(2).*(xyz(1, 2) - 1) + (matrixdim(2).*matrixdim(1)) .* (xyz(1, 3) - 1 ));
    % Discard(idx) = Mask.vol(xyz(end, 1) + matrixdim(2).*(xyz(end, 2) - 1) + (matrixdim(2).*matrixdim(1)) .* (xyz(end, 3) - 1 )) + Discard(idx);
end

% Removing fibers
tracts.fiber(Discard==0) = [];

% Finish up by completing the rest of the tract information.
tracts.nImgWidth        = matrixdim(1);
tracts.nImgHeight       = matrixdim(2);
tracts.nImgSlices       = matrixdim(3);
tracts.fPixelSizeWidth  = voxdim(1);
tracts.fPixelSizeHeight = voxdim(2);
tracts.fSliceThickness  = voxdim(3);
tracts.nFiberNr         = nCells - sum(Discard==0);

disp(['Finished loading ' filename]);