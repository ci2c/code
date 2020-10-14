% Copyright (c) 2008 INRIA - Asclepios Project. All rights reserved.

function [T,sp,origin] = ReadInrTensorData(filename)

  % Usage:
  %
  % [T, sp, origin] = ReadInrTensorData(filename)
  %
  % T: Tensor field (cells) -> access by brackets, i.e., T{10,10,10}.
  % sp: spacing (voxel size)
  % origin: origin of the image in real world coordinates

  
[I,H] = loadinr(filename);
sp = [H.vx, H.vy, H.vz];
origin = [0 0 0];

dims = size(I);

% tensor dimension
NTensor = size(I,4);
N = (sqrt( 8*NTensor + 1 ) - 1)/2;

T = cell(dims(1:3));


for k=1:dims(3)
    for j=1:dims(2)
        for i=1:dims(1)
   
            v = I(i,j,k,:);
            t = zeros(N,N);
            ind = 1;
            
            for nc=1:N
               for nl = 1:nc
                t(nl,nc) = v(ind);
                t(nc,nl) = t(nl,nc);
                ind = ind+1;
              end
            end
            
             T{i,j,k} = t;

        end
    end
end
