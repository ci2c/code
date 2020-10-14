function Jacc = EPIcomputeJaccobian(u, F)
% usage : JACC = EPIcomputeJaccobian(U, forwardity)
%
% Inputs :
%       U             : Displacement field
%       forwardity    : 1 for forward image Jaccobian (default)
%                       0 for backward image Jaccobian
%
% Output :
%       JACC          : Jaccobian of displacement field U
%
%
% Pierre Besson @ CHRU Lille, Dec. 2011

if nargin ~= 2 && nargin ~= 1
    error('invalid usage');
end

if nargin == 1
    F = 1;
end

if F ~= 1 && F ~= 0
    error('forwardity must be set to 1 or 0');
end

uip = circshift(u, [0, -1, 0]);
uip(:,end,:) = uip(:,end-1,:);
uim = circshift(u, [0, 1, 0]);
uim(:, 1, :) = uim(:,2,:);
U_term = (uip - uim) ./ 2;


if F == 1
    Jacc = 1 + U_term;
else
    Jacc = 1 - U_term;
end