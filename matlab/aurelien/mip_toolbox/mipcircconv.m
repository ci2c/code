function y = mipcircconv(x,h)
m = (length(h)-1)/2;
xnew = padarray(x,[0 m],'circular','both');
y = conv(xnew,h);
y = y(2*m+1:end-2*m);