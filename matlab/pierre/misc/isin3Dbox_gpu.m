function BOOL = isin3Dbox_gpu(V, Box)
% usage : BOOLEAN = isin3Dbox_gpu(V, Box)
%
% Determines if a vector V has at least one point in the Box.
%
% Inputs :
%     V     : 3 x N vector
%     Box   : 3 x 2 matrix of this form
%            [ X_min  X_max;
%              Y_min  Y_max;
%              Z_min  Z_max];
%
% Pierre Besson @ CHRU Lille. December, 2010

if nargin ~= 2
    error('invalid usage');
end

V = gpuArray(V);
Box = gpuArray(Box);

BOOL = gather(V(1, :) > Box(1,1) & V(1, :) < Box(1,2) & (V(2, :) > Box(2,1) & V(2, :) < Box(2,2)) & (V(3, :) > Box(3,1) & V(3, :) < Box(3,2) ));