function save_tract_vtk(tract,fname,fileType, fieldname)
% usage : save_tract_vtk(TRACT, FNAME, [FILETYPE, FIELDNAME])
% 
% Inputs :
%       TRACT     : A tract in a structure, as loaded with f_readFiber or
%                      f_readFiber_vtk_bin.
%       FNAME     : filename.vtk
%
% Options :
%       FILETYPE  : String, must be 'ASCII' , 'BINARY' or [] for default.
%              Default : 'BINARY'.
%       FIELDNAME : string cell of the field name to write.
%              Example : {'FA', 'FA_mean'}
%
% Luis Concha. BIC. July 2008.
% Pierre Besson @ CHRU Lille. December 2010.
% see also SAVE_VOLUME_VTK, SAVE_SURFACE_VTK



if nargin < 3 | isempty(fileType)
   fileType = 'BINARY'; 
end

if ~strcmp(fileType,'BINARY') & ~strcmp(fileType,'ASCII')
   error('Invalid file type (ASCII or BINARY only)');
   return
end

fid = fopen(fname,'w');

fprintf(fid,'%s\n','# vtk DataFile Version 3.0');
fprintf(fid,'%s\n','Tracts');
fprintf(fid,'%s\n',fileType);
fprintf(fid,'%s\n','DATASET POLYDATA');

% nPoints = 0;
% nFibers = tract.nFiberNr;
% for f = 1 : nFibers
%     nPoints = nPoints + tract.fiber(f).nFiberLength;
% end

FIBxyz = cat(1, tract.fiber(:).xyzFiberCoord);

nFibers = tract.nFiberNr;
nPoints = length(FIBxyz);

fprintf(fid,'%s %d %s\n','POINTS',nPoints,'float');

