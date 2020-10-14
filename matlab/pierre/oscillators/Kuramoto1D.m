% [sol,sol2] = Kuramoto1D(trange,theta0,omega,kernel,display)
% Performs numerical integration of a 1D array of phase-coupled
% Kuramoto oscillators (with free ends) using a user-supplied
% connection kernel.
%
% The ode45 solution is returned in 'sol' (see deval). It is
% computed using an efficient convolution-based implementation
% of the ODE function. An alternative version of the same solution
% is also returned in 'sol2'. It is computed using a slower method
% that is based on the conventional form of the Kuramoto model and
% is only used for validating the source code. Sol2 is not computed
% unless the caller specifically requests it in the output.
%
% Input parameters:
%    trange = [t0:tstep:tend]   
%    theta0 = initial phases (1xn)
%    omega = driving frequencies (1xn)
%    kernel = connection kernel (1xk)
%    display = true or false (to draw plots during integration)
%
% Returns:
%    sol  = ODE solution (using fast convolution method)
%    sol2 = ODE solution (using standard Kuramoto method)
%
% Example:
%    n=100;
%    trange=[0:0.1:10];
%    theta0=2*pi*rand(1,n);
%    omega=randn(1,n);
%    kernel=mexihat(-3,3,21); 
%    Kuramoto1D(trange,theta0,omega,kernel,true);
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
function [sol,sol2] = Kuramoto1D(trange,theta0,omega,kernel,display)

    % get dimensions
    n = numel(theta0);
    k = numel(kernel);
    
    % transpose omega and kernel for the benefit of odefun
    omega=omega';
    kernel=kernel';
    
    % define histogram bins used by odedisplay for phase-shift plot
    nbins = 21;
    bins = linspace(-pi+pi/nbins,pi-pi/nbins,nbins);    % bin centres

    % initiate the plot handles required by odedisplay function 
    phaseplot = [];
    phaselabel=[];
    Pkplot = [];
    Pktext=[];
    Pkdeltaplot = [];
    Pkdeltatext = [];
    driverplot = [];
    amplitudeplot = [];
    spectrumplot = [];
    kernelplot = [];
    
    % enable our custom real-time ODE plotting function if requested
    if display
        % enable plotting
        odeoption = odeset('OutputFcn',@odedisplay);
    else
        % disable plotting
        odeoption = [];        
    end

    % integrate    
    sol = ode45(@odefun,trange,theta0,odeoption);
    
    % if the sol2 output argument is requested by the caller then
    % repeat the integration using the simpler form of the ODE function
    % as well. The caller can then compare both sol and sol2 for equivalence.
    if nargout>1
        disp('Computing sol2')
        sol2 = ode45(@odefunbasic,trange,theta0, odeoption);
    end
       
    
    % Kuramoto ODE function
    function dtheta = odefun(t,theta)

        % Calculate the coupling strength of neighbouring oscillators
        % according to the given kernel weights.
        % Here we exploit the trigonometric relationship sin(x-y)=sin(x)cos(y)-cos(x)sin(y)
        % to separate the coupling into two components based on cos(theta) and sin(theta).
        % The computation can then be performed as convolution of each of these components separately.
        
        % pre-compute some common expressions
        sin_theta = sin(theta);
        cos_theta = cos(theta);

        % The Kuramoto Equation, separated into cos and sin components.
        % The convolution computes the weighted sum of local oscillator phases.
        % The convolution performed here is actually 1D convolution despite
        % using the 2D convolution function (conv2). We use conv2 here
        % because it handles the boundary conditions more conveniently than
        % the 1D conv function does.
        dtheta = omega + ...
               + cos_theta .* conv2(sin_theta, kernel, 'same') ...
               - sin_theta .* conv2(cos_theta, kernel, 'same');        
    end


    % Kuramoto ODE function in its simpler (but less efficient) form
    function dtheta = odefunbasic(t,theta)
        
        % initialise dtheta with driving frequency
        dtheta = omega;       

        % compute the kernel offsets
        koffset=[-(k-1)/2:(k-1)/2];
        
        % ...then add the phase coupling from each kernel element
        for i=1:k
            % Get the phase of the kth kernel element by shifting
            % theta by the amount specified in koffset(i).
            % We pad the wrapped values with original values taken from
            % theta so that (theta_k - theta) will evaluate to zero for
            % those padded entries.
            theta_k = theta;
            kk = koffset(i);
            if (kk<0)
                theta_k(1:end+kk) = theta(-kk+1:end);
            end
            if (kk>0)
                theta_k(kk+1:end) = theta(1:end-kk);
            end
            
            % The Kuramoto oscillator equation
            dtheta = dtheta + kernel(i)*sin(theta_k-theta);
        end
        
    end
       
         
    % Custom ODE plot function
    function status = odedisplay(t,y,mode)
        switch mode
            case 'init' 
                theta = y(:,1)';

                h = figure('Name','Kuramoto 1D');
                position = get(h,'Position');
                position(3) = 1000;     % figure width
                position(4) = 600;      % figure height
                set(h,'Position',position);    

                subplot(2,4,1);
                %phaseplot = polar(theta(1,:),ones(1,n),'o-');
                phaseplot = polar(theta(1,:),linspace(1,10,n),'.-');
                title('Instantaneous Phase');
                phaselabel = xlabel( ['t=',num2str(t(1)),' secs']);


                subplot(2,4,2);   
                thetamod = mod(theta+pi,2*pi) - pi;   % wrap theta within interval [-pi,pi]
                Pk = hist(thetamod',bins)/n;          % distribution of absolute phases
                Pkplot = bar(bins,Pk);
                xlim([-pi,pi]);
                ylim([0 1]);
                title('Phase Distribution');
                xlabel('instantaneous phase');

                % compute the Shannon Entropy for the absolute phase distribution
                indx = find(Pk>0);
                lnPk = zeros(size(Pk));
                lnPk(indx) = log(Pk(indx));
                S = -sum( Pk.*lnPk )' ./ log(nbins);
                Pktext = text(-3,0.9,['entropy=',num2str(S)]);
                
                subplot(2,4,3);
                thetadelta= theta(:,1:end-1) - theta(:,2:end);      % LHS node - RHS node
                thetadelta= mod(thetadelta+pi,2*pi) - pi;           % wrap within interval [-pi,pi]
                Pkdelta = hist(thetadelta',bins)/(n-1);             % distribution of relative phases                
                Pkdeltaplot = bar(bins,Pkdelta);
                xlim([-pi,pi]);
                ylim([0 1]);
                title('Phase Gradient Distrib');
                xlabel('phase gradient');
                
                % compute the Shannon Entropy for the phase gradient distribution
                indx = find(Pkdelta>0);
                lnPkdelta = zeros(size(Pkdelta));
                lnPkdelta(indx) = log(Pkdelta(indx));
                Sdelta = -sum( Pkdelta.*lnPkdelta )' ./ log(nbins);
                Pkdeltatext = text(-3,0.9,['entropy=',num2str(Sdelta)]);

                subplot(2,4,4); 
                [omegahist,omegabins] = hist(omega);
                driverplot = bar(omegabins,omegahist/n);
                %xlim([0 n+1]);
                title('Driving Freq Distrib');
                xlabel('driving frequency');
                %ylabel('count');
                
                subplot(2,4,[5 6]);
                amplitudeplot = stem(1:n,sin(theta));
                title('Instantaneous Amplitude');
                xlabel('Node');
                xlim([0 n+1]);
                ylim([-1 1]);

                subplot(2,4,7);
                % compute FFT
                spectrum = fft(sin(theta))./n;
                % construct matching frequency domain (x-axis) values
                fdomain = linspace(0, n-1, n);
                spectrumplot = bar(fdomain,abs(spectrum));
                %set(gca, 'YScale','log' );    
                %set(gca, 'XScale','log' );    
                ylim([0 1]);
                xlim([-1 n/2+1]);
                title('spatial frequency spectrum');
                xlabel('spatial frequency (waves per array)');
                ylabel('power');       

                subplot(2,4,8);   
                kernelx = linspace(-(k-1)/2,(k-1)/2,k);
                kernelplot = bar(kernelx,kernel);
                title('Kernel');
    

            case []
                for i= 1:numel(t)
                    %pause2(tstep); 
        
                    theta = y(:,i)';
                    
                    r=linspace(1,10,n);
                    set(phaseplot,'Xdata',r.*cos(theta));
                    set(phaseplot,'Ydata',r.*sin(theta));
                    set(phaselabel,'String',['t=',num2str(t(i)),' secs']);
                    set(amplitudeplot,'Ydata',sin(theta));    
                    
                    % update the phase distribution histogram
                    thetamod = mod(theta+pi,2*pi) - pi;           % wrap within interval [-pi,pi]
                    Pk = hist(thetamod',bins)/n;
                    set(Pkplot,'Ydata',Pk);
                    
                    % compute the Shannon Entropy for the absolute phase distribution
                    indx = find(Pk>0);
                    lnPk = zeros(size(Pk));
                    lnPk(indx) = log(Pk(indx));
                    S = -sum( Pk.*lnPk )' ./ log(nbins);
                    set(Pktext,'String',['entropy=',num2str(S)]);
                    
                    % update the phase gradient distribution histogram
                    thetadelta= theta(:,1:end-1) - theta(:,2:end);      % LHS node - RHS node
                    thetadelta= mod(thetadelta+pi,2*pi) - pi;           % wrap within interval [-pi,pi]
                    Pkdelta = hist(thetadelta',bins)/(n-1);             % histogram the relative phases into bins (nbins x t)
                    set(Pkdeltaplot,'Ydata',Pkdelta);
                  
                    % compute the Shannon Entropy for the phase gradient distribution
                    indx = find(Pkdelta>0);
                    lnPkdelta = zeros(size(Pkdelta));
                    lnPkdelta(indx) = log(Pkdelta(indx));
                    Sdelta = -sum( Pkdelta.*lnPkdelta )' ./ log(nbins);
                    %set(Pkdeltatext,'String',['entropy=',num2str(Sdelta,'%3.2f ')]);
                    set(Pkdeltatext,'String',['entropy=',num2str(Sdelta)]);
                    
                    % update the spatial frequency spectrum
                    spectrum = fft(sin(theta))./n;
                    set(spectrumplot,'Ydata',abs(spectrum));
                   
                    drawnow;                                       
                end
                
            case 'done'
        end
        status=0;
    end


end
