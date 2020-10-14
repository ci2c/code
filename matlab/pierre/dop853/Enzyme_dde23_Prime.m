function yPrime = Enzyme_dde23_Prime(t,y,Z)
y4L1 = Z(4,1);

II   = 10.5;
z    = 1/(1+0.0005*y4L1^3);
yPrime(1) = II - z * y(1);
yPrime(2) = z* y(1) - y(2);
yPrime(3) = y(2) - y(3);
yPrime(4) = y(3) - 0.5*y(4);
yPrime    = yPrime(:);

