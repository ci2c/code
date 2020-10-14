% Bloch Equation Simulation, Excercise F-3c
% -----------------------------------------
% 
%	Almost the same as F-3b:


t = .0001:.00005:.006;           % in s.
rf = .05*sinc(1000*t-3);	
rfmod = exp(2*pi*800*1i*t);
%rf = [rf.*rfmod + rf.*conj(rfmod)];
rf = rf.*rfmod;
grad = .2*ones(size(t));

% Now add refocussing gradient, and append to rf and t.

refocratio = -.52;
grad = [grad refocratio*grad];
t = [t t+.006];
rf = [rf 0*rf];	

T1 = 600;       % ms.
T2 = 100;       % ms.
x = [-50:1:50];
df = 0;
[msig,m] = sliceprofile(rf,grad,t,T1,T2,x,df);


subplot(3,2,1);
plot(x,abs(msig));
xlabel('Position (mm)');
ylabel('Signal Magnitude');
grid on;
title('Magnitude Profile');

subplot(3,2,3);
plot(x,angle(msig));
xlabel('Position (mm)');
ylabel('Signal Phase (rad)');
grid on;
title('Phase Profile');

subplot(3,2,5);
plot(x,m(3,:));
xlabel('Position (mm)');
ylabel('Residual M_z');
grid on;
title('M_z Profile');

subplot(3,2,2);
plot(t,real(rf),'--',t,imag(rf),':',t,abs(rf),'-');
xlabel('Time (s)');
ylabel('RF (G)');
grid on;
title('RF vs Time');

subplot(3,2,4);
plot(t,grad);
xlabel('Time (s)');
ylabel('Gradient (G/cm)');
grid on;
title('Gradient vs Time');

