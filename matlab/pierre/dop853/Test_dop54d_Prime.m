function [yPrime, tLag] = Test_dop54d_Prime(t,y,varargin)

format long

Choix  = varargin{:};
phifun = 'Test_phi';
% Evaluation of the a value at time lag position
tLag = -1; 
y1L1  = feval('dop54d_Lag',phifun,1,t+tLag,Choix);
yPrime = 3*y - 2*y1L1 - 3*t^2 - 4*t + 7;
