% This is a demonstration script for the Kuramato0D() function.
% It implements a network of globally connected Kuramoto oscillators
% with no spatial properties. It represents the conventional Kuramoto model.

% number of oscillators to simulate
n=128;

% simulated time domain
trange=0:0.01:5;

% initial phase of each oscillator is uniform random
theta0 = 2*pi*rand(1,n);

% Here we specify normally distributed driving frequencies.
% Driving frequencies are given in radians per second (1 cycle/sec = 2*pi rad/sec)
omega = randn(1,n);

% K is coupling strength
K = 10/n;

% integrate
sol = Kuramoto0D(trange,theta0,omega,K,true);

% compute evolution of Kuramoto R
theta = deval(sol,trange);
R = sum( exp(i*theta) )./n;
size(R)
figure;
plot(trange,abs(R));
title('Evolution of Kuramoto R');
xlabel('time (sec)');
ylabel('r');
