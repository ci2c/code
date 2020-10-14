% ------------------------------------------------------------------- %
% Population dynamic problem                                          %
% E. Hairer, S.P. Norsett, G. Wanner                                  %
% Solving Ordinary Differential Equations first edition 1986 (p. 292) %
% Matlab version:                                                     %
% Denis Bichsel                                                       %
% dbichsel@infomaniak.ch                                              %
% Rue des Deurres 58                                                  %
% 2000 Neuchâtel                                                      %
% ------------------------------------------------------------------- %

clear all
close all
clc

t    = [0:0.1:60];
y0   = 0.1;
NbrA = 5;

maxstep = 10;

warning off
options = dopset('MaxStep',maxstep);

A = [0.35,0.5,1,1.4,1.6]; % Parameter
 
tic
for k = 1:NbrA
  [t,y] = dop54d(@Population_dop54d_Prime,t,y0,options,A(k)); 
  T54(k,:) = t;
  Y54(k,:) = y;    
end
T1 = toc;

tic
for k = 1:NbrA
  [t,y] = dop853d(@Population_dop853d_Prime,t,y0,options,A(k)); 
  T853(k,:) = t;
  Y853(k,:) = y; 
end
T2 = toc;

Couleur = ['b','r','g','m','k'];

figure(1)
subplot(1,2,1)
for k = 1 : NbrA
  plot(T54(k,:),Y54(k,:),Couleur(k))
  hold on
end 
title('Population dynamique dop54d')

subplot(1,2,2)
for k = 1 : NbrA
  plot(T853(k,:),Y853(k,:),Couleur(k))
  hold on
end  
title('Population dynamique dop853d')
Y853Y54 = Y853 - Y54;

figure(2)
for k = 1 : NbrA
  plot(T853(k,:),Y853Y54(k,:),Couleur(k))
  hold on
end 
title('Population dyn. diff of sol,  dop853d - dop54d')

