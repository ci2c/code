function BOOL = isin3Dsphere(V, C, R)
% usage : BOOLEAN = isin3Dsphere(V, C, R)
%
% Determine which points of V are within a spehre of center C and radius R
%
% Inputs :
%     V     : 3 x N matrix
%     C     : 3 x 1 vector
%     R     : 1 x 1 value (>0)
%
% Pierre Besson @ CHRU Lille, Feb. 2013

if nargin ~= 3
    error('invalid usage');
end


V(:,1) = V(:,1) - C(1);
V(:,2) = V(:,2) - C(2);
V(:,3) = V(:,3) - C(3);

BOOL = (V(:,1) .* V(:,1) + V(:,2) .* V(:,2) + V(:,3) .* V(:,3)) <= (R.*R);