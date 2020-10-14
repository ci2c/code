function Out = sobelsph(phi_grid, theta_grid, delta);
% Usage: function Out = sobelsph(phi_grid, theta_grid, delta);
% 
% Return the spherical grid mapping the sobbel opreator centered at indices
% (0,0) with angular opening delta
%
% Author: Pierre Besson, v.0.1 September, 04 2008

% Check args
if nargin ~= 3 | nargout ~= 1
    help sobelsph
    error('Incorrect expression');
end

% Put the kernel
% (( -1 0 1 )
%  ( -2 0 2 )
%  ( -1 0 1 )
Ring = (theta_grid < delta);
% Used smoothed ring to avoid Gibb's phenomenon
%Ring = 1 / (delta * sqrt(2 * pi)) * exp(-(theta_grid).^2 / (2 * delta^2));
P1 = (phi_grid >= 0) .* (phi_grid < pi / 3) .* Ring;
P2 = 2 .* (phi_grid >= pi / 3) .* (phi_grid < 2 * pi / 3) .* Ring;
P3 = (phi_grid >= 2 * pi / 3) .* (phi_grid < pi) .* Ring;
P4 = -(phi_grid >= pi) .* (phi_grid < 4 * pi / 3) .* Ring;
P5 = -2 .* (phi_grid >= 4 * pi / 3) .* (phi_grid < 5 * pi / 3) .* Ring;
P6 = -(phi_grid >= 5 * pi / 3) .* (phi_grid < 2 * pi) .* Ring;

Out = P1 + P2 + P3 + P4 + P5 + P6;