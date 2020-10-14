function [yPrime, tLag] = Mass_Cte_dop54d_Prime(t,y,varargin)

MatriceA = varargin{1};

phifun = 'Mass_phi';
Comp   = 1;
tLag   = -1;
y2L1   = feval('dop54d_Lag',phifun,Comp,t+tLag);

yPrime(1) =       y(2);
yPrime(2) = -4*pi*pi* y2L1; 
yPrime    = MatriceA*yPrime(:);
yPrime    = yPrime(:);
