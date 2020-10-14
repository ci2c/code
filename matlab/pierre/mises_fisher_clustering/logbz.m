function y = logbz(x)
% [Y Flag] = logbz(X)
% 
% This is exactly like log except when the result is negative Flag becomes
% 1 and the result becomes (-450) %-realmax

y = log(x);
Flag = (y ==-Inf);
y(Flag) = -450; %realmax;


