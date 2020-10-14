function [yPrime, tLag] = Population_dop853d_Prime(t,y,varargin)

A      = varargin{:};
phifun = 'Population_Phi';
% Evaluation of the value at time lag position
tLag   = -1; 
y1L1   = feval('dop853d_Lag',phifun,1,t+tLag);
yPrime = (A -y1L1)*y;
