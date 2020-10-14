function fssurfcolor(fssurf, feature, vtkfile)
%fssurfcolor(fssurf, feature, vtkfile)
%Save FreeSurfer surface to .vtk format and asign color to each vertex
%
%Arguments:
%  fssurf         : Name of the Freesurfer surface
%  feature        : Structure containing one or more features
%  vtkfile        : Name of the .vtk output colored surface

if nargin ~= 3
    error('Wrong usage');
end

disp('Read surface');
[surf.coord, surf.tri] = freesurfer_read_surf(fssurf);
disp('Save .vtk colored surface');
surf.coord = surf.coord';
save_surface_vtk(surf, vtkfile, 'ASCII', feature);
