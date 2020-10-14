function phi = Wille_and_Backer_phi(Comp,t,varargin)
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
%
%	Denis Bichsel 2010-03-20
% ---------------------------
phi = 1;  % Cte for all components