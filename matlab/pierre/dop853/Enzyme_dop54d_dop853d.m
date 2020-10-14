% ------------------------------------------------------------------- %
% Enzyme kinetics problem                                             %
% E. Hairer, S.P. Norsett, G. Wanner                                  %
% Solving Ordinary Differential Equations first edition 1986 (p. 296) %
% Matlab version:                                                     %
% Denis Bichsel                                                       %
% dbichsel@infomaniak.ch                                              %
% Rue des Deurres 58                                                  %
% 2000 Neuchâtel                                                      %
% --------------------------------------------------------------------%
clear all
close all
clc

t  = 0:0.1:160;
y0 = [63;11;11;21];

maxstep = 0.114;

dopoption = dopset('MaxStep',maxstep);

warning off
tic
[t1,y1] = dop54d(@Enzyme_dop54d_Prime,t,y0,dopoption); 
T1 = toc; 

tic
[t2,y2] = dop853d(@Enzyme_dop853d_Prime,t,y0,dopoption); 
T2 = toc; 

y2y1 = y2 - y1; % Difference 

odeoptions = ddeset('MaxStep',maxstep);
tic
sol = dde23(@Enzyme_dde23_Prime,[4],@Enzyme_dde23_Phi,t,odeoptions);
T3 = toc;
t3 = sol.x';
y3 = sol.y;

figure(1)
subplot(1,3,1)
plot(t1,y1(:,1),'b',t1,y1(:,2),'r',t1,y1(:,3),'g',t1,y1(:,4),'k') 
title(['dop54d,  time = ',num2str(T1)]) 

subplot(1,3,2)
plot(t2,y2(:,1),'b',t2,y2(:,2),'r',t2,y2(:,3),'g',t2,y2(:,4),'k')  
title(['dop853d,  time = ',num2str(T2)]) 

subplot(1,3,3)
plot(t3,y3(1,:),'b',t3,y3(2,:),'r',t3,y3(3,:),'g',t3,y3(4,:),'k')  
title(['dde23,  time = ',num2str(T3)]) 

% Comparaison  dop853d - dop54d  and  dop853 - dde23

[t2,y2] = dop853d(@Enzyme_dop853d_Prime,t3,y0,dopoption); 

y2y3 = y2 - y3';

figure(2)
subplot(1,2,1)
plot(t1,y2y1(:,1),'b',t1,y2y1(:,2),'r',t1,y2y1(:,3),'g',t1,y2y1(:,4),'k')
title('dop853d sol  minus  dop54d sol')
subplot(1,2,2)
plot(t3,y2y3(:,1),'b',t3,y2y3(:,2),'r',t3,y2y3(:,3),'g',t3,y2y3(:,4),'k')
title('dop853d sol  minus  dde23 sol')
