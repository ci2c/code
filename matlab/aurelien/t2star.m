function diff = t2star(x,X,Y)

A=x(1);
B=x(2);
diff = A.*exp(-X./B) - Y;