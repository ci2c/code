function [yprime,tLag] = Infection_dop853d_Prime(t,y,varargin)
% ---------------------------
% User defined function : Infectious disease modelling
% Example 15.14 in
%   Solving Differential Equations I  Nonstiff Problems
%  	E. Hairer S.P. Norsett G.Wanner  (page 295)
%	Springer Verlag ISBN  3-540-17145-2  ISBN 0-387-17145-2
%   and
%   Solving Differential Equations II  Stiff and Differential-Algebric Problems
%	E. Hairer G.Wanner
%   Springer Verlag ISBN  3-540-53775-9  ISBN 0-387-53775-9
% See also
%   http://www.unige.ch/~hairer/software.html
%
%	Denis Bichsel 01-10-2010
% ---------------------------
% Input
% -----
% t        : The variable of the differential system
% y        : The unknown functions to evaluate
% varargin : Allow to transmit parameters to this function
%
% Output
% ------
% yprime are the derivative of the functions y
% ---------------------------

phifun = 'Infection_phi';
% Evaluation of the a value at time lag position
tLag = [-1, -10]; 
y2L1  = feval('dop853d_Lag',phifun,2,t+tLag(1));
y2L10 = feval('dop853d_Lag',phifun,2,t+tLag(2));
% Derivative of the y functions
yprime    =  zeros(3,1);
yprime(1) = -y(1) * y2L1 + y2L10;
yprime(2) =  y(1) * y2L1 - y(2);
yprime(3) =  y(2) - y2L10;