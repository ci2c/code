function [yPrime,tLag] = OscityMass_dop853d_Prime(t,y,varargin)

% Remarque "@Mass_ty_Fcn"  est utile pour ce test
%          En général ne doit pas être là, 
%          Idée du test, on calcule une matrice et on l'applique
%          au vecteur yPrime et ensuite on applique la matrice inverse
%          pour obtenir la fonction connue.
Fcn = @Mass_ty_Fcn;
A   = feval(Fcn,t,y);

phifun = 'Mass_phi';
Comp   =  1;
tLag   = -1;
y2L1   = feval('dop853d_Lag',phifun,Comp,t+tLag);

yPrime(1) =       y(2);
yPrime(2) = -4*pi*pi* y2L1; 
yPrime    = A*yPrime(:);
yPrime    = yPrime(:);