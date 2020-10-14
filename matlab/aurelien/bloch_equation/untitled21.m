% Bloch Equation Simulation, Excercise F-3c
% -----------------------------------------
% 
%	Almost the same as F-3b:


t = .0001:.00005:.02;           % in s.
n = (t - 0.01) ./ 0.01;
rf = 0.07./cosh(4.*n);
mod = -4.*800.*tanh(4.*n);
rfmod = exp(1i.*2.*pi.*mod);
rf = rf.*rfmod;
grad = .05*ones(size(t));

% Now add refocussing gradient, and append to rf and t.

refocratio = -.52;
grad = [grad refocratio*grad];
t = [t t+.02];
rf = [rf 0*rf];	

T1 = 1300;       % ms.
T2 = 60;       % ms.
x = [-100:1:100];
df = 0;
[msig,m] = sliceprofile(rf,grad,t,T1,T2,x,df);


subplot(3,2,1);
plot(x,real(msig));
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
plot(t,real(rf),'--',t,imag(rf),':',t,abs(rf),'r-');
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
