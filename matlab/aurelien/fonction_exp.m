function diff = fonction_exp(x,X,Y)

A = x(:,1);
B = x(:,2);
A = repmat(A, 1, size(X, 2));
B = repmat(B, 1, size(X, 2));
diff = A.*(1-2.*exp(-X./B)) - Y;
%diff = sum(diff(:) .* diff(:));