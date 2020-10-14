function [yPrime,tLag]  = Wille_and_Backer_dop54d_Prime(t,y)



phifun = 'Wille_and_Backer_Phi';
% Evaluation of the value at time lag position
tLag(1)   = -1;
tLag(2)   = -0.20;

y1L1   = feval('dop54d_Lag',phifun,1,t+tLag(1));
y2L2   = feval('dop54d_Lag',phifun,2,t+tLag(2));

yPrime(1) = y1L1;
yPrime(2) = y1L1 + y2L2;
yPrime(3) = y(2);
yPrime = yPrime(:);