function Save_metaNpara2vtk(file_meta, file_Deform, file_Jaco, file_coeff, fileVTK)
% function Save_metaNpara2vtk(tract,fname,fileType)
% 
% midAxis     : A tract  structure to be eligible to feed in
% save_track_vtk.m
% file_midAxisPt     : Medial axis file (3 useless line + 19x3 position
% vectors)
% file_midCurv  : Curvature values on from 2nd to 18th medial axis points)
%
% Hosung. BIC. July 2008.

% import surf file
file_obj=strtok(file_meta, '.')
file_obj=strcat(file_obj, '.obj')
Meta2Obj(file_meta, file_obj);
surf1=SurfStatReadSurf1(file_obj);

% import multi-dimensional data
data=struct('Deformation', 0, 'Jacobian', 0, 'Coefficient_Phi', 0)

% import medial axis points
fid=fopen(file_Deform);
if (fid>-1)
    for i = 1:3
        tline=fgetl(fid);
        disp(tline)
    end
    data.Deformation=fscanf(fid, '%f', [1002,1])
    fclose(fid);
end

fid=fopen(file_Jaco);
for i = 1:3
    tline=fgetl(fid);
    disp(tline)
end
data.Jacobian=fscanf(fid, '%f', [1002,1])
fclose(fid);

fid=fopen(file_coeff);
for i = 1:3
    tline=fgetl(fid);
    disp(tline)
end
data.Coefficient_Phi=fscanf(fid, '%f', [1002,1])
fclose(fid);

delete(file_obj);
% save a VTK file
save_surface_vtk(surf1, fileVTK, 'ASCII', data);

