function Middle_line = Middle_line_design(d, R, X0, L)
% Usage: MIDDLE_LINE = Middle_line_design(D, R, X0, L)
%
% Inputs
% ------
% D - Length of hippocampus head
%
% R - 3D curvature radius of the tail
%     Horizontal and Vertical Radius (RH & RV) [RH, RV]
%
% X0 - Position of ref. point [X0_x, X0_y, X0_z]
%
% L - Length of hippocampus tail

if nargin ~= 4
	error('Incorrect syntax: wrong number of arguments');
	return
end

Head_x = (linspace(0,d,1000))' + ones(1000, 1) * X0(1);
Head_y = ones(1000, 1) * X0(2);
Head_z = ones(1000, 1) * X0(3);

Head = [Head_x, Head_y, Head_y];

CenterH = [Head_x(end), Head_y(end) - R(1), Head_z(end)];
CenterV = [Head_x(end), Head_y(end), Head_z(end) - R(2)];

Tail_x = linspace(0,L,1000)';
Tail_y = zeros(1000, 1);
Tail_z = zeros(1000, 1);

% Horizontal curving
if R(1) ~= 0
	Teta = asin(Tail_x / R(1));
	Tail_y = R(1)*(1-cos(Teta));
else
	Tail_y = zeros(size(Tail_x));
end

% Vertical curving
if R(2) ~= 0
	Teta = asin(Tail_y / R(2));
	Tail_z = R(2) * (1-cos(Teta));
else
	Tail_z = zeros(size(Tail_y));
end

Tail_x = Tail_x + Head_x(end);
Tail_y = Tail_y + Head_y(end);
Tail_z = Tail_z + Head_z(end);

Middle_line = [([Head_x; Tail_x]), ([Head_y; Tail_y]), ([Head_z; Tail_z])];
return