if strcmp(fileType,'BINARY')
    fwrite(fid, FIBxyz', 'float', 'ieee-be');
else
    fprintf(fid, '%f %f %f\n', FIBxyz');
end

% if strcmp(fileType,'BINARY')
%     for f = 1 : nFibers
%         fwrite(fid,tract.fiber(f).xyzFiberCoord','float','ieee-be');
%     end
% else
%     for f = 1 : nFibers
%         fprintf(fid,'%f %f %f\n',tract.fiber(f).xyzFiberCoord');
%     end
% end

fprintf(fid,'%s %d %d\n','LINES',nFibers,nPoints + nFibers);

Idx = 0;
for f = 1 : nFibers
    start = Idx;
    stop  = Idx + tract.fiber(f).nFiberLength -1;
    indices = [start:1:stop];
    Idx   = stop+1;
    indices = [tract.fiber(f).nFiberLength indices];
    if strcmp(fileType,'BINARY')
       fwrite(fid,indices,'int','ieee-be');
    else
       fprintf(fid,'%d ',indices); 
       fprintf(fid,'\n');
    end
end

% If there is data in the tracts, save it too
% if isfield(tract.fiber,'data') & saveScalars
%     vars = fieldnames(tract.fiber(1).data);
%     fprintf(fid,'%s %d\n','CELL_DATA',tract.nFiberNr);
%     for v = 1 : length(vars)
%         var = vars{v};
%         if isempty(regexp(var,'.*mean', 'once' )) 
%             continue;
%         end
%         fprintf(1,'%s ','Cell data');
%         fprintf(fid,'%s %s %s\n','SCALARS',var,'float');
%         fprintf(1,'%s %s %s\n','SCALARS',var,'float');
%         fprintf(fid,'%s\n','LOOKUP_TABLE default');
%         for f = 1 : nFibers
%             eval(['data=tract.fiber(f).data.' var ';'])
%             data = single(data);
%             if strcmp(fileType,'BINARY')
%                 fwrite(fid,data,'float','ieee-be');
%             else
%             fprintf(fid,'%f\n',tract.fiber(f).data.FA_pp);
%             end
%         end
%     end
%     
%     fprintf(fid,'%s %d\n','POINT_DATA',nPoints);
%     for v = 1 : length(vars)
%         var = vars{v};
%         if isempty(regexp(var,'.*_pp', 'once' )) 
%             continue;
%         end
%         fprintf(1,'%s ','Point data');
%         fprintf(fid,'%s %s %s\n','SCALARS',var,'float');
%         fprintf(1,'%s %s %s\n','SCALARS',var,'float');
%         fprintf(fid,'%s\n','LOOKUP_TABLE default');
%         for f = 1 : nFibers
%             eval(['data=tract.fiber(f).data.' var ';'])
%             data = single(data);
%             if strcmp(fileType,'BINARY')
%                 fwrite(fid,data,'float','ieee-be');
%             else
%             fprintf(fid,'%f\n',tract.fiber(f).data.FA_pp);
%             end
%         end
%     end
% end

if nargin == 4
    for i = 1 : size(fieldname, 1)
        fname = char(fieldname(i, :));
        if isfield(tract.fiber, fname)
            if isfield(tract, fname)
                if strcmp(tract.(fname).type, 'point')
                    fprintf(fid,'\n %s %d\n','POINT_DATA',nPoints);
                    fprintf(fid, '%s %s %s\n', 'SCALARS', fname, 'float');
                    fprintf(fid, '%s\n', 'LOOKUP_TABLE default');
                    COLOR_TABLE=cat(1, tract.fiber(:).(fname));
                    COLOR_TABLE(isnan(COLOR_TABLE)) = 0;
                    if strcmp(fileType,'BINARY')
                        fwrite(fid, single(COLOR_TABLE), 'float', 'ieee-be');
                    else
                        fprintf(fid, '%f\n', COLOR_TABLE);
                    end
                else
                    fprintf(fid,'%s %d\n','CELL_DATA',tract.nFiberNr);
                    fprintf(fid,'%s %s %d\n','SCALARS', fname, length(tract.fiber(1).(fname)));
                    fprintf(fid, 'LOOKUP_TABLE default\n');
                    COLOR_TABLE=cat(1, tract.fiber(:).(fname));
                    COLOR_TABLE(isnan(COLOR_TABLE)) = 0;
%                     if max(COLOR_TABLE(:)) < 1
%                         COLOR_TABLE = round(COLOR_TABLE * 256);
%                     end
                    if strcmp(fileType,'BINARY')
                        fwrite(fid, COLOR_TABLE');
                        fprintf(fid, '\n');
                    else
                        fprintf(fid, '%d\n', COLOR_TABLE');
                    end
                end
            end
        end
    end
end

% Prints CELL and POINT DATA
if isfield(tract.fiber, 'rgbFiberColor')
    fprintf(fid,'%s %d\n','CELL_DATA',tract.nFiberNr);
    fprintf(fid,'%s %d\n','COLOR_SCALARS cellcolor', length(tract.fiber(1).rgbFiberColor));
    COLOR_TABLE=cat(1, tract.fiber(:).rgbFiberColor);
    if max(COLOR_TABLE(:)) < 1
        COLOR_TABLE = round(COLOR_TABLE * 256);
    end
    if strcmp(fileType,'BINARY')
        fwrite(fid, COLOR_TABLE');
        fprintf(fid, '\n');
    else
        fprintf(fid, '%d %d %d\n', round(COLOR_TABLE'));
    end
end

if isfield(tract.fiber, 'rgbPointColor')
    fprintf(fid,'%s %d\n','POINT_DATA',nPoints);
    fprintf(fid,'%s %d\n','COLOR_SCALARS pointcolor', size(tract.fiber(1).rgbPointColor, 2));
    COLOR_TABLE=cat(1, tract.fiber(:).rgbPointColor);
    if max(COLOR_TABLE(:)) < 1
        COLOR_TABLE = round(COLOR_TABLE * 256);
    end
    if strcmp(fileType,'BINARY')
        fwrite(fid, COLOR_TABLE');
    else
        fprintf(fid, '%d %d %d\n', round(COLOR_TABLE'));
    end
end


fclose(fid);