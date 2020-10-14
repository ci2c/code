function tract = read_fiberViewFormat(fname)

fid = fopen(fname,'r');

newTube = 0;
while 1
   line = fgetl(fid);
   if ~ischar(line);break;end;
   if regexp(line,'NObjects =')
      nFibers = regexpi(line,'NObjects = (\d*)','match');
      eval([cell2mat(nFibers) ';']);
      NObjects = NObjects -1;
      fibers = cell(NObjects,1);
      fiberIndex = 0;
      TubeExist  = 0;
   end
   if regexp(line,'ObjectType = Tube')
      newTube = 1;
      if TubeExist
         fibers{fiberIndex+1,1} = coords;
         fiberIndex = fiberIndex +1;
      end
      TubeExist = 1;
   end
   if newTube
       if regexp(line,'NPoints =')
           nPoints = regexpi(line,'NPoints = (\d*)','match');
           eval([cell2mat(nPoints) ';']);
           coords  = zeros(NPoints,3);
           pos     = 0;
           newTube = 0;
       end
   end
   if ~newTube & regexp(line,'^\d')
      line_mod = regexp(line,'^([\S]*[\s][\S]*[\s][\S]*).*','tokens');
      data = str2num(cell2mat(line_mod{:}));
      try
          coords(pos+1,:) = data(1,1:3);
          pos = pos+1;
      catch
          disp('error');
      end
   end
   
end
if TubeExist
 fibers{fiberIndex+1,1} = coords;
 fiberIndex = fiberIndex +1;
end

fclose(fid);


tract.nFiberNr = NObjects;

for f = 1 : NObjects
    tract.fiber(f).xyzFiberCoord = fibers{f,1};
    tract.fiber(f).rgbFiberColor = rand(1,3);
    tract.nImgWidth = NaN;
    tract.nImgHeight = NaN;
    tract.nImgSlices = NaN;
end