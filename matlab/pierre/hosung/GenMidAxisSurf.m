function midAxis = GenMidAxisSurf(file_midAxisPt, file_midCurv)
% function midAxis = GenMidAxisSurf(file_midAxisPt, file_midCurv)
% 
% midAxis     : A tract  structure to be eligible to feed in
% save_track_vtk.m
% file_midAxisPt     : Medial axis file (3 useless line + 19x3 position
% vectors)
% file_midCurv  : Curvature values on from 2nd to 18th medial axis points)
%
% Hosung. BIC. July 2008.

% definitions to make it work out
midAxis = struct('fiber', 0, 'nImgWidth',128, 'nImgHeight', 128, 'nImgSlices', 54, 'fPixelSizeWidth',2.5, 'fPixelSizeHeight', 2.5, 'fSliceThickness', 2.5, 'nFiberNr', 1) 
midAxis.fiber = struct( 'xyzFiberCoord',1, 'nFiberLength',19, 'rgbFiberColor', [0.7115 0.0904 0.3871], 'nSelectFiberStartPoint', 0, 'nSelectFiberEndPoint',18,'data',0)
midAxis.fiber.data=struct('curvature_pp',0,'someOtherThing_pp',rand(19,1))

% import medial axis points
fid=fopen(file_midAxisPt);
for i = 1:3
    tline=fgetl(fid);
    disp(tline)
end
midAxis.fiber.xyzFiberCoord=fscanf(fid,'%f',[3,19]);
midAxis.fiber.xyzFiberCoord=midAxis.fiber.xyzFiberCoord'

fclose(fid);

% import curvature data
fid2=fopen(file_midCurv);
for i = 1:3
    tline=fgetl(fid2);
    disp(tline)
end
midAxis.fiber.data.curvature_pp=fscanf(fid,'%f',[19,1])
fclose(fid2);
midAxis.fiber.data.curvature_pp= [0; midAxis.fiber.data.curvature_pp; 0];

% DONEf