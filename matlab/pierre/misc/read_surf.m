function [coord, tri, normal, colr]=read_surf(in_file)

% [coord, tri, normal, colr]=read_surf(in_file)

fid=fopen(in_file,'r','b');
fread(fid,1,'char');
fread(fid,5,'float');
npoints=fread(fid,1,'int');
if npoints==40962
   coord=fread(fid,[3,npoints],'float');
   normal=fread(fid,[3,npoints],'float');
   ntri=fread(fid,1,'int');
   fread(fid,2+ntri,'int');
   tri=fread(fid,[3,ntri],'int')+1;
   fclose(fid);
else
   fclose(fid);
   fid=fopen(in_file,'r');
   fscanf(fid,'%s',1);
   fscanf(fid,'%f',5);
   npoints=fscanf(fid,'%f',1);
   if npoints==40962
      coord=fscanf(fid,'%f',[3,npoints]);
      normal=fscanf(fid,'%f',[3,npoints]);
      ntri=fscanf(fid,'%f',1);
      ind=fscanf(fid,'%f',1);
      if ind==0
          colr=fscanf(fid,'%f',4);
      else
          colr=fscanf(fid,'%f',[4,npoints]);
      end
      fscanf(fid,'%f',ntri);
      tri=fscanf(fid,'%f',[3,ntri])+1;
      fclose(fid);
   else
      return
   end
end

return
