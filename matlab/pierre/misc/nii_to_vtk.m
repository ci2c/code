function nii_to_vtk(Im,fname,fileType)
% function nii_to_vtk(Image,fname,fileType)
% 
% Save a 3D nii in vtk format, binary or ascii.
%
% Image     : nii structure as created using load_nifti
% fname     : File name .vtk
%
% Luis Concha. Noel lab. BIC, MNI. September, 2008
% Edited Pierre Besson July 2009
%
% see also SAVE_SURFACE_VTK, SAVE_TRACT_VTK

Im.vol(isnan(Im.vol)) = 0;
%Im.vol = permute(Im.vol,[2 1 3]);


if nargin < 3
  fileType = 'BINARY';
end

% origin = Im.vox2ras(1:3, 4)';
origin = [0 0 0];
dims = diag(Im.vox2ras(1:3,1:3))';

% if nargin < 3
%  origin = [1 1 1];
%    dims = [1 1 1];
%  elseif nargin < 4
%    origin = [1 1 1];
%    dims = [1 1 1];
%  elseif nargin < 5
%    origin = [1 1 1];
% end

if ~strcmp(fileType,'BINARY') & ~strcmp(fileType,'ASCII')
   error('Invalid file type (ASCII or BINARY only)');
   return
end


nPoints = numel(Im.vol);
if ~isinteger(Im.vol(1));
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
fprintf(fid,'%s %d %d %d\n','DIMENSIONS',size(Im.vol,1),size(Im.vol,2),size(Im.vol,3));
fprintf(fid,'%s %f %f %f\n','ORIGIN',origin(1),origin(2),origin(3));
fprintf(fid,'%s %d %d %d\n','SPACING',dims(1),dims(2),dims(3));
fprintf(fid,'%s %d\n','POINT_DATA',numel(Im.vol));
fprintf(fid,'%s %s %d\n','SCALARS volume_scalars',dataFormat,1);
fprintf(fid,'%s\n','LOOKUP_TABLE default');
if strcmp(fileType,'BINARY')
   fwrite(fid,Im.vol,dataFormat,'ieee-be');

else
   if ~isinteger(Im.vol(1));
       fprintf(fid,'%d\n',Im.vol);
   else
       fprintf(fid,'%f\n',Im.vol);
   end   
end



fclose(fid);
