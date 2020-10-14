% COCONTRACTIONSTABILITYMOVIE generates an animated movie (avi) of the motion of
% the 200 instances of a three-link biomechanical limb under conditions of medium,
% strong and extreme levels of muscle co-contraction. The movie demonstrates
% co-contraction of antagonist muscles modulating bistability of limb joints.
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
%
function CocontractionStabilityMovie()

    % animation frame rate
    fps = 20;

    % make a movie (if true)
    if true
        mov = avifile('CocontractionStabilityMovie.avi', 'FPS',fps);
    end
 
    % arm constants
    parm.L = [1 1 1];                        % length of each segment
    parm.M = [1 1 1];                        % mass of each segment
    parm.I = parm.M .* parm.L.^2/12;         % moment of inertia of each segment
    parm.Gx = [0 0 0];                       % external linear force applied on each segment (x-component)
    parm.Gy = -9.81*parm.M;                  % external linear force applied on each segment (y-component)
    parm.Te = [0 0 0];                       % external torque applied on each segment
    parm.FQx = 0;                            % External linear force applied at tip (Q) of arm
    parm.FQy = 0;                            % External linear force applied at tip (Q) of arm
    parm.Ox = 0;                             % X-position of arm anchor point
    parm.Oy = 0;                             % Y-position of arm anchor point
    parm.Otheta = pi;                        % Angular orientation of arm anchor point
    parm.Kf = [0 0 0];                       % Linear damping constant applied to each each segment
    parm.Kt = [0 0 0];                       % Angular damping constant applied to each each segment
    parm.Ks = 1;                             % Joint-spring stiffness constant
    parm.Kd = 1;                             % Joint-spring damping constant
    parm.actA = [0.9 0.9 1.0];               % activation level (0..1) of muscles A (flexors)
    parm.actB = [0.8 1.0 0.9];               % activation level (0..1) of muscles B (extensors)
    parm.FmaxA = [4000,2000,1000];           % maximal force of muscles A
    parm.FmaxB = [4000,2000,1000];           % maximal force of muscles B
    parm.KpeA = [0.1,0.1,0.1];               % PE Force-Length parameters of muscles A
    parm.KpeB = [0.1,0.1,0.1];               % PE Force-Length parameters of muscles B
    parm.KlA = -ones(1,3)*pi^2/log(0.1);     % CE Force-Length parameters of muscles A
    parm.KlB = -ones(1,3)*pi^2/log(0.1);     % CE Force-Length parameters of muscles B
    parm.KvA = [0.2,0.2,0.2];                % CE Force-Velocity parameters of muscles A
    parm.KvB = [0.2,0.2,0.2];                % CE Force-Velocity parameters of muscles B
    parm.phiA = [-0.2,-0.2,-0.2];            % angles of muscle insertion a (proximal muscle A, typically phiA<0)
    parm.phiB = [ 0.2, 0.2, 0.2];            % angles of muscle insertion d (proximal muscle B, typically phiB>0)
    parm.phiC = [ 0.2, 0.2, 0.2];            % angles of muscle insertion c (distal muscle A, typically phiC>0)
    parm.phiD = [-0.2,-0.2,-0.2];            % angles of muscle insertion d (distal muscle B, typically phiD<0)
    parm.psiminA = [0.3*pi, 0.3*pi, 0.3*pi]; % joint angle lower limit wrt muscle A (eg psimin=0)
    parm.psimaxA = [1.6*pi, 1.6*pi, 1.6*pi]; % joint angle upper limit wrt muscle A (eg psimax=2*pi)
    parm.psiminB = 2*pi-parm.psimaxA;        % joint angle lower limits wrt muscle B
    parm.psimaxB = 2*pi-parm.psiminA;        % joint angle upper limits wrt muscle B
    parm.psimidA = pi-1;                     % resting joint angle (length) of muscle A
    parm.psimidB = pi-1;                     % resting joint angle (length) of muscle B

    % number of repeat trials
    ntrials = 200;
    
    % construct identical initial conditions for each experimental condition
    Sx0 = zeros(ntrials,3);
    Sy0 = zeros(ntrials,3);
    Vx0 = zeros(ntrials,3);
    Vy0 = zeros(ntrials,3);
    theta0 = zeros(ntrials,3);
    omega0 = zeros(ntrials,3);
    for n=1:ntrials
        [Sx0(n,:),Sy0(n,:),Vx0(n,:),Vy0(n,:),theta0(n,:),omega0(n,:)] = RandomInitialValues(parm.L, parm.psiminA+0.5, parm.psimaxA-0.5);
    end
    
    % initalise intermediate variables for MEDIUM co-contraction 
    SxA = Sx0;
    SyA = Sy0;
    VxA = Vx0;
    VyA = Vy0;
    thetaA = theta0;
    omegaA = omega0;
    
    % initalise intermediate variables for STRONG co-contraction 
    SxB = Sx0;
    SyB = Sy0;
    VxB = Vx0;
    VyB = Vy0;
    thetaB = theta0;
    omegaB = omega0;
    
    % initalise intermediate variables for EXTREME co-contraction 
    SxC = Sx0;
    SyC = Sy0;
    VxC = Vx0;
    VyC = Vy0;
    thetaC = theta0;
    omegaC = omega0;
    
    % simulation time range
    tstep = 1/fps;
    trange = [0:tstep:10];
    
    figure('name','Muscle Co-contraction', 'numbertitle','off', 'position',2*[rand*100 rand*100 480 360], 'color','w');
    axes_background = axes('Position',[0,0,1,1]);
    image(imread('CocontractionStabilityBackground.png'));
    axis off;
    axesA = axes('Position',[0.06,0.42,0.25,0.4]);
    axesB = axes('Position',[0.385,0.42,0.25,0.4]);
    axesC = axes('Position',[0.71,0.42,0.25,0.4]);

    % for each time step....
    for tframe = trange
    
        % incrementally simulate ntrials of MEDIUM co-contraction
        disp(num2str([ntrials],'MEDIUM co-contraction %d trials'));
        parm.actA = [0.3 0.1 0.3];   % activation level (0..1) of the agonist muscles  
        parm.actB = [0.1 0.3 0.1];   % activation level (0..1) of the antagonist muscles  
        axes(axesA);
        [SxA,SyA,VxA,VyA,thetaA,omegaA] = MultipleTrials(SxA,SyA,VxA,VyA,thetaA,omegaA);
        title('Medium Co-contraction', 'FontWeight','bold', 'FontSize',18);   
        drawnow;

        % incrementally simulate ntrials of MEDIUM co-contraction
        disp(num2str([ntrials],'STRONG co-contraction %d trials'));
        parm.actA = [0.6 0.4 0.6];   % activation level (0..1) of the agonist muscles  
        parm.actB = [0.4 0.6 0.4];   % activation level (0..1) of the antagonist muscles  
        axes(axesB);
        [SxB,SyB,VxB,VyB,thetaB,omegaB] = MultipleTrials(SxB,SyB,VxB,VyB,thetaB,omegaB);
        title('Strong Co-contraction', 'FontWeight','bold', 'FontSize',18);   
        drawnow;

        % incrementally simulate ntrials of MEDIUM co-contraction
        disp(num2str([ntrials],'EXTREME co-contraction %d trials'));
        parm.actA = [0.9 0.7 0.9];   % activation level (0..1) of the agonist muscles  
        parm.actB = [0.7 0.9 0.7];   % activation level (0..1) of the antagonist muscles  
        axes(axesC);
        [SxC,SyC,VxC,VyC,thetaC,omegaC] = MultipleTrials(SxC,SyC,VxC,VyC,thetaC,omegaC);
        title('Extreme Co-contraction', 'FontWeight','bold', 'FontSize',18);   
        drawnow;
        
        % add movie frame
        if exist('mov','var')
            mov = addframe( mov, getframe(gcf) );
            
            % pad the first frame out to one second
            if (tframe==0)
                for count=2:fps
                    mov = addframe( mov, getframe(gcf) );
                end
            end
            
        end

    end
    
    if exist('mov','var')
        mov = close(mov);    
    end
    
    return

        
    function [Sx1,Sy1,Vx1,Vy1,theta1,omega1] = MultipleTrials(Sx0,Sy0,Vx0,Vy0,theta0,omega0) 

        % init return values
        Sx1 = zeros(ntrials,3);
        Sy1 = zeros(ntrials,3);
        Vx1 = zeros(ntrials,3);
        Vy1 = zeros(ntrials,3);
        theta1 = zeros(ntrials,3);
        omega1 = zeros(ntrials,3);
        
        % plot origin crosshairs
        plot(0,0,'+k','MarkerSize',15,'LineWidth',1);
        axis equal;
        ylim([-3 3]);
        xlim([-2,3]);
        grid on
        xlabel('X coordinate (m)', 'FontSize',14);
        ylabel('Y coordinate (m)', 'FontSize',14);
        set(gca,'XTick', [-3 -2 -1 0 1 2 3]);
        set(gca,'YTick', [-3 -2 -1 0 1 2 3]);
        hold on;
        text(2.9,-2.8,[' ',num2str(tframe,'%5.2f sec')], 'Color',[0.7 0.7 0.7], 'FontName','-*-times-bold-r-*-*-24', 'HorizontalAlignment','right');

        for n=1:ntrials
            % determine the endpoints of the initial limb position (for plotting)
            [Px,Py,Qx,Qy] = endpoints(Sx0(n,:),Sy0(n,:),parm.L,theta0(n,:));

            % plot initial limb position for the current time frame
            plot ( [Px(1,1), Qx(1,1)] , [Py(1,1), Qy(1,1)] , 'bo-', ...
                   [Px(1,2), Qx(1,2)] , [Py(1,2), Qy(1,2)] , 'bo-', ...
                   [Px(1,3), Qx(1,3)] , [Py(1,3), Qy(1,3)] , 'bo-' ); 
            %ylim([-3 3]);
            %xlim([-2,3]);
            %axis equal;

            % integrate    
            [t,Sx,Sy,Vx,Vy,theta,omega]=marm3ode([tframe, tframe+tstep],Sx0(n,:),Sy0(n,:),Vx0(n,:),Vy0(n,:),theta0(n,:),omega0(n,:),parm);
            
            % return final results for use as initial conditions at next time step
            Sx1(n,:) = Sx(end,:);
            Sy1(n,:) = Sy(end,:);
            Vx1(n,:) = Vx(end,:);
            Vy1(n,:) = Vy(end,:);
            theta1(n,:) = theta(end,:);
            omega1(n,:) = omega(end,:);           
                       
        end
        hold off;
    end

    function [Sx,Sy,Vx,Vy,theta,omega] = RandomInitialValues(L,psiminA,psimaxA)            
        Sx = [0 0 0];           % euclidean position of centre of mass (x-component)
        Sy = [0 0 0];           % euclidean position of centre of mass (y-component)
        Vx = [0 0 0];           % linear velocity of centre of mass (x-component)
        Vy = [0 0 0];           % linear velocity of centre of mass (y-component)
        omega = [0 0 0];        % angular velocity limb segments (in radians per sec)

        % randomise joint 1 angle
        thetamin1 = pi + pi - psiminA(1);       
        thetamax1 = pi + pi - psimaxA(1);
        theta(1) = (thetamax1-thetamin1)*rand + thetamin1;

        % randomise joint 2 angle
        thetamin2 = pi + theta(1) - psiminA(2);
        thetamax2 = pi + theta(1) - psimaxA(2);
        theta(2) = (thetamax2-thetamin2)*rand + thetamin2;

        % randomise joint 3 angle
        thetamin3 = pi + theta(2) - psiminA(3);
        thetamax3 = pi + theta(2) - psimaxA(3);
        theta(3) = (thetamax3-thetamin3)*rand + thetamin3;
        
        % recalculate euclidean limb positions Sx and Sy
        [Sx,Sy] = midpoints(L,theta);
    end
    

    function [Sx,Sy] = midpoints(L,theta)
        % returns the midpoints of the three arm segments having the given
        % lengths (L) and orientations (theta) when the endpoint of the first segment 
        % is anchored at {0,0}.
        Sx(1) = -L(1)/2 * cos(theta(1));
        Sy(1) = -L(1)/2 * sin(theta(1));
        Sx(2) = -L(1) * cos(theta(1)) - L(2)/2 * cos(theta(2));
        Sy(2) = -L(1) * sin(theta(1)) - L(2)/2 * sin(theta(2));
        Sx(3) = -L(1) * cos(theta(1)) - L(2) * cos(theta(2)) - L(3)/2 * cos(theta(3));
        Sy(3) = -L(1) * sin(theta(1)) - L(2) * sin(theta(2)) - L(3)/2 * sin(theta(3));
    end


    function [Px,Py,Qx,Qy] = endpoints(Sx,Sy,L,theta)
        % returns the endpoints of the three arm segments
        R = ones(size(Sx,1),1) * L/2;
        Px = Sx + ( R .* cos(theta) ) ;
        Py = Sy + ( R .* sin(theta) ) ;
        Qx = Sx - ( R .* cos(theta) ) ;
        Qy = Sy - ( R .* sin(theta) ) ;
    end

end


