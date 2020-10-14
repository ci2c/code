function fsvol2vtk(vol, vtkfile, is_ras)
%fsvol2vtk(vol, vtkfile, [is_ras])
%Save FS-MRI matrix vol to .vtk
%
%Arguments:
%  vol            : Matrix containing FS like MRI
%  vtkfile        : Name of the .vtk outfile
%  is_ras         : Boolean. 1 if volume is in RAS space. By default, is_ras=0.

if nargin ~= 2 & nargin ~= 3
    error('Wrong usage');
end

if nargin == 3
    if is_ras == 0
    	disp('Rotate volume in RAS space');
    	vol=rotate_to_surf(vol);
    else
    	disp('Volume in RAS space');
    end
end

disp('Save .vtk volume');

save_volume_vtk(vol, vtkfile, 'ASCII', [1 1 1], [-127 -128 -127]);
