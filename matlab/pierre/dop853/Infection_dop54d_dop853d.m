% ------------------------------------------------------------------- %
% Infectious disease modelling                                        %
% E. Hairer, S.P. Norsett, G. Wanner                                  %
% Solving Ordinary Differential Equations first edition 1986 (p. 294) %
% Matlab version:                                                     %
% Denis Bichsel                                                       %
% dbichsel@infomaniak.ch                                              %
% Rue des Deurres 58                                                  %
% 2000 Neuchâtel                                                      %
% --------------------------------------------------------------------%
clear all
close all
clc

t       = 0:0.1:40;
maxstep = 10;
warning off

options = dopset('MaxStep',maxstep,'OutputSel',[1 2 3],'DenseOutputSel',[1,2,3], ...
                 'DenseOutputFcn','Infection_dop54d_t_2');

[y0,NbrComp] = Infection_phi(1,t(1));
for k = 2:NbrComp
  [y0(k),NbrComp] = Infection_phi(k,t(1));
end
 
tic
[t1,y1] = dop54d(@Infection_dop54d_Prime,t,y0,options);
T1 = toc;

options = dopset('MaxStep',maxstep,'OutputSel',[1 2 3],'DenseOutputSel',[1,2,3], ...
                 'DenseOutputFcn','Infection_dop853d_t_2');

[y0,NbrComp] = Infection_phi(1,t(1));
for k = 2:NbrComp
  [y0(k),NbrComp] = Infection_phi(k,t(1));
end
 
tic
[t2,y2] = dop853d(@Infection_dop853d_Prime,t,y0,options);
T2 = toc;

figure
subplot(1,2,1)
plot(t1,y1(:,1),'r',t1,y1(:,2),'b',t1,y1(:,3),'k')
title(['Infection dop54d, time = ',num2str(T1)]) 
subplot(1,2,2)
plot(t2,y2(:,1),'r',t2,y2(:,2),'b',t2,y2(:,3),'k')
title(['Infection dop853d, time = ',num2str(T2)]) 

