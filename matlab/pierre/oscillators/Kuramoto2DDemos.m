% This is a demonstration script for the Kuramato2Dw() function.
% It implements a 2D network of Kuramoto oscillators that are spatially
% connected according to user-defined synaptic kernel.

% number of oscillators to simulate
nrow=64;
ncol=64;

% simulated time domain
trange=[0:0.01:1];

% initial phase of each oscillator is uniform random
theta0 = 2*pi*rand(nrow,ncol);

% uniform driving frequencies
omega = 2*pi*ones(nrow,ncol);          % 2*pi rad/sec = 1 cycle/sec

% define connection kernel as fourth-derivative of Laplacian of Guassian
Kradius=20;                             % kernel "radius"
[X,Y]=meshgrid(-Kradius:Kradius);       % kernel domain
X2Y2 = (3/Kradius)^2 * (X.^2 + Y.^2);
kernel = 2/12 * (12 - 48*X2Y2 + 16*X2Y2.^2).*exp(-X2Y2);    
surf(X,Y,kernel);
title('synaptic kernel');

% integrate (set final parameter true/false to enable/disable real-time display)
sol = Kuramoto2Dw(trange,theta0,omega,kernel,true);

% extract results
[theta2D,dtheta2D] = deval(sol,trange);         % extract results
theta2D = reshape(theta2D,nrow,ncol,[]);        % restore matrix format
dtheta2D = reshape(dtheta2D,nrow,ncol,[]);      % restore matrix format
dtheta2D = bsxfun(@minus, dtheta2D, omega);     % subtract omega from each plane

% animate results
figure('name','Kuramoto2DDemos', 'numbertitle','off', 'position',[100 100 900 400]);
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
   
