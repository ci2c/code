function phi = Enzyme_phi(Comp,t,varargin)
% ---------------------------
% User defined function. In general case phi may be a function of t
% This function define the Comp-th component y value for every t value 
% such that : t0 + min(tau) <= t <= t0, t0 is the initial value
% of the integration interval.
% min(tau) is the smallest value of the time lag used in the 
% differential system equations (min(tau) is negative).
%
% Input
% -----
% Comp is the indice of the variable for which the time lag value must be
% evaluated
% t_Tau is variable like t -Tau1, t-Tau2 ...
% where Tau1, Tau2 ... are the time lags
%
% Output
% ------
% yInit is the value of the fonction y with indice Comp
% evalauted at t_Tau
% ------------
% Example 15.14 in
%   Solving Differential Equations I  Nonstiff Problems
%  	E. Hairer S.P. Norsett G.Wanner
%	Springer Verlag ISBN  3-540-17145-2  ISBN 0-387-17145-2
%   and
%   Solving Differential Equations II  Stiff and Differential-Algebric Problems
%	E. Hairer G.Wanner
%   Springer Verlag ISBN  3-540-53775-9  ISBN 0-387-53775-9
% See also
%   http://www.unige.ch/~hairer/software.html
%
%	Denis Bichsel 2010-02-20
% ---------------------------
switch Comp
  case 1
    phi = 63;
  case 2
    phi = 10;
  case 3
    phi = 10;
  case 4
    phi = 21;
end

