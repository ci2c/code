function tracts = f_readFiber_vtk_bin(filename,matrixdim,voxdim)
%
% function f_readFiber_vtk_bin(filename,matrixdim,voxdim)
%
% filename  : A vtk polydata file, with any extension (i.e. vtk or fib). So
%             far it has been tested successfully with MedINRIA .fib files,
%             files written by ParaView and .vtk files written by
%             MincFibreTrack.
% matrixdim : The volume dimensions from where the fibers came from [X Y Z]. This is
%             actually not used by this function, rather by the display
%             function tracTubes_DTIstudio.m If not specified, the tracts
%             will have default values of matrixdim = [128 128 54].
% voxdim    : The voxel dimensions [x y z]. Similarly to matrixdim, not used
%             by the function itself. If not specified, the tracts
%             will have default values of voxdim = [2.5 2.5 2.5].
% matrixras : Vox2ras matrix
%
%	See also tracTubes_DTIstudio_selection, f_readFiber
%
% Luis Concha, BIC. June, 2008.
% Pierre Besson, CHR. Lille, 2010

fid = fopen(filename,'r');
[fname, mode, mformat] = fopen(fid);


if nargin < 3
   matrixdim = [128 128 60];
   voxdim    = [2 2 2];
end


% Obtain header info, which is in ASCII
while 1 
   tline = fgetl(fid);
   %disp(tline)
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
%disp(['There are ' num2str(nCells) ' cells.'])
cell_data    = fread(fid,nSize,'int','ieee-be'); % this one is big endian!

% Added PB
% Load cell color
blank       = fgetl(fid);
keyword     = fgetl(fid);
matches     = regexpi(keyword,'CELL_DATA\s(\d*)', 'tokens');
     nCData = str2num(matches{1}{1});
keyword     = fgetl(fid);
matches     = regexpi(keyword,'COLOR_SCALARS scalars\s(\d*)', 'tokens');
    nScalar = str2num(matches{1}{1});
%disp(['There are ' num2str(nCData) ' CELL DATA and ' num2str(nScalar) ' COLOR SCALARS']);
cell_color  = fread(fid, nCData.*nScalar);
cell_color  = reshape(cell_color, nScalar, nCData)';

% Load point color
blank       = fgetl(fid);
keyword     = fgetl(fid);
matches     = regexpi(keyword,'POINT_DATA\s(\d*)', 'tokens');
     nPData = str2num(matches{1}{1});
keyword     = fgetl(fid);
matches     = regexpi(keyword,'COLOR_SCALARS scalars\s(\d*)', 'tokens');
    nScalar = str2num(matches{1}{1});
%disp(['There are ' num2str(nPData) ' POINT DATA and ' num2str(nScalar) ' COLOR SCALARS']);
point_color  = fread(fid, nPData.*nScalar);
point_color  = reshape(point_color, nScalar, nPData)';

fclose(fid);


% pre allocate some memory
%disp('Allocating memory');
tracts.fiber(nCells).xyzFiberCoord          = NaN;
tracts.fiber(nCells).nFiberLength           = NaN;
tracts.fiber(nCells).rgbFiberColor          = rand(1,3);
tracts.fiber(nCells).rgbPointColor          = rand(1,3);
tracts.fiber(nCells).nSelectFiberStartPoint = 0;
tracts.fiber(nCells).nSelectFiberEndPoint   = NaN;
tracts.fiber(nCells).id                     = NaN;

    
% Organize the points corresponding to each line.    
idx = 0;
pos = 1;
offset = 0;
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
    tracts.fiber(idx).xyzFiberCoord          = point_data(fIdxs,:);  % Original
    tracts.fiber(idx).nFiberLength           = length(fIdxs);
    tracts.fiber(idx).rgbFiberColor          = cell_color(idx,:);
    tracts.fiber(idx).rgbPointColor          = point_color(fIdxs,:);
    tracts.fiber(idx).nSelectFiberStartPoint = 0;
    tracts.fiber(idx).nSelectFiberEndPoint   = length(fIdxs)-1;
    tracts.fiber(idx).id                     = idx * ones(length(fIdxs), 1);
    
    
end

% Finish up by completing the rest of the tract information.
tracts.nImgWidth        = matrixdim(1);
tracts.nImgHeight       = matrixdim(2);
tracts.nImgSlices       = matrixdim(3);
tracts.fPixelSizeWidth  = voxdim(1);
tracts.fPixelSizeHeight = voxdim(2);
tracts.fSliceThickness  = voxdim(3);
tracts.nFiberNr         = nCells;

%disp(['Finished loading ' filename]);