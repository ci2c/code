% ------------------------------------------------------------------- 
% Matlab example  ddex1.m  (Wille' and Baker)
%                                                      
%DDEX1  Example 1 for DDE23.
%   This is a simple example of Wille' and Baker that illustrates the
%   straightforward formulation, computation, and plotting of the solution 
%   of a system of delay differential equations (DDEs). 
%
%   The differential equations
%
%        y'_1(t) = y_1(t-1)  
%        y'_2(t) = y_1(t-1)+y_2(t-0.2)
%        y'_3(t) = y_2(t)
%
%   are solved on [0, 5] with history y_1(t) = 1, y_2(t) = 1, y_3(t) = 1 for
%   t <= 0. 
%
%   The lags are specified as a vector [1, 0.2], the delay differential
%   equations are coded in the subfunction DDEX1DE, and the history is
%   evaluated by the function DDEX1HIST. Because the history is constant it
%   could be supplied as a vector:
%       sol = dde23(@ddex1de,[1, 0.2],ones(3,1),[0, 5]);
%
%   See also DDE23, FUNCTION_HANDLE.

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/21 19:24:16 $
% ------------------------------------------------------------------- %
clear all
close all
clc

t       = 0:0.1:1;    % 5
y0      = [1,1,1];
maxstep = 1;

warning off
options = dopset('MaxStep',maxstep);

tic
[t1,y1] = dop54d(@Wille_and_Backer_dop54d_Prime,t,y0,options); 
T1 = toc;

tic
[t2,y2] = dop853d(@Wille_and_Backer_dop853d_Prime,t,y0,options); 
T2 = toc;

tic
sol = dde23(@Wille_and_Backer_dde23_Prime,[1, 0.20],@Wille_and_Backer_dde23_phi,t);
T3 = toc;
t3 = sol.x';
y3 = sol.y;

figure(1)
subplot(1,3,1)
plot(t1,y1(:,1),'b',t1,y1(:,2),'r',t1,y1(:,3),'g')
title(['Wille Backer dop54d,  time = ',num2str(T1)])
xlabel('time t');
ylabel('solution y');

subplot(1,3,2)
plot(t2,y2(:,1),'b',t2,y2(:,2),'r',t2,y2(:,3),'g')
title(['Wille Backer dop853d,  time = ',num2str(T2)])
xlabel('time t');
ylabel('solution y');

subplot(1,3,3)
plot(t3,y3(1,:),'b',t3,y3(2,:),'r',t3,y3(3,:),'g')
title(['Wille Backer dde23,  time = ',num2str(T3)])
xlabel('time t');
ylabel('solution y');

y2y1 = y2-y1;

figure(2)
subplot(1,2,1)
plot(t2,y2y1(:,1),'b',t2,y2y1(:,2),'r',t2,y2y1(:,3),'g')
title('dop853d sol  minus  dop54d sol')
[t1,y1] = dop54d(@Wille_and_Backer_dop54d_Prime,t3,y0,options); 
y3y1 = y3'-y1;
subplot(1,2,2); plot(t1,y3y1(:,1),'b',t1,y3y1(:,2),'r',t1,y3y1(:,3),'g')
title('dop54d sol  minus  dde23 sol')

if t(end) <= 1
  ye = Wille_and_Backer_SolExacte(t1);
  yey1 = ye - y1;
  figure(3)
  subplot(1,3,1)
  plot(t1,yey1(:,1),'b',t1,yey1(:,2),'r',t1,yey1(:,3),'g')
  title('Exact sol  minus  sol by dop54d')  

  ye = Wille_and_Backer_SolExacte(t2);
  yey2 = ye - y2;
  figure(3)
  subplot(1,3,2)
  plot(t2,yey2(:,1),'b',t2,yey2(:,2),'r',t2,yey2(:,3),'g')
  title('Exact sol  minus  sol by dop853d')

  ye = Wille_and_Backer_SolExacte(t3);
  yey3 = ye - y3';
  figure(3)
  subplot(1,3,3)
  plot(t3,yey3(:,1),'b',t3,yey3(:,2),'r',t3,yey3(:,3),'g')
  title('Exact sol  minus  sol by dde23')
end


    
    




