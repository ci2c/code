% Bloch Equation Simulation, Excercise A-5b
% -----------------------------------------
% 

dT = 1;		% 1ms delta-time.
T = 1000;	% total duration
N = ceil(T/dT)+1; % number of time steps.
df = 10;	% Hz off-resonance.
T1 = 600;	% ms.
T2 = 100;	% ms.

% ===== Get the Propagation Matrix ======

[A,B] = freeprecess(dT,T1,T2,df);


% ===== Simulate the Decay ======

M = zeros(3,N);	% Keep track of magnetization at all time points.
M(:,1)=[1;0;0];	% Starting magnetization.

for k=2:N
	M(:,k) = A*M(:,k-1)+B;
end;


% ===== Plot the Results ======

time = [0:N-1]*dT;
plot(time,M(1,:),'b-',time,M(2,:),'r--',time,M(3,:),'g-.');
legend('M_x','M_y','M_z');
xlabel('Time (ms)');
ylabel('Magnetization');
axis([min(time) max(time) -1 1]);
grid on;

