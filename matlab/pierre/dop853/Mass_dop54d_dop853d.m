% ------------------------------------------------------------------- %
% Delay differential equation:                                        %
% Options testées :  Mass  MStateDependence                           %
%                                                                     %
% Les solutions de ces exemples sont                                  %
%   t = [0,1]                                                         %
%   y(t) = cos(2*pi*t)                                                %
%                                                                     %
% Denis Bichsel                                                       %
% Rue des Deurres 58                                                  %
% 2000 Neuchâtel                                                      %
% Tel. 41 (0) 32 730 10 16                                            %
% email: dbichsel@infomaniak.ch                                       %
% ------------------------------------------------------------------- %
clear all
close all
clc

pas     = 0.01;
t       = 0:pas:2;
y0      = [1,0];
maxstep = 1;
% Mass = matrice constante
MassCte   = [2,-3;-1,4];
optiondop = dopset('Mass',MassCte,'MaxStep', maxstep);
tic
[t1,y1] = dop54d(@Mass_Cte_dop54d_Prime,t,y0,optiondop,MassCte);
T1 = toc;

tic
[t2,y2] = dop853d(@Mass_Cte_dop853d_Prime,t,y0,optiondop,MassCte);
T2 = toc;

y2y1 = y2 - y1;

figure(1)
subplot(1,3,1)
plot(t1,y1)
title(['dop54d, Mass = cte, time = ',num2str(T1)])
subplot(1,3,2)
plot(t2,y2)
title(['dop853d, Mass = cte, time = ',num2str(T2)])
subplot(1,3,3)
plot(t2,y2y1)
title('dop853d sol - dop54d sol')
% ---------------------------

% Mass  = function depending on t only          
optiondop = dopset('Mass',@Mass_t_Fcn,'MStateDependence','none','MaxStep',maxstep);
tic
[t3,y3] = dop54d(@Mass_t_dop54d_Prime,t,y0,optiondop);
T3 = toc;

tic
[t4,y4] = dop853d(@Mass_t_dop853d_Prime,t,y0,optiondop);
T4 = toc;

y4y3 = y4- y3;

figure(2)
subplot(1,3,1)
plot(t3,y3)
title(['dop54d, Mass(t), time = ',num2str(T3)])
subplot(1,3,2)
plot(t4,y4)
title(['dop853d, Mass(t), time = ',num2str(T4)])
subplot(1,3,3)
plot(t4,y4y3)
title('dop853d sol - dop54d sol')
% ---------------------------

% Mass = function depending on t and y
optiondop = dopset('Mass',@Mass_ty_Fcn,'MStateDependence','strong');
tic
[t5,y5] = dop54d(@Mass_ty_dop54d_prime,t,y0,optiondop);
T5 = toc;

tic
[t6,y6] = dop853d(@Mass_ty_dop853d_prime,t,y0,optiondop);
T6 = toc;

y6y5 = y6 - y5;

figure(3)
subplot(1,3,1)
plot(t5,y5)
title(['dop54d, Mass(t,y), time = ',num2str(T5)])
subplot(1,3,2)
plot(t6,y6)
title(['dop853d, Mass(t,y), time = ',num2str(T6)])
subplot(1,3,3)
plot(t6,y6y5)
title('dop853d sol - dop54d sol')