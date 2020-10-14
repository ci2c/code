function save_nii_to_vtk(nii_file, vtk_file)
% usage : save_nii_to_vtk(NII_FILE, VTK_FILE)
% 
% Inputs :
%        NII_FILE      : input nifti volume name
%        VTK_FILE      : output vtk file name
%
% Pierre Besson @ CHRU Lille, May 2011
%
% see also SAVE_SURFACE_VTK, SAVE_TRACT_VTK

if nargin ~= 2
    error('invalid usage');
end

% Load volume
try
    V = spm_vol(nii_file);
    [Y, XYZ] = spm_read_vols(V);
    size_x = size(Y, 1);
    size_y = size(Y, 2);
    size_z = size(Y, 3);
catch
    error(['can not load ' nii_file]);
end

fid = fopen(vtk_file, 'w');
fprintf(fid, '%s\n', '# vtk DataFile Version 3.0');
fprintf(fid, '%s\n', 'volume');
% fprintf(fid, '%s\n', 'BINARY');
fprintf(fid, '%s\n', 'ASCII');
fprintf(fid, '%s\n', 'DATASET STRUCTURED_GRID');
fprintf(fid, '%s %d %d %d\n', 'DIMENSIONS', size_x, size_y, size_z);
fprintf(fid, '%s %d %s\n', 'POINTS', size_x * size_y * size_z, 'float');
fprintf(fid, '%f %f %f\n', XYZ);
fprintf(fid, '%s %d\n', 'POINT_DATA ', size_x * size_y * size_z);
fprintf(fid, '%s\n', 'SCALARS volume_scalars float');
fprintf(fid, '%s\n', 'LOOKUP_TABLE default');
fprintf(fid, '%f\n', Y);
% fwrite(fid, Y, 'float', 'ieee-be');
fclose(fid);