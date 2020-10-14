function Kern = make_ellipsoid(Axes)
% Usage: KERN = MAKE_ELLIPSOID(AXES)
%
% INPUT:
% -------
%  AXES - Length of axes along X, Y and Z [A, B, C]
%
% Creates the filled ellipsoid :
% x^2/A^2 + y^2/B^2 + z^2/C^2 <= 1

if nargin ~= 1
	error('Invalid syntax: wrong nuber of arguments')
end

if size(Axes) ~= [1 3]
	error('Invalid size for arguments')
end

A = Axes(1);
B = Axes(2);
C = Axes(3);

X = -A:A;
Y = -B:B;
Z = -C:C;
Kern = zeros(size(X, 2), size(Y, 2), size(Z, 2));

for i = 1 : length(X)
	for j = 1 : length(Y)
		for k = 1 : length(Z)
			Kern(i, j, k) = X(i).^2 / A.^2 + Y(j).^2 / B.^2 + Z(k).^2 / C.^2;
		end
	end
end

Kern = Kern <= 1;

return

