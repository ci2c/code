function save_fiber_cuts_vtk(tract,Connectome, roi1, roi2,fname,fileType,fieldname)
% usage : save_tract_vtk(TRACT, CONNECTOME, I, J, FNAME, [FILETYPE, FIELDNAME])
% 
% Inputs :
%       TRACT       : A tract in a structure, as loaded with f_readFiber or
%                      f_readFiber_vtk_bin.
%       CONNECTOME  : Connectome structure containing fiber cuts field
%       I           : ID of first ROI
%       J           : ID of second ROI
%       FNAME       : filename.vtk
%
% Options :
%       FILETYPE  : String, must be 'ASCII' , 'BINARY' or [] for default.
%              Default : 'BINARY'.
%       FIELDNAME : string cell of the field name to write.
%              Example : {'FA', 'FA_mean'}
%
% Pierre Besson @ CHRU Lille. May 2012
% see also SAVE_VOLUME_VTK, SAVE_SURFACE_VTK

if nargin ~= 5 && nargin ~= 7 && nargin ~= 6
    error('invalid usage');
end

if nargin < 6 || isempty(fileType)
   fileType = 'BINARY'; 
end

if ~strcmp(fileType,'BINARY') && ~strcmp(fileType,'ASCII')
   error('Invalid file type (ASCII or BINARY only)');
end

fid = fopen(fname,'w');

fprintf(fid,'%s\n','# vtk DataFile Version 3.0');
fprintf(fid,'%s\n','Tracts');
fprintf(fid,'%s\n',fileType);
fprintf(fid,'%s\n','DATASET POLYDATA');

if roi1 > roi2
    Temp = roi1;
    roi1 = roi2;
    roi2 = Temp;
end

if Connectome.cuts{roi1, roi2}.N == 0
    disp('no fiber to print');
    return
end

nFibers = Connectome.cuts{roi1, roi2}.N;

FIBxyz = [];
for i = 1 : nFibers
    fibID = Connectome.cuts{roi1, roi2}.fib(i,1);
    start_point = Connectome.cuts{roi1, roi2}.fib(i,2);
    end_point = Connectome.cuts{roi1, roi2}.fib(i,3);
    FIBxyz = [FIBxyz; tract.fiber(fibID).xyzFiberCoord(start_point:end_point, :)];
end

nPoints = length(FIBxyz);

fprintf(fid,'%s %d %s\n','POINTS',nPoints,'float');

if strcmp(fileType,'BINARY')
    fwrite(fid, FIBxyz', 'float', 'ieee-be');
else
    fprintf(fid, '%f %f %f\n', FIBxyz');
end

fprintf(fid,'%s %d %d\n','LINES',nFibers,nPoints + nFibers);

Idx = 0;
for f = 1 : nFibers
    start_point = Connectome.cuts{roi1, roi2}.fib(f,2);
    end_point = Connectome.cuts{roi1, roi2}.fib(f,3);
    start = Idx;
    Length = length(start_point:end_point);
    stop  = Idx + Length - 1;
    indices = [start:1:stop];
    Idx   = stop+1;
    indices = [Length indices];
    if strcmp(fileType,'BINARY')
       fwrite(fid,indices,'int','ieee-be');
    else
       fprintf(fid,'%d ',indices); 
       fprintf(fid,'\n');
    end
end

fclose(fid);