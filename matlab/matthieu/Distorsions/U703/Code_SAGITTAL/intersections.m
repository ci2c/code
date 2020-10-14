function [x0,y0] = intersections(x1,y1,x2,y2,robust)
%INTERSECTIONS Intersections of curves.
%   Computes the (x,y) locations where two curves intersect.  The curves
%   can be broken with NaNs or have vertical segments.
%
% Usage:
%   [X0,Y0] = intersections(X1,Y1,X2,Y2,ROBUST);
%
% where X1 and Y1 are equal-length vectors of at least two points and
% represent curve 1.  Similarly, X2 and Y2 represent curve 2.
% X0 and Y0 are column vectors containing the points at which the two
% curves intersect.
%
% ROBUST (optional) set to true means to use a slight variation of the
% algorithm that might return duplicates of some intersection points, and
% then those duplicates are removed.  The default is true, but since the
% algorithm is slightly slower you can set it to false if you know that
% your curves don't intersect at any segment boundaries.
%
% Be careful if the two curves have any degenerate line segments, exactly
% overlap anywhere or you expect to find an intersection at an end point of
% one of the curves.  (A degenerate segment is one in which the two end
% points are the same.)  Because of numerical effects it is difficult to
% handle these correctly.  These problems will be unlikely to occur with
% real data.

% Version: 1.5, 26 April 2007
% Author:  Douglas M. Schwarz
% Email:   dmschwarz=ieee*org, dmschwarz=urgrad*rochester*edu
% Real_email = regexprep(Email,{'=','*'},{'@','.'})


% Theory of operation:
%
% Given two line segments, L1 and L2,
%
%   L1 endpoints:  (x1(1),y1(1)) and (x1(2),y1(2))
%   L2 endpoints:  (x2(1),y2(1)) and (x2(2),y2(2))
%
% we can write four equations with four unknowns and then solve them.  The
% four unknowns are t1, t2, x0 and y0, where (x0,y0) is the intersection of
% L1 and L2, t1 is the distance from the starting point of L1 to the
% intersection relative to the length of L1 and t2 is the distance from the
% starting point of L2 to the intersection relative to the length of L2.
%
% So, the four equations are
%
%    (x1(2) - x1(1))*t1 = x0 - x1(1)
%    (x2(2) - x2(1))*t2 = x0 - x2(1)
%    (y1(2) - y1(1))*t1 = y0 - y1(1)
%    (y2(2) - y2(1))*t2 = y0 - y2(1)
%
% Rearranging and writing in matrix form,
%
%  [x1(2)-x1(1)       0       -1   0;      [t1;      [-x1(1);
%        0       x2(2)-x2(1)  -1   0;   *   t2;   =   -x2(1);
%   y1(2)-y1(1)       0        0  -1;       x0;       -y1(1);
%        0       y2(2)-y2(1)   0  -1]       y0]       -y2(1)]
%
% Let's call that A*T = B.  We can solve for T with T = A\B.
%
% Once we have our solution we just have to look at t1 and t2 to determine
% whether L1 and L2 intersect.  If 0 <= t1 < 1 and 0 <= t2 < 1 then the two
% line segments cross and we can include (x0,y0) in the output.
%
% In principle, we have to perform this computation on every pair of line
% segments in the input data.  This can be quite a large number of pairs so
% we will reduce it by doing a simple preliminary check to eliminate line
% segment pairs that could not possibly cross.  The check is to look at the
% smallest enclosing rectangles (with sides parallel to the axes) for each
% line segment pair and see if they overlap.  If they do then we have to
% compute t1 and t2 (via the A\B computation) to see if the line segments
% cross, but if they don't then the line segments cannot cross.  In a
% typical application, this technique will eliminate most of the potential
% line segment pairs.


% Input checks.
error(nargchk(4,5,nargin))
% x1 and y1 must be vectors with same number of points (at least 2).
if sum(size(x1) > 1) ~= 1 || sum(size(y1) > 1) ~= 1 || ...
		length(x1) ~= length(y1)
	error('X1 and Y1 must be equal-length vectors of at least 2 points.')
end
% x2 and y2 must be vectors with same number of points (at least 2).
if sum(size(x2) > 1) ~= 1 || sum(size(y2) > 1) ~= 1 || ...
		length(x2) ~= length(y2)
	error('X2 and Y2 must be equal-length vectors of at least 2 points.')
end

% Default value for robust is true.
if nargin < 5
	robust = true;
end


% Force all inputs to be column vectors.
x1 = x1(:);
y1 = y1(:);
x2 = x2(:);
y2 = y2(:);

