% This is a demonstration script for the HanselMato2Dw() function.
% It implements a 2D network of Hansel-Mato oscillators that are spatially
% connected according to user-defined synaptic kernel.

% number of oscillators to simulate
nrow= 64;
ncol= 64;

% simulated time domain
trange=[0:0.01:10];

% initial phase of each oscillator is uniform random
theta0 = 2*pi*rand(nrow,ncol);

% uniform driving frequencies in rad/sec (1 cycle/sec = 2*pi rad/sec)
omega = 0.2*ones(nrow,ncol);

% Mexican-Hat style kernel
[X,Y]=meshgrid(linspace(-3,3,41));
Z = X.^2 + Y.^2;
kernelraw = (1-0.9715*Z).*exp(-Z); 
kernelraw = kernelraw/sum(sum(kernelraw));
surf(X,Y,kernelraw);
title('synaptic kernel');

% HanselMato2Dw() requires the central kernel coefficient to be zero
kernel=kernelraw;
kernel(21,21)=0;

% Hansel-Mato parameters
alpha = 1.25;
r = 0.25;

% integrate (set final parameter true/false to enable/disable real-time display)
sol = HanselMato2Dw(trange,theta0,omega,kernel,alpha,r,true); 

% extract results
[theta2D,dtheta2D] = deval(sol,trange);         % extract results
theta2D = reshape(theta2D,nrow,ncol,[]);        % restore matrix format
dtheta2D = reshape(dtheta2D,nrow,ncol,[]);      % restore matrix format
dtheta2D = bsxfun(@minus, dtheta2D, omega);     % subtract omega from each plane

% animate results
figure('name','HanselMato2DDemos', 'numbertitle','off', 'position',[100 100 900 400]);
myaxes = [ subplot(1,2,1), subplot(1,2,2) ];    % initiate two display panels
for i= 1:numel(trange)
    % display oscillator phases 
    axes(myaxes(1));  
    thetadisplay = 32 + 32*cos(theta2D(:,:,i));       % theta=0 is brightest, theta=pi is darkest
    image(thetadisplay, 'Parent',myaxes(1));   
    title('Oscillator Phases');

    % display oscillator coupling tension
    axes(myaxes(2)); 
    imagesc( dtheta2D(:,:,i), 'Parent', myaxes(2));   
    title('Local Coupling Tension');

    drawnow;
    pause(1/30);
end

