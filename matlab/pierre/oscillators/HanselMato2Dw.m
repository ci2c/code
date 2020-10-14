% sol = HanselMato2Dw(trange,theta0,omega,kernel,alpha,r,display)
% Performs numerical integration of a 2D array of phase-coupled
% oscillators (with wrapped boundary conditions) using a Hansel & Mato
% (1993) style interaction term and a user-supplied connection kernel.
%
% Input parameters:
%    trange = [t0:tstep:tend].   
%    theta0 = initial phases (1xn).
%    omega = driving frequencies (1xn).
%    kernel = connection kernel (1xk) where k should be an odd number.
%    alpha = -pi..pi is a parameter of Hansel Mato model.
%    r = 0.25 is a parameter of Hansel Mato model.
%    display = true or false (to display results during the integration).
%
% Returns:
%    sol = ODE solution (see ode45, deval)
%
% Example:
%    nrow=64;
%    ncol=64;
%    trange=[0:0.01:10];
%    theta0=2*pi*rand(nrow,ncol);
%    omega=randn(nrow,ncol);
%    kernel=ones(5,5);
%    kernel(3,3)=0;
%    alpha=1.25;
%    r=0.25;
%    HanselMato2Dw(trange,theta0,omega,kernel,alpha,r,true);
%
% Reference:
%    Breakspear, M., Heitmann, S., Daffertshofer, A. (2010) Generative
%    models of cortical oscillations: From Kuramoto to the nonlinear
%    Fokker­Planck equation. Frontiers in Neuroscience 4: 190.
%
% Copyright (C) 2010 Stewart Heitmann <heitmann@ego.id.au>
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
function sol = HanselMato2Dw(trange,theta0,omega,kernel,alpha,r,display)

    % get dimensions of incoming matrices
    [nrow,ncol] = size(theta0);                 % incoming theta dims
    [orow,ocol] = size(omega);                  % incoming omega dims (should match theta)
    [krow,kcol] = size(kernel);                 % kernel dims (should be odd)
    halfkrow = floor(krow/2);
    halfkcol = floor(kcol/2);
    
    assert(nrow==orow && ncol==ocol, 'theta0 and omega must be same dimension');
    assert(mod(krow,2)==1, 'kernel must have an odd number of rows');
    assert(mod(kcol,2)==1, 'kernel must have an odd number of cols');
    assert(kernel(ceil(krow/2),ceil(kcol/2))==0, 'central element in kernel must be zero. eg kernel=[1 1 1; 1 0 1; 1 1 1]');

    % Compute dimensions of working theta (ie: theta + border equal 1/2 kernel width)
    % used in the odefun.
    wrow = nrow + krow - 1; 
    wcol = ncol + kcol - 1;
    
    % Pre-allocate storage for local variables used in odefun.
    % This is not strictly necessary but is done to prevent thrashing the memory manager.
    theta = zeros(nrow,ncol);
    thetaX = zeros(3*nrow,3*ncol);
    thetaW = zeros(wrow,wcol);
    sin_theta = zeros(wrow,wcol);
    cos_theta = zeros(wrow,wcol);
    dtheta = zeros(wrow,wcol);
    
    % tile omega to match the dimensions of working theta
    omegaW = repmat(omega,3,3);                                 % tile the original matrix
    omegaW = omegaW( nrow-halfkrow+1 : 2*nrow+halfkrow, ...
                    ncol-halfkcol+1 : 2*ncol+halfkcol );        % strip away excess borders
    %size(omegaW)
        
    % initiate axis handles required by odedisplay function 
    myaxes = [];
    
    % enable our custom real-time ODE plotting function if requested
    if display
        % enable plotting
        odeoption = odeset('OutputFcn',@odedisplay);
    else
        % disable plotting
        odeoption = [];        
    end

    % integrate
    theta1D = reshape(theta0, 1, nrow*ncol);     % reshape working theta0 as 1D vector 
    sol = ode45(@odefun,trange,theta1D,odeoption);
    
    
    % My implmentation of the Hansel & Mato ODE function in 2D using wrapped borders
    % dtheta/dt = omega + SUM_i[ k_i * (sin(theta_i-theta-alpha) - r*sin(2*(theta_i-theta))) ]
    % I have added a local synaptic footprint whereas they use global coupling.
    % I have also rejigged the equations to use convolution for implementation efficiency.
    function dtheta1D = odefun(t,theta1D)
        
         % reconstruct 2D data from incoming parameter
        theta = reshape(theta1D, nrow, ncol);
        
        % re-tile the borders of the incoming theta matrix and strip excess border
        thetaX = repmat(theta,3,3);
        thetaW = thetaX( nrow-halfkrow+1 : 2*nrow+halfkrow, ...
                         ncol-halfkcol+1 : 2*ncol+halfkcol );        % strip away excess borders

        % Calculate the coupling strength of neighbouring oscillators
        % according to the given kernel weights.
        % Here we exploit the trigonometric relationship sin(x-y)=sin(x)cos(y)-cos(x)sin(y)
        % to separate the coupling into components based on cos(theta) and sin(theta).
        % The weighted kernel can then be performed as convolution of each of these components separately.
        
        % pre-compute some handy expressions
        sin_theta = sin(thetaW);
        cos_theta = cos(thetaW);
        sin_2theta = sin(2*thetaW);
        cos_2theta = cos(2*thetaW);
        
        % The Hansel Mato Equation (my kernel version of), separated into cos and sin components.
        % The convolution computes the weighted sum of local oscillator phases.
        % The convolution performed here is actually 1D convolution despite
        % using the 2D convolution function (conv2). We use conv2 here
        % because it handles the boundary conditions more conveniently than
        % the 1D convolution function (conv) does.
        dtheta = omegaW ...
               + cos(thetaW+alpha) .* conv2(sin_theta, kernel, 'same') ...
               - sin(thetaW+alpha) .* conv2(cos_theta, kernel, 'same') ...
               - r*cos_2theta .* conv2(sin_2theta, kernel, 'same') ...
               + r*sin_2theta .* conv2(cos_2theta, kernel, 'same') ;
     
        % return result (stripped of borders) as 1D column vector        
        dtheta1D = reshape( dtheta([1:nrow]+halfkrow,[1:ncol]+halfkcol), nrow*ncol, 1); 
    end

         
    % Custom ODE plot function
    function status = odedisplay(t,y,mode)
        switch mode
            case 'init'   
                % construct figure and plot axes 
                figure('name','Hansel-Mato 2D (wrapped)', 'numbertitle','off', 'position',[100 100 400 400])
                myaxes = subplot(1,1,1);    % initiate display panel
                %colormap('gray');  
                
            case []
                for i= 1:numel(t)
                    %pause2(tstep);         
                    theta = reshape(y(:,i), nrow, ncol);
                    
                    % Display oscillator phases.
                    axes(myaxes(1));
                    thetadisplay = 32 + 32*cos(theta);       % theta=0 is brightest, theta=pi is darkest
                    image(thetadisplay);
                    title(num2str(t(i)*1000,'Oscillator Phases at t=%g millisecs'));                                  
                    drawnow;                                       
                end
                
            case 'done'
        end
        status=0;
    end


end
