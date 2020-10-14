function [f] = f_readFiber(filename)
%
% function [f] = f_readFiber(filename)
%
%   This program will read in a "Fiber.dat" file created
%   within DTIStudio.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fp=fopen(filename, 'rb', 'l');

f.fiberfiletag = char(fread(fp, 8, 'char'));
f.nFiberNr = fread(fp, 1, 'uint32');
f.nReserved = fread(fp, 1, 'uint32');
f.fReserved = fread(fp, 1, 'float');

% image dimenson
f.nImgWidth = fread(fp, 1, 'uint32');
f.nImgHeight = fread(fp, 1, 'uint32');
f.nImgSlices = fread(fp, 1, 'uint32');

% voxel size
f.fPixelSizeWidth = fread(fp, 1, 'float');
f.fPixelSizeHeight = fread(fp, 1, 'float');
f.fSliceThickness = fread(fp, 1, 'float');

% 0=coronal, 1=axial, >2=sagittal
f.cSliceOrientation = fread(fp, 1, 'char');

% 0=normal, 1=flipped
f.cSliceSequencing = fread(fp, 1, 'char');


fseek(fp, 128, 'bof');

% Preallocate 
f.fiber(1).nFiberLength = 0;
f.fiber(1).rgbFiberColor = [];
f.fiber(1).nSelectFiberStartPoint = 0;
f.fiber(1).nSelectFiberEndPoint = 0;
f.fiber(1).xyzFiberCoord = single(zeros(3, 50));
f.fiber(f.nFiberNr).nFiberLength = 0;

for ii=1:f.nFiberNr
	%fiber data (offset 128)
	%each fiber is stored in following way:
	%int                  nFiberLength;	// fiber length
	f.fiber(ii).nFiberLength = fread(fp, 1, 'uint32');

	%unsigned char  cReserved;
	f.fiber(ii).cReserved = fread(fp, 1, 'char');

	%RGB_TRIPLE    rgbFiberColor;    // R-G-B, 3 bytes totally
	f.fiber(ii).rgbFiberColor = fread(fp, 3, 'uint8');

	%int                  nSelectFiberStartPoint;
	f.fiber(ii).nSelectFiberStartPoint = fread(fp, 1, 'uint32');

	%int                  nSelectFiberEndPoint;
	f.fiber(ii).nSelectFiberEndPoint = fread(fp, 1, 'uint32');

	% XYZ_TRIPLE    xyzFiberCoordinate[nFiberLength]; //x-y-x, 3 float data
	f.fiber(ii).xyzFiberCoord = fread(fp, [3 f.fiber(ii).nFiberLength], 'float=>float')';

end

fclose(fp);
