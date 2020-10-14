function fixFiberViewFiles(in,out)
% Remove a couple of lines that fiberViewer doesn't like from
% MedINRIA=generated .fib files.
%
% function fixFiberViewFiles(in,out)
% in: filename of .fib file to fix
% out: filename of fixed file.
%
% Luis Concha. June 08.
 

fid = fopen(in,'r');
new = fopen(out,'w');

while 1
   line = fgetl(fid);
   if ~ischar(line);break;end;
   
   if regexp(line,'BinaryData');continue;end;
   if regexp(line,'Root = False');continue;end;
   
   fprintf(new,'%s\n',line);
    
end


fclose(fid)
fclose(new);