% Compute number of line segments in each curve and some differences we'll
% need later.
n1 = length(x1) - 1;
n2 = length(x2) - 1;
dxy1 = diff([x1 y1]);
dxy2 = diff([x2 y2]);

% Determine the combinations of i and j where the rectangle enclosing the
% i'th line segment of curve 1 overlaps with the rectangle enclosing the
% j'th line segment of curve 2.
[i,j] = find(repmat(min(x1(1:end-1),x1(2:end)),1,n2) <= ...
	repmat(max(x2(1:end-1),x2(2:end)).',n1,1) & ...
	repmat(max(x1(1:end-1),x1(2:end)),1,n2) >= ...
	repmat(min(x2(1:end-1),x2(2:end)).',n1,1) & ...
	repmat(min(y1(1:end-1),y1(2:end)),1,n2) <= ...
	repmat(max(y2(1:end-1),y2(2:end)).',n1,1) & ...
	repmat(max(y1(1:end-1),y1(2:end)),1,n2) >= ...
	repmat(min(y2(1:end-1),y2(2:end)).',n1,1));

% Find segments pairs which have at least one vertex = NaN and remove them.
% This line is a fast way of finding such segment pairs.  We take
% advantage of the fact that NaNs propagate through calculations, in
% particular subtraction (in the calculation of dxy1 and dxy2, which we
% need anyway) and addition.
remove = isnan(sum(dxy1(i,:) + dxy2(j,:),2));
i(remove) = [];
j(remove) = [];

% Initialize matrices.  We'll put the T's and B's in matrices and use them
% one column at a time.  For some reason, the \ operation below is faster
% on my machine when A is sparse so we'll initialize a sparse matrix with
% the fixed values and then assign the changing values in the loop.
n = length(i);
T = zeros(4,n);
A = sparse([1 2 3 4],[3 3 4 4],-1,4,4,8);
B = -[x1(i) x2(j) y1(i) y2(j)].';
index_dxy1 = [1 3];  %  A(1) = A(1,1), A(3) = A(3,1)
index_dxy2 = [6 8];  %  A(6) = A(2,2), A(8) = A(4,2)

% Loop through possibilities.  Set warning not to trigger for anomalous
% results (i.e., when A is singular).
warning_state = warning('off','MATLAB:singularMatrix');
try
	for k = 1:n
		A(index_dxy1) = dxy1(i(k),:);
		A(index_dxy2) = dxy2(j(k),:);
		T(:,k) = A\B(:,k);
	end
	warning(warning_state)
catch
	warning(warning_state)
	rethrow(lasterror)
end

% Find where t1 and t2 are between 0 and 1 and return the corresponding x0
% and y0 values.  Anomalous segment pairs can be segment pairs that are
% colinear (overlap) or the result of segments that are degenerate (end
% points the same).  The algorithm will return an intersection point that
% is at the center of the overlapping region.  Because of the finite
% precision of floating point arithmetic it is difficult to predict when
% two line segments will be considered to overlap exactly or even intersect
% at an end point.  For this algorithm, an anomaly is detected when any
% element of the solution (a single column of T) is a NaN.
% The robust alternative might find some intersections twice, but they will
% be removed later.  It's more robust, but a little slower.
if robust
	in_range = T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) <= 1 & T(2,:) <= 1;
else
	in_range = T(1,:) >= 0 & T(2,:) >= 0 & T(1,:) < 1 & T(2,:) < 1;
end
anomalous = any(isnan(T));
if any(anomalous)
	ia = i(anomalous);
	ja = j(anomalous);
	% set x0 and y0 to middle of overlapping region.
	T(3,anomalous) = (max(min(x1(ia),x1(ia+1)),min(x2(ja),x2(ja+1))) + ...
		min(max(x1(ia),x1(ia+1)),max(x2(ja),x2(ja+1)))).'/2;
	T(4,anomalous) = (max(min(y1(ia),y1(ia+1)),min(y2(ja),y2(ja+1))) + ...
		min(max(y1(ia),y1(ia+1)),max(y2(ja),y2(ja+1)))).'/2;
	x0 = T(3,in_range | anomalous).';
	y0 = T(4,in_range | anomalous).';
else
	x0 = T(3,in_range).';
	y0 = T(4,in_range).';
end

% Remove duplicate intersection points if robust option is true.
if robust
	xy0 = unique([x0 y0],'rows');
	x0 = xy0(:,1);
	y0 = xy0(:,2);
end

% Plot the results (useful for debugging).
% plot(x1,y1,x2,y2,x0,y0,'ok');

