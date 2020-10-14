% [sol] = Kuramoto0D(trange,theta0,omega,K,display)
% Performs numerical integration of a 0D set of phase-coupled
% Kuramoto oscillators with global coupling strength K.
% Caller should ensure K is normalised by number of oscillators.
%
% Input parameters:
%    trange = [t0:tstep:tend]   
%    theta0 = initial phases (1xn)
%    omega = driving frequencies (1xn)
%    K = 1/n (scalar)
%    display = true or false (to draw plots during integration)
%
% Returns:
%    sol = ODE solution (see ode45, deval)
%
% Example:
%    n=100;
%    trange=[0:0.1:10];
%    theta0=2*pi*rand(1,n);
%    omega=randn(1,n);
%    K=10/n;
%    Kuramoto0D(trange,theta0,omega,K,true);
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
function [sol] = Kuramoto0D(trange,theta0,omega,K,display)

    % get dimensions
    n = numel(theta0);
    
    % define histogram bins used by odedisplay for phase distribution plot
    nbins = 21;
    bins = linspace(-pi+pi/nbins,pi-pi/nbins,nbins);    % bin centres

    % initiate the plot handles required by odedisplay function 
    phaseplot = [];
    phaselabel=[];
    Pkplot = [];
    Pktext=[];
    Rtext=[];
    driverplot = [];
    
    % enable our custom real-time ODE plotting function if requested
    if display
        % enable plotting
        odeoption = odeset('OutputFcn',@odedisplay, 'MaxStep', length(trange));
    else
        % disable plotting
        odeoption = [];        
    end

    % integrate    
    sol = ode45(@odefun,trange,theta0,odeoption);
    

    % Kuramoto ODE function in its basic form
    function dtheta = odefun(t,theta)
        
        % initialise dtheta with driving frequency (transposed to match incoming theta (nx1))
        dtheta = omega';  

        % accumulate the phase coupling from each kernel element
        for jj=1:n-1
            % get the phase of the jth theta elements by circular shift
            % to align theta(jj+1) with theta(1)
            theta_j = circshift(theta,[-jj,0]); 
            
            % The Kuramoto oscillator equation
            dtheta = dtheta + K*sin(theta_j-theta);
        end
        
        %dtheta'
    end
       
         
    % Custom ODE plot function
    function status = odedisplay(t,y,mode)
        switch mode
            case 'init' 
                theta = y(:,1)';

                h = figure('Name','Kuramoto 1D');
                position = get(h,'Position');
                position(3) = 900;     % figure width
                position(4) = 300;      % figure height
                set(h,'Position',position);    

                subplot(1,3,1);
                phaseplot = polar(theta(1,:),ones(1,n),'o');
                title('Instantaneous Phase');
                phaselabel = xlabel( ['t=',num2str(t(1)),' secs']);

                subplot(1,3,2);   
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
                Pktext = text(-3,0.9,['entropy =',num2str(S)]);

                % computer Kuramoto 'r' order parameter
                R = abs(sum( exp(i*theta) )./n);
                Rtext = text(-3,0.8,['Kuramoto r =',num2str(R)]);

                subplot(1,3,3); 
                [omegahist,omegabins] = hist(omega);
                driverplot = bar(omegabins,omegahist/n);
                %xlim([0 n+1]);
                title('Driving Freq Distrib');
                xlabel('driving frequency');
                %ylabel('count');
                

            case []
                for ii= 1:numel(t)
                    pause(0.01);
                    theta = y(:,ii)';
                    
                    set(phaseplot,'Xdata',cos(theta));
                    set(phaseplot,'Ydata',sin(theta));
                    set(phaselabel,'String',['t=',num2str(t(ii)),' secs']);
                    
                    % update the phase distribution histogram
                    thetamod = mod(theta+pi,2*pi) - pi;           % wrap within interval [-pi,pi]
                    Pk = hist(thetamod',bins)/n;
                    set(Pkplot,'Ydata',Pk);
                    
                    % compute the Shannon Entropy for the absolute phase distribution
                    indx = find(Pk>0);
                    lnPk = zeros(size(Pk));
                    lnPk(indx) = log(Pk(indx));
                    S = -sum( Pk.*lnPk )' ./ log(nbins);
                    set(Pktext,'String',['entropy = ',num2str(S)]);
                    
                    % computer Kuramoto 'r' order parameter
                    R = abs( sum( exp(i*theta) )./n );
                    set(Rtext,'String',['Kuramoto r = ',num2str(R)]);

                    drawnow;                                       
                end
                
            case 'done'
        end
        status=0;
    end


end
