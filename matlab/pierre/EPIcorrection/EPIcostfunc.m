function F = EPIcostfunc(V1, V2, XYZ, u, lambda1, lambda2)
% usage : F = EPIcostfunc(V1, V2, XYZ, U, [lambda1, lambda2])
%
% Inputs :
%       V1            : Structure of image 1
%                        (displacements toward +y)
%       V2            : Structure of image 2
%                        (displacements toward -y)
%       XYZ           : coordinates matrix
%       U             : displacement field
%
% Options :
%       lambda1       : parameter for u scaling (default : 0)
%       lambda2       : parameter for u smoothness (default : 0)
%
% Outputs :
%       F             : Cost function
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 4 && nargin ~= 6
    error('invalid usage');
end

if nargin == 4
    lambda1 = 0;
    lambda2 = 0;
end

uip = circshift(u, [0, -1, 0]);
uip(:,end,:) = uip(:,end-1,:);
uim = circshift(u, [0, 1, 0]);
uim(:, 1, :) = uim(:,2,:);
U_term = (uip - uim) ./ 2;


J1 = 1 + U_term;

J2 = 1 - U_term;

I1u = spm_sample_vol(V1, XYZ(1,:)', XYZ(2,:)' + u(:), XYZ(3,:)', 2);
I2u = spm_sample_vol(V2, XYZ(1,:)', XYZ(2,:)' - u(:), XYZ(3,:)', 2);

F = sum( (J1(:) .* I1u(:) - J2(:) .* I2u(:)) .* (J1(:) .* I1u(:) - J2(:) .* I2u(:)) ) ./ numel(u);

if lambda1 ~= 0
    F = F + lambda1 .* sum(u(:) .* u(:));
end

if lambda2 ~= 0
    [Gx, Gy] = gradient(u);
    Gx(:,1:2) = 0;
    Gx(:, end-1:end) = 0;
    
    F = F + lambda2 .* sum( sqrt( Gx(:) .* Gx(:) + Gy(:) .* Gy(:) ) );    
end