function tracts = f_readFiber_vtk(fname,voxdim,matrixdim)
% 
% function tracts = f_readFiber_vtk(fname,voxdim,matrixdim)
%
% tracts    : A structure similar to that created by f_readFiber, which I use
%             to load DTIstudio .dat files.
% fname     : Path to the vtk file.
% voxdim    : [x y z] Voxel dimensions in mm.
% matrixdim : [read phase slice] Volume dimensions in voxels.
%
% The resulting tract can be visualized with 
% H = tracTubes_DTIstudio_selection(tracts,index,'random',0,0,'-x');
%
%
% 
% Luis Concha. BIC. April, 2008.
% Pierre Besson @ CHRU. December, 2010.

if nargin < 1 | nargin > 3
    error('invalid usage');
end

if nargin == 1
    voxdim = [2 2 2];
    matrixdim = [128 128 60];
end

if nargin == 2
    matrixdim = [128 128 60];
end    


% Prepare the output 
tracts.nImgWidth        = matrixdim(1);
tracts.nImgHeight       = matrixdim(2);
tracts.nImgSlices       = matrixdim(3);
tracts.fPixelSizeWidth  = voxdim(1);
tracts.fPixelSizeHeight = voxdim(2);
tracts.fSliceThickness  = voxdim(3);



fid = fopen(fname,'r');

% Check the first five lines for header information
lineNum = 1;
for lineNum = 1 : 5
   tline = fgetl(fid);
    if ~ischar(tline),   break,   end
    if regexpi(tline,'POINTS\s(.*)\s'); 
       nPoints = regexpi(tline,'POINTS\s(.*)\s','tokens');
       nPoints = cell2mat(nPoints{:});
       nPoints = str2num(nPoints);
    end
   
   lineNum = lineNum+1;
end


% Obtain the xyz coordinates of all the points
disp('Getting tract coordinates');
xyz = textscan(fid,'%f %f %f','Delimiter',' ');
XYZ = [xyz{1} xyz{2} xyz{3}];

% Next line in the .vtk file is the number of lines in the set
tline = fgetl(fid);
nLines = regexpi(tline,'LINES\s(.*)\s\d*','tokens');
nLines = cell2mat(nLines{:});
nLines = str2num(nLines);


% Now load the line indices. 
disp('Loading line indices');
fIdx = 1;
line_indices = textscan(fid,'%s',nLines,'delimiter','\n');

% Added PB
% Load color data
disp('Loading Cell color data');
blank = fgetl(fid);
tline = fgetl(fid);
nCData = regexpi(tline, 'CELL_DATA\s(\d*)', 'tokens');
nCData = cell2mat(nCData{:});
nCData = str2num(nCData);
tline = fgetl(fid);
nScalar = regexpi(tline, 'COLOR_SCALARS scalars\s(\d*)', 'tokens');
nScalar = cell2mat(nScalar{:});
nScalar = str2num(nScalar);
% disp(['There are ' num2str(nCData) ' POINT DATA and ' num2str(nScalar) ' COLOR SCALARS']);
CellColor = textscan(fid, '%f ', 'Delimiter', ' ');
CellColor = CellColor{1}(:);
CellColor = reshape(CellColor, nScalar, nCData)';

disp('Loading Point color data');
tline = fgetl(fid);
nPData = regexpi(tline, 'POINT_DATA\s(\d*)', 'tokens');
nPData = cell2mat(nPData{:});
nPData = str2num(nPData);
tline = fgetl(fid);
nScalar = regexpi(tline, 'COLOR_SCALARS scalars\s(\d*)', 'tokens');
nScalar = cell2mat(nScalar{:});
nScalar = str2num(nScalar);
PointColor = textscan(fid, '%f', 'Delimiter', ' ');
PointColor = PointColor{1}(:);
PointColor = reshape(PointColor, nScalar, nPData)';

%
progress('init', 'textbar', 'Organizing data...'); 

%%%% pre allocate some memory
    tracts.fiber(nLines).xyzFiberCoord = NaN;
    tracts.fiber(nLines).nFiberLength  = NaN;
    tracts.fiber(nLines).rgbFiberColor = rand(1,3);
    tracts.fiber(nLines).rgbPointColor = rand(1,3);
    tracts.fiber(nLines).nSelectFiberStartPoint = 0;
    tracts.fiber(nLines).nSelectFiberEndPoint = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for fIdx = 1 : length(line_indices{1})
    try
        progress(fIdx./nLines);
        idxs = str2num(cell2mat(line_indices{1}(fIdx)));
        idxs = idxs +1;  % add the matlab offset
        idxs(1) = [];               % the first number is the number of vertices, not an index


        % Populate the tracts structure with this line indices, using the
        % xyz coordinates of the corresponding points.
        tracts.fiber(fIdx).xyzFiberCoord = XYZ(idxs,:);
        tracts.fiber(fIdx).nFiberLength  = length(idxs);
        tracts.fiber(fIdx).rgbFiberColor = CellColor(fIdx, :);
        tracts.fiber(fIdx).rgbPointColor = PointColor(idxs,:);
        tracts.fiber(fIdx).nSelectFiberStartPoint = 0;
        tracts.fiber(fIdx).nSelectFiberEndPoint = length(idxs)-1;
    catch
        disp('Pause');
    end
    
    
end


fclose(fid);

% Last thing to add to the structure...
tracts.nFiberNr = length(tracts.fiber);
fprintf(1,'\n %s has %d lines and %d points in total\n\n', fname, nLines, nPoints);





