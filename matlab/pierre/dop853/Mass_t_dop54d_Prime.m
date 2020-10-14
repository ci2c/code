function [yPrime,tLag] = Mass_t_dop54d_Prime(t,y,varargin)

% Remarque "@Mass_t_Fcn"  est utile pour ce test
%          En général ne doit pas être là, 
%          Idée du test, on calcule une matrice et on l'applique
%          au vecteur yPrime et ensuite on applique la matrice inverse
%          pour obtenir la fonction connue.
Fcn = @Mass_t_Fcn;
A   = feval(Fcn,t);

phifun = 'Mass_phi';
Comp   =  1;
tLag   = -1;
y2L1   = feval('dop54d_Lag',phifun,Comp,t+tLag);

yPrime(1) =       y(2);
yPrime(2) = -4*pi*pi* y2L1; 
yPrime    = A*yPrime(:);
yPrime    = yPrime(:);