function [yPrime, tLag] = Enzyme_dop54d_Prime(t,y,varargin)


phifun = 'Enzyme_Phi';
% Evaluation of the value at time lag position
tLag   = -4; 
y4L1   = feval('dop54d_Lag',phifun,4,t+tLag);


II   = 10.5;
z    = 1/(1+0.0005*y4L1^3);

yPrime(1) = II - z * y(1);
yPrime(2) = z* y(1) - y(2);
yPrime(3) = y(2) - y(3);
yPrime(4) = y(3) - 0.5*y(4);
yPrime = yPrime(:);