function diff = fonction_t2(x,X,Y)

A = x(:,1);
B = x(:,2);
A = repmat(A, 1, size(X, 2));
B = repmat(B, 1, size(X, 2));
diff = A.*exp(-X./B) - Y;
%diff = sum(diff(:) .* diff(:));