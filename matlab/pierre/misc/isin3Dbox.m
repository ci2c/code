function BOOL = isin3Dbox(V, Box)
% usage : BOOLEAN = isin3Dbox(V, Box)
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

BOOL = V(1, :) > Box(1,1) & V(1, :) < Box(1,2) & V(2, :) > Box(2,1) & V(2, :) < Box(2,2) & V(3, :) > Box(3,1) & V(3, :) < Box(3,2);
% A = Box(:,2) - Box(:,1);
% A = sum(A .* A);
% M = (Box(:,2) + Box(:,1)) ./ 2;
% M = repmat(M, 1, size(V, 2));
% BOOL = sum((V - M) .* (V - M)) < A;