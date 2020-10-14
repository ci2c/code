function flag = raySurfaceIntersection2(l, p0, p1, p2, IDs, Consecutive, fiberEnd)
% usage : flag = raySurfaceIntersection2(l, p0, p1, p2, IDs, Consecutive, fiberEnd)
% Ray/triangle intersection using the algorithm proposed by Möller and Trumbore (1997).
%
% Input:
%    l : coordinates of the points along the line (N x 3)
%    p0, p1, p2: vertices vectors of the triangles (M x 3)
% Output:
%    flag: (0) Reject, (1) Intersect. Vector of BOOLEAN.
% Author: 
%  original version : rayTriangleIntersection by Jesus Mena
%  modified version by Pierre Besson @ CHRU Lille, December 2010

if nargin ~= 7
    error('invalid usage');
end

uIDs_orig = unique(IDs);
FLAG = zeros(length(uIDs_orig), 1);
Fiber_change = circshift(IDs, -1) - IDs;
Fiber_change = Fiber_change(1:end-1)~=0;
Consecutive = Consecutive - circshift(Consecutive, -1)~=-1;
Consecutive = Consecutive(1:end-1);
Fiber_change = (Fiber_change + Consecutive)~=0;
fiberEnd = fiberEnd(1:end-1);
d = circshift(l, -1) - l;
d = d(1:end-1, :);
o = l(1:end-1, :);
clear Consecutive;

% Find all combination between segments and triangles
[A, B] = ndgrid(1:size(o, 1), 1:size(p0, 1));
o = o(A(:), :);
d = d(A(:), :);
p0 = p0(B(:), :);
p1 = p1(B(:), :);
p2 = p2(B(:), :);
Fiber_change = Fiber_change(A(:));
fiberEnd = fiberEnd(A(:));
IDs = IDs(A(:));
clear B;

LL = sqrt(d(:,1).^2+d(:,2).^2+d(:,3).^2);
d = d ./ repmat(LL, 1, 3);

epsilon = 0.0000001;
flag = ones(size(p1, 1), 1);

e1 = p1-p0;
e2 = p2-p0;
q  = cross(d, e2);
a  = dot(e1',q')';

flag(a > -epsilon & a < epsilon) = 0;

f = 1./a;
s = o - p0;
u = f .* dot(s', q')';

r = cross(s, e1);
v = f.*dot(d',r')';

flag(v<0.0 | u+v>1.0 | u<0.0) = 0;

t = f .* dot(e2', r')';
t(flag==0) = 0;

%  --- The first term checks for crossing between 2 consecutive points
%  --- The 2nd and 3rd check for tail and head crossing allowing 2mm
% Flag_nonzero = (flag(A(:))~=0);
% First_elem = (fiberEnd == 2) .* Flag_nonzero;
% Last_elem = (fiberEnd == 1) .* Flag_nonzero;
First_elem = (fiberEnd == 2);
% disp(['First elem : ' num2str(sum(First_elem))]);
Last_elem = (fiberEnd == 1);
% disp(['Last elem : ' num2str(sum(Last_elem))]);
flag(flag~=0) = (t(flag~=0) < LL(flag~=0)) .* (t(flag~=0) > 0);
flag(Fiber_change~=0) = 0;
flag(First_elem~=0) = flag(First_elem~=0) + (t(First_elem~=0) < 0) .* (t(First_elem~=0) > -2);
flag(Last_elem~=0) = flag(Last_elem~=0) + (t(Last_elem~=0) > 0) .* (t(Last_elem~=0) < 2);

for i = 1 : length(uIDs_orig)
    FLAG(i) = sum(flag(IDs==uIDs_orig(i)));
end

flag = FLAG;

return;