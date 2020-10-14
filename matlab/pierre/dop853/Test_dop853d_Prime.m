function [yPrime, tLag] = Test_dop853d_Prime(t,y,varargin)

Choix  = varargin{:};
phifun = 'Test_phi';
% Evaluation of the a value at time lag position
tLag = -1; 
y1L1  = feval('dop853d_Lag',phifun,1,t+tLag,Choix);

tLag   = -1;
yPrime = 3*y - 2*y1L1 - 3*t^2 - 4*t + 7;