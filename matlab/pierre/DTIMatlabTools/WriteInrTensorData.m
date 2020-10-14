% Copyright (c) 2008 INRIA - Asclepios Project. All rights reserved.

function []=WriteInrTensorData(T, sp, filename)
   
  % Usage:
  %
  % WriteInrTensorData( T, sp, filename)
  %
  % T: Tensor field (cells).
  % sp: spacing (voxel size)
  % origin: origin of the image in real world coordinates
    
dimx = size(T,1);
dimy = size(T,2);
dimz = size(T,3);

buffer = zeros([dimx dimy dimz 6]);

for k=1:dimz
    for j=1:dimy
        for i=1:dimx
            
            t = T{i,j,k};
            buffer(i,j,k,:)=[t(1,1) t(1,2) t(2,2) t(1,3) t(2,3) t(3,3)];
            
        end
    end
end

% check out if the .gz extension is set
l = length(filename);
if ( strcmp( filename(l-2:l), '.gz') );
    filename = filename(1:l-3);
end

type = 'double_vec';
writeinr(filename, buffer, type, sp);
command = sprintf('gzip %s',filename);
unix(command);
