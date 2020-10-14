function data = loadRaw(fname,matrixX,matrixY,slices,fmt);
% data = loadRaw(fname,matrixX,matrixY,slices,fmt);
%
%   Reads a data set in raw format (3D) and creates a single variable with
%   size matrixX X matrixY x slices
%   fmt is the string for number format, and can be 'float', 'uint8' or
%   'uint16'.  
%        
%   for DTIstudio: raw images are uint16, maps are float (except for vectors)
%   not implemented for reading vector fields yet.
%
%   make sure that Left/Right, up/down are OK.  If not, use
%   permute(data,[order]) in before returning the function

fid = fopen(fname);
map = fread(fid,fmt);
fclose(fid);
map = transpose(map);                                  
map = reshape(map,matrixX,matrixY,slices);     
data = map;