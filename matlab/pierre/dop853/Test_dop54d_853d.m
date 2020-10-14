% ------------------------------------------------------------------- %
% Delay differential equation:
%
%    y' = 3*y(t) - 2*y(t-1) - 3*t^2 - 4*t + 7
% 
% If phi = phi(t) = 3t^2 - 2t + 1, then the solution is analytic
% everywhere and the exact solution is
%   y =  3t^2 - 2t + 1
% 
% If phi is another function, the solution is different and not
% analytic at t = 0, 1, 2 ...
% 
% The solutions for phi = 3t^2 - 2t + 1 and for phi = 1
% are evaluated and shown
% 
% Denis Bichsel
% Rue des Deurres 58 
% 2000 Neuchâtel
% Tel. 41 (0) 32 730 10 16
% email: dbichsel@infomaniak.ch
% ------------------------------------------------------------------- %
clear all
close all
clc

t  = [0,2];
y0 = 1;

maxstep = 0.01;
reltol  = 1e-3;
abstol  = 1e-6;

warning off
option = dopset('RelTol',reltol,'AbsTol',abstol,'MaxStep',maxstep);

tic
[t1,y1] = dop54d(@Test_dop54d_Prime,t,y0,option,1);     % <--- 1 pour sol exacte
T1 = toc;
yExact  = 3*t1.^2 - 2*t1 + 1;

[t11,y11] = dop54d(@Test_dop54d_Prime,t,y0,option,2);   % <--- 2 pour phi = 1

figure(1)
subplot(1,3,1); plot(t1,y1);        title(['dop54d,  Time = ',num2str(T1)])
subplot(1,3,2); plot(t1,y1-yExact); title('Exact sol - dop54d sol')
subplot(1,3,3); plot(t11,y11);      title('phi = 1');

tic
[t2,y2] = dop853d(@Test_dop853d_Prime,t,y0,option,1);   % <--- 1 pour sol exacte
T2 = toc;
yExact  = 3*t2.^2 - 2*t2 + 1;

[t22,y22] = dop853d(@Test_dop853d_Prime,t,y0,option,2); % <--- 2 pour phi = 1

figure(2)
subplot(1,3,1); plot(t2,y2);        title(['dop853d,  Time = ',num2str(T2)])
subplot(1,3,2); plot(t2,y2-yExact); title('Exact sol - dop853 sol')
subplot(1,3,3); plot(t22,y22);      title('phi = 1');


options = ddeset('MaxStep', maxstep,'RelTol',reltol,'AbsTol',abstol);

tic
sol = dde23(@Test_dde23_Prime,1,@Test_dde23_phi,t,options);
T3 = toc;
t3 = sol.x;
y3 = sol.y;
y3e =  3*t3.^2 - 2*t3 + 1;

figure(3)
subplot(1,2,1); plot(t3,y3);     title(['dde23,  Time = ',num2str(T3)])
subplot(1,2,2); plot(t3,y3-y3e); title('Exact sol - dde23 sol')



