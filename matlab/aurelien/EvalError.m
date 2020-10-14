function diff = EvalError(x,X,Y)

A=x(1);
B=x(2);
% diff = min(A.*(1-2.*exp(-X./B)) - Y, -A.*(1-2.*exp(-X./B)) - Y);
% diff = abs(A.*(1-2.*exp(-X./B))) - Y;
diff = A.*(1-2.*exp(-X./B)) - Y;