% This is a demonstration script for the Kuramato1D() function.
% It implements a 1D network of Kuramoto oscillators that are spatially
% connected according to user-defined synaptic kernel.

% number of oscillators to simulate
n=128;

% simulated time domain
trange=0:0.1:30;

% initial phase of each oscillator is uniform random
theta0 = 2*pi*rand(1,n);
 
% Here we specify normally distributed driving frequencies.
% Driving frequencies are specified in radians per second (1 cycle/sec = 2*pi rad/sec)
omega = randn(1,n); 

% Here we specify a connection kernel based on the 4th derivative of Gaussian
x = -40:40;
c = 1/12;
kernel = 2 * 1/12 * (12 - 48 * c^2 * x.^2 + 16 * c^4 * x.^4) .* exp(-c^2 * x.^2);

% integrate (set final parameter true/false to enable/disble real-time display)
sol = Kuramoto1D(trange,theta0,omega,kernel,true);

% extract the results
theta = deval(sol,trange);      % theta is (n x t) matrix 
