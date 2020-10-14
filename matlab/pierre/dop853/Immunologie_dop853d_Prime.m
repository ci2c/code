function [yPrime, tLag] = Immunologie_dop853d_Prime(t,y,varargin)

tau  = -0.5; 
tLag = tau;
h6 = varargin{1};
phifun = 'Immunologie_Phi';
% Evaluation of the value at time lag position

y1Ltau   = feval('dop853d_Lag',phifun,1,t+tau);
y3Ltau   = feval('dop853d_Lag',phifun,3,t+tau);



h1 = 2;
h2 = 0.8;
h3 = 1e4; 
h4 = 0.17;
h5 = 0.5;
h7 = 0.12;
h8 = 8;
if y(4) <= 0.1
  ksi = 1;
else
  ksi = (1-y(4))*10/9;
end
yPrime(1) = (h1 -h2*y(3))*y(1);
yPrime(2) = ksi*h3*y3Ltau*y1Ltau-h5*(y(2)-1);
yPrime(3) = h4*(y(2)-y(3)) -h8*y(3)*y(1);
yPrime(4) = h6*y(1) -h7*y(4);

yPrime = yPrime(:);