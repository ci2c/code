function save_volume_vtk(vol,fname,fileType,dims,origin)
% function save_volume_vtk(vol,fname,fileType,dims,origin)
% 
% Save a 3D matrix in vtk format, binary or ascii.
%
% vol       : a 3D matrix
% fname     : File name .vtk
% dims      : Voxel dimensions in mm. Default = [1 1 1]
% origin    : Origin of the volume. Default = [1 1 1]
%
% Luis Concha. Noel lab. BIC, MNI. September, 2008
%
% see also SAVE_SURFACE_VTK, SAVE_TRACT_VTK

vol(isnan(vol)) = 0;
vol = permute(vol,[2 1 3]);


if nargin < 3
  fileType = 'BINARY';
  origin = [1 1 1];
  dims = [1 1 1];
elseif nargin < 4
  origin = [1 1 1];
  dims = [1 1 1];
elseif nargin < 5
  origin = [1 1 1];
end

if ~strcmp(fileType,'BINARY') & ~strcmp(fileType,'ASCII')
   error('Invalid file type (ASCII or BINARY only)');
   return
end


nPoints = numel(vol);
if ~isinteger(vol(1));
    dataFormat = 'float';
    formatStr  = '%f';
else
    dataFormat = 'short';
    formatStr  = '%d';
end
    

fid = fopen(fname,'w');
fprintf(fid,'%s\n','# vtk DataFile Version 3.0');
fprintf(fid,'%s\n','volume');
fprintf(fid,'%s\n',fileType);
fprintf(fid,'%s\n','DATASET STRUCTURED_POINTS');
fprintf(fid,'%s %d %d %d\n','DIMENSIONS',size(vol,1),size(vol,2),size(vol,3));
fprintf(fid,'%s %f %f %f\n','ORIGIN',origin(1),origin(2),origin(3));
fprintf(fid,'%s %d %d %d\n','SPACING',dims(1),dims(2),dims(3));
fprintf(fid,'%s %d\n','POINT_DATA',numel(vol));
fprintf(fid,'%s %s %d\n','SCALARS volume_scalars',dataFormat,1);
fprintf(fid,'%s\n','LOOKUP_TABLE default');
if strcmp(fileType,'BINARY')
   fwrite(fid,vol,dataFormat,'ieee-be');

else
   if ~isinteger(vol(1));
       fprintf(fid,'%d\n',vol);
   else
       fprintf(fid,'%f\n',vol);
   end   
end



fclose(fid);
