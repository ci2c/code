function Middle_line = Middle_line_design2(X0, L, D, W, H)
% Usage: MIDDLE_LINE = Middle_line_design2(X0, L, D, W, H)
%
% Inputs
% ------
% X0 - Position of origin [X0_x, X0_y, X0_z]
%
% L - Length of hippocampus
%
% D - Position of the shift
%
% W - Width of the shift
%
% H - Height of the shift


if nargin ~= 5
	error('Incorrect syntax: wrong number of arguments');
	return
end

R = W/2;

if D + R > L
	error('L is too small compared to D & W');
	return
end

if H == 0
	Middle_line_x = linspace(0, L, 3000)';
	Middle_line_y = zeros(3000, 0);
	Middle_line_z = zeros(3000, 0);
	Middle_line = [Middle_line_x + X0(1), Middle_line_y + X0(2), Middle_line_z + X0(3)];
else
	Middle_line_x = linspace(0, D - R, 1000)';
	Middle_line_y = zeros(1000, 1);
	Middle_line_z = zeros(1000, 1);
	
	T = linspace(-R, R, 1000)';
	A = -H / (R^4 - 2*R^3);
	d = 2 * R * H / (R^4 - 2*R^3);
	Bend_y = A * T.^4 + d * T.^2 + H;
	
	Middle_line_x = [Middle_line_x; linspace(D-R, D+R, 1000)'];
	Middle_line_y = [Middle_line_y; Bend_y];
	Middle_line_z = [Middle_line_z; zeros(1000, 1)];
	
	Middle_line_x = [Middle_line_x; linspace(D+R, L, 1000)'];
	Middle_line_y = [Middle_line_y; zeros(1000, 1)];
	Middle_line_z = [Middle_line_z; zeros(1000, 1)];
	
	Middle_line = [Middle_line_x + X0(1), Middle_line_y + X0(2), Middle_line_z + X0(3)];
end
return
