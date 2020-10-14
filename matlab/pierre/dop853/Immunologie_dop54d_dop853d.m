% ------------------------------------------------------------------- %
% Model in immunology                                                 %
% E. Hairer, S.P. Norsett, G. Wanner                                  %
% Solving Ordinary Differential Equations first edition 1986 (p. 297) %
% Matlab version:                                                     %
% Denis Bichsel                                                       %
% dbichsel@infomaniak.ch                                              %
% Rue des Deurres 58                                                  %
% 2000 Neuchâtel                                                      %
%                                                                     %
% Important                                                           %
% ---------                                                           %
%                                                                     %
% The solution depends on every parameter and solver.                 %
% Interesting : h6_1 =  10 and maxstep = 0.1                          %
%               h6_1 =  10 and maxstep = 0.5                          %
% Interesting : h6_2 = 300 and maxstep = 0.1                          %
%               h6_2 = 300 and maxstep = 0.5                          %
% --------------------------------------------------------------------%
clear all
close all
clc

t       = 0:0.1:220;
y0      = [1e-6;1;1;0];
h6_1    = 10;
h6_2    = 300;
maxstep = 0.5;

option = dopset('MaxStep',maxstep);

warning off

tic
[t1,y1] = dop54d(@Immunologie_dop54d_Prime,t,y0,option,h6_1); 
T1 = toc;

tic
[t2,y2] = dop54d(@Immunologie_dop54d_Prime,t,y0,option,h6_2); 
T2 = toc;

tic
[t3,y3] = dop853d(@Immunologie_dop853d_Prime,t,y0,option,h6_1); 
 T3 = toc;
 
tic
[t4,y4] = dop853d(@Immunologie_dop853d_Prime,t,y0,option,h6_2); 
T4 = toc;

figure(1)
subplot(2,2,1)
plot(t1,1e4*y1(:,1),'b',t1,y1(:,2)/2,'r',t1,y1(:,3),'g',t1,10*y1(:,4),'k')
title(['dop54d, h6 = ',num2str(h6_1),', time = ',num2str(T1)])
subplot(2,2,2)
plot(t2,1e4*y2(:,1),'b',t2,y2(:,2)/2,'r',t2,y2(:,3),'g',t2,10*y2(:,4),'k')
title(['dop54d, h6 = ',num2str(h6_2),', time = ',num2str(T2)])
subplot(2,2,3)
plot(t3,1e4*y3(:,1),'b',t3,y3(:,2)/2,'r',t3,y3(:,3),'g',t3,10*y3(:,4),'k')
title(['dop853d, h6 = ',num2str(h6_1),', time = ',num2str(T3)])
subplot(2,2,4)
plot(t4,1e4*y4(:,1),'b',t4,y4(:,2)/2,'r',t4,y4(:,3),'g',t4,10*y4(:,4),'k')
title(['dop853d, h6 = ',num2str(h6_2),', time = ',num2str(T4)])

% Difference
y3y1 = y3 - y1;
y4y2 = y4 - y2;

figure(2)
subplot(1,2,1)
plot(t1,1e4*y3y1(:,1),'b',t1,y3y1(:,2)/2,'r',t1,y3y1(:,3),'g',t1,10*y3y1(:,4),'k')
title(['dop853d sol - dop54d sol, h6 = ',num2str(h6_1)])

subplot(1,2,2)
plot(t1,1e4*y4y2(:,1),'b',t1,y4y2(:,2)/2,'r',t1,y4y2(:,3),'g',t1,10*y4y2(:,4),'k')
title(['dop853d sol - dop54d sol, h6 = ',num2str(h6_2)])




