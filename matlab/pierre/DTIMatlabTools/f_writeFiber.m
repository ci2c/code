function f_writeFiber(f)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This program will write in a "Fiber.dat" file created
%   within DTIStudio.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fp=fopen('WriteFiber.dat', 'wb', 'l');


% WRITE HEADER

fwrite(fp,f.fiberfiletag,'char');%write fiberfiletage

fwrite(fp,f.nFiberNr,'uint32'); % write nFiberNr

fwrite(fp,f.nReserved,'uint32'); % write nReserved

fwrite(fp,f.fReserved,'float');% write fReserved


% Write image dimension
fwrite(fp,f.nImgWidth, 'uint32'); %Width
fwrite(fp,f.nImgHeight, 'uint32'); %Height
fwrite(fp,f.nImgSlices, 'uint32'); % Slices

% Write Voxel size
fwrite(fp,f.fPixelSizeWidth, 'float'); %Width
fwrite(fp,f.fPixelSizeHeight, 'float'); %Height
fwrite(fp,f.fSliceThickness, 'float'); % Slices

fwrite(fp, f.cSliceOrientation, 'char'); % write  cSliceOrientation(0=coronal, 1=axial, >2=sagittal)
fwrite(fp, f.cSliceSequencing, 'char'); % write  cSliceSequencing;   // 0=normal, 1=flipped

%%%% to fill in zeros for 128 offset of fiber data writing // 46+82=128 bytes
fwrite(fp,[0], 'int16'); % 2 bytes
fwrite(fp,[0,0,0,0,0,0,0,0,0,0],'double'); % 80 bytes
%%%%


% write fibers
for ii=1: f.nFiberNr
    fwrite(fp, f.fiber(ii).nFiberLength, 'uint32');
    fwrite(fp,f.fiber(ii).cReserved,'char');
    %fwrite(fp, f.fiber(ii).rgbFiberColor, 'uint8');
    fwrite(fp, [255,0,0], 'uint8');
    fwrite(fp, f.fiber(ii).nSelectFiberStartPoint, 'uint32');
    fwrite(fp, f.fiber(ii).nSelectFiberEndPoint, 'uint32');
    fwrite(fp, (f.fiber(ii).xyzFiberCoord)', 'float');
end

fclose(fp);


