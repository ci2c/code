function y = sinc_interp(x,u)

m = 0:length(x)-1;

for i=1:length(u)
  y(i) = sum(x.*sinc(m- u(i)));
end
