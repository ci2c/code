function mgz2vtk(vtkfile, mrifile)
%mgz2vtk(vtkfile, mrifile)
%Save FreeSurfer volume .mgz to .vtk
%
%Arguments:
%  vtkfile        : Name of the .vtk outfile
%  mrifile        : Name of the .mgz infile

if nargin ~= 2
    error('Wrong usage');
end

disp('Read .mgz volume');
mri = MRIread(mrifile);
disp('Save .vtk volume');
save_volume_vtk(rotate_to_surf(mri.vol), vtkfile, 'ASCII', [1 1 1], [-127 -128 -127]);
