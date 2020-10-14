function info = mnc_info(fname)
%
% function info = mnc_info(fname)
%
%

tmpFileName = '/tmp/tmp.txt';

eval(['!mincinfo ' fname ' > ' tmpFileName])

fid = fopen(tmpFileName);

check=0;
while 1
   tline = fgetl(fid);
   if ~ischar(tline), break, end
   if regexp(tline,'-----'),check=1;end;
   if regexp(tline,'xspace') & check
      match = regexp(tline,'(\S*)','tokens');
      info.xspace.length = str2num(cell2mat(match{2}));
      info.xspace.step   = str2num(cell2mat(match{3}));
      info.xspace.start  = str2num(cell2mat(match{4}));
   end
   if regexp(tline,'zspace') & check
      match = regexp(tline,'(\S*)','tokens');
      info.zspace.length = str2num(cell2mat(match{2}));
      info.zspace.step   = str2num(cell2mat(match{3}));
      info.zspace.start  = str2num(cell2mat(match{4}));
   end
   if regexp(tline,'yspace') & check
      match = regexp(tline,'(\S*)','tokens');
      info.yspace.length = str2num(cell2mat(match{2}));
      info.yspace.step   = str2num(cell2mat(match{3}));
      info.yspace.start  = str2num(cell2mat(match{4}));
   end
   
end

fclose(fid);
%eval(['!rm ' tmpFileName])