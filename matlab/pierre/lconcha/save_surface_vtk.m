function save_surface_vtk(surf,fname,fileType,valuesPerVertex, valuesPerTriangle, vectorPerVertex, vectorPerTriangle)
% function save_surface_vtk(surf,fname,[fileType,valuesPerVertex,...
%                           valuesPerTriangle, vectorPerVertex, vectorPerTriangle])
%
% surf              : A structure loaded by surfstat's reader
%                     containing N vertices and F triangles
%
% fname             : filename.vtk
%
% fileType          : String, must be either 'ASCII' or 'BINARY'. 
%                     Default : 'BINARY'
%
% valuesPerVertex   : N-length vector containing vertex-wise attributes
%                     Use [] if NA. Default = []
%
% valuesPerTriangle : F-length vector containing triangle-wise attributes
%                     Use [] if NA. Default = []
%
% vectorPerVertex   : Nx3 matrix assigning a vector at each vertex
%                     Use [] if NA. Default = []
%
% vectorPerTriangle : Fx3 matrix assigning a vector at each triangle
%                     Use [] if NA. Default = []
%
% See also SAVE_VOLUME_VTK, SAVE_TRACT_VTK
%
% Pierre Besson @ CHRU Lille 2013

if nargin < 2
    error('invalid usage');
end

if nargin < 3
   fileType = 'BINARY'; 
end

if ~strcmp(fileType,'BINARY') & ~strcmp(fileType,'ASCII')
   error('Invalid file type (ASCII or BINARY only)');
end

if ~isfield(surf, 'normal')
    surf.normal = getSurfNormals(surf);
end

fid = fopen(fname, 'w');
fprintf(fid, '# vtk DataFile Version 3.0\n');
fprintf(fid, 'Unstructured Grid Surface\n');
fprintf(fid, '%s\n', fileType);
fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');

nPoints = length(surf.coord);

fprintf(fid, 'POINTS %d float\n', nPoints);
if strcmp(fileType, 'BINARY')
    fwrite(fid, surf.coord, 'float', 'ieee-be');
else
    fprintf(fid, '%f %f %f\n', surf.coord);
end

if size(surf.tri, 1) > size(surf.tri, 2)
    surf.tri = surf.tri';
end

nt = size(surf.tri, 2);
triangles = [3*ones(1, nt); surf.tri-1];
fprintf(fid, 'CELLS %d %d\n', nt, 4*nt);
if strcmp(fileType, 'BINARY')
    fwrite(fid, triangles, 'int', 'ieee-be');
else
    fprintf(fid, '%d %d %d %d\n', triangles);
end

fprintf(fid, 'CELL_TYPES %d\n', nt);
if strcmp(fileType, 'BINARY')
    fwrite(fid, 5*ones(nt, 1), 'int', 'ieee-be');
else
    fprintf(fid, '%d\n', 5*ones(nt, 1));
end

fprintf(fid, 'POINT_DATA %d\n', nPoints);
fprintf(fid, 'NORMALS Normals float\n');
if strcmp(fileType, 'BINARY')
    fwrite(fid, surf.normal, 'float', 'ieee-be');
else
    fprintf(fid, '%f %f %f\n', surf.normal);
end

if nargin > 3 && ~isempty(valuesPerVertex)
    fprintf(fid, 'SCALARS vertex_data float 1\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    if strcmp(fileType, 'BINARY')
        fwrite(fid, valuesPerVertex, 'float', 'ieee-be');
    else
        fprintf(fid, '%f\n', valuesPerVertex);
    end
end

if nargin > 5 && ~isempty(vectorPerVertex)
    fprintf(fid, 'VECTORS vertex_vector float\n');
    if strcmp(fileType, 'BINARY')
        fwrite(fid, vectorPerVertex', 'float', 'ieee-be');
    else
        fprintf(fid, '%f\n', vectorPerVertex');
    end
end

if nargin > 4 && ~isempty(valuesPerTriangle)
    fprintf(fid, 'CELL_DATA %d\n', nt);
    fprintf(fid, 'SCALARS face_data float 1\n');
    fprintf(fid, 'LOOKUP_TABLE default\n');
    if strcmp(fileType, 'BINARY')
        fwrite(fid, valuesPerTriangle, 'float', 'ieee-be');
    else
        fprintf(fid, '%f\n', valuesPerTriangle);
    end
end

if nargin > 6 && ~isempty(vectorPerTriangle)
    fprintf(fid, 'VECTORS face_vector float\n');
    if strcmp(fileType, 'BINARY')
        fwrite(fid, vectorPerTriangle', 'float', 'ieee-be');
    else
        fprintf(fid, '%f\n', vectorPerTriangle');
    end
end

fclose(fid);