function F = EPIcostfuncfast3D(V1, V2, XYZ, u, U_term, Delta, Delta_struc, lambda1, lambda2, I, J)
% usage : F = EPIcostfuncfast3D(V1, V2, XYZ, U, U_term, Delta, Delta_struc, [lambda1, lambda2], I, J)
%
% Inputs :
%       V1            : Structure of image 1
%                        (displacements toward +y)
%       V2            : Structure of image 2
%                        (displacements toward -y)
%       XYZ           : coordinates matrix
%       U             : displacement field
%       U_term        : (uip - uim) / 2
%       Delta         : Matrix telling where to evaluate F
%       Delta_struc   : Structure of the delta matrix
%
% Options :
%       lambda1       : parameter for u scaling (default : 0)
%       lambda2       : parameter for u smoothness (default : 0)
%
% Outputs :
%       F             : Cost function
%
% Pierre Besson @ CHRU Lille, Nov. 2011

if nargin ~= 9 && nargin ~= 11
    error('invalid usage');
end

if nargin == 5
    lambda1 = 0;
    lambda2 = 0;
end

nxyu = size(Delta_struc, 1);
nzu = size(Delta_struc, 2);

J1 = sparse(I,J,1 + U_term, nxyu, nzu);
J2 = sparse(I,J,1 - U_term, nxyu, nzu);

I1u = sparse(I,J,spm_sample_vol(V1, XYZ(1,:)', XYZ(2,:)' + u + Delta, XYZ(3,:)', 4), nxyu, nzu) .* J1;
I2u = sparse(I,J,spm_sample_vol(V2, XYZ(1,:)', XYZ(2,:)' - (u + Delta), XYZ(3,:)', 4), nxyu, nzu) .* J2;

F = sum( (I1u - I2u) .* (I1u - I2u) ) ./ nxyu;
