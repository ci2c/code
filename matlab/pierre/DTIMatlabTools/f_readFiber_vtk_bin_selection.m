function [allTracts,selectedTracts] = f_readFiber_vtk_bin_selection(filename,selections,matrixdim,voxdim)
%
% function [allTracts,selectedTracts] =
%                                       f_readFiber_vtk_bin_selection...
%                                       (filename,selectionFname,...
%                                       matrixdim,voxdim)
%
% filename      : A vtk polydata file, provided by MedINRIA.
% selectionFname: A second .fib file of tracts isolated in MedINRIA. These
%                 tracts must originate from the same "spaghetti bowl"
%                 specified by "filename", i.e. both files are provided by
%                 MedINRIA. Alternatively, this variable can be a cell
%                 array of file names.
% matrixdim     : The volume dimensions from where the fibers came from [X Y Z]. This is
%                 actually not used by this function, rather by the display
%                 function tracTubes_DTIstudio.m If not specified, the tracts
%                 will have default values of matrixdim = [128 128 54].
% voxdim        : The voxel dimensions [x y z]. Similarly to matrixdim, not used
%                 by the function itself. If not specified, the tracts
%                 will have default values of voxdim = [2.5 2.5 2.5].
%
% Outputs:
% 
% allTracts     : The spaghetti bowl of tracts.
% selectedTracts: A structure array of the selected tracts, containing the
%                 tract itself and the filename of the selection.
%
%	See also tracTubes_DTIstudio_selection, f_readFiber,
%	f_readFiber_vtk_bin
%
% Luis Concha, BIC. June, 2008.

fid = fopen(filename,'r');
[fname, mode, mformat] = fopen(fid);




if nargin<2
   disp('Please specify a tract-selection filename');
   return
end

if nargin < 4
   matrixdim = [128 128 54];
   voxdim    = [2.5 2.5 2.5];
end


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
    
    
end

% Finish up by completing the rest of the tract information.
tracts.nImgWidth        = matrixdim(1);
tracts.nImgHeight       = matrixdim(2);
tracts.nImgSlices       = matrixdim(3);
tracts.fPixelSizeWidth  = voxdim(1);
tracts.fPixelSizeHeight = voxdim(2);
tracts.fSliceThickness  = voxdim(3);
tracts.nFiberNr         = nCells;

disp(['Finished loading ' filename]);
allTracts      = tracts;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now we load the tract selection files. These files contain no xyz
% coordinates of the vertices, only the line indices. The coordinates are
% referred back to the big vtk file, the one we loaded above. 

% Find out if we're dealing with one selection file, or with many.
if iscell(selections)
    nSelections = length(selections);
elseif ischar(selections)
    nSelections = 1;
end

% For each file that selects tracts...
for s = 1 : nSelections
    if iscell(selections)
        selectionFname  = selections{s};
    else
        selectionFname  = selections;
    end

    fidSelect           = fopen(selectionFname,'r');

    while 1 
       tline = fgetl(fid);
       if regexpi(tline,'POINTS')
          matches       = regexpi(tline,'POINTS\s(\d*)\s(.*)','tokens'); 
          nPoints       = str2num(matches{1}{1});
          type          = matches{1}{2};
          break
       end
    end

    % There are no points to load.
    keyword             = fgetl(fid);  % Here's where vtk stores the number of lines that exist; it's in ASCII
    matches             = regexpi(keyword,'LINES\s(\d*)\s(\d*)','tokens');
          nCells_select = str2num(matches{1}{1});
          nSize_select  = str2num(matches{1}{2});
    disp(['There are ' num2str(nCells) ' cells in the selection file.'])
    cell_data_select    = fread(fid,nSize_select,'int','ieee-be'); % this one is big endian!
    fclose(fidSelect);


    % pre allocate some memory
    disp('Allocating memory');
    tracts2.fiber(nCells_select).xyzFiberCoord          = NaN;
    tracts2.fiber(nCells_select).nFiberLength           = NaN;
    tracts2.fiber(nCells_select).rgbFiberColor          = rand(1,3);
    tracts2.fiber(nCells_select).nSelectFiberStartPoint = 0;
    tracts2.fiber(nCells_select).nSelectFiberEndPoint   = NaN;


    % Organize the points corresponding to each line.The xyz coordinates correspond to the big file.    
    idx = 0;
    pos = 1;
    offset = 0;
    while 1
        idx = idx+1;
        if idx > nCells_select, break, end;
        nV        = cell_data_select(pos);
        start     = pos + 1;
        stop      = pos + nV;
        try
            fIdxs = cell_data_select(start:stop);
        catch
            disp('error');
            disp([idx nV start stop]);
            continue
        end
        pos       = stop +1;

        fIdxs     = fIdxs +1;  % add the matlab offset


        % Populate the tracts structure with this line indices, using the
        % xyz coordinates of the corresponding points.
        tracts2.fiber(idx).xyzFiberCoord          = point_data(fIdxs,:);
        tracts2.fiber(idx).nFiberLength           = length(fIdxs);
        tracts2.fiber(idx).rgbFiberColor          = rand(1,3);
        tracts2.fiber(idx).nSelectFiberStartPoint = 0;
        tracts2.fiber(idx).nSelectFiberEndPoint   = length(fIdxs)-1;


    end

    % Finish up by completing the rest of the tract information.
    tracts2.nImgWidth        = matrixdim(1);
    tracts2.nImgHeight       = matrixdim(2);
    tracts2.nImgSlices       = matrixdim(3);
    tracts2.fPixelSizeWidth  = voxdim(1);
    tracts2.fPixelSizeHeight = voxdim(2);
    tracts2.fSliceThickness  = voxdim(3);
    tracts2.nFiberNr         = nCells_select;

    % Return the selected tracts organized in a structure.
    selectedTracts(s).tracts = tracts2;
    selectedTracts(s).filename = selectionFname;
    disp(['Finished loading ' selectionFname]);

end % end of for loop of selections
disp('Finished loading all files');
