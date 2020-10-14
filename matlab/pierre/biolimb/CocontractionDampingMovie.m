% COCONTRACTIONDAMPINGMOVIE generates an animated movie (avi) of the motion of
% the three-link biomechanical limb under conditions of medium, strong and
% extreme levels of muscle co-contraction. The movie demonstrates co-contraction
% of antagonist muscles modulating the effect of muscle damping in the limb.
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
function CocontractionDampingMovie()
   
    % animation frame rate
    fps = 20;

    % save the animation as a movie file (if true) 
    if true
        mov = avifile('CocontractionDampingMovie.avi', 'FPS',fps);
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
    parm.psimidA = (parm.psiminA+parm.psimaxA)/2;   % resting joint angle (length) of muscle A
    parm.psimidB = (parm.psiminB+parm.psimaxB)/2;   % resting joint angle (length) of muscle B

    % Compute trajectory of limb under MEDIUM co-contraction
    parm.actA = [0.3 0.1 0.3];                     % activation level (0..1) of the agonist muscles  
    parm.actB = [0.1 0.3 0.1];                     % activation level (0..1) of the antagonist muscles  
    [t,PxA,PyA,QxA,QyA] = IntegrateLimb();

    % Compute trajectory of limb under STRONG co-contraction
    parm.actA = [0.6 0.4 0.6];                     % activation level (0..1) of the agonist muscles  
    parm.actB = [0.4 0.6 0.4];                     % activation level (0..1) of the antagonist muscles  
    [t,PxB,PyB,QxB,QyB] = IntegrateLimb();

    % Compute trajectory of limb under EXTREME co-contraction
    parm.actA = [0.9 0.7 0.9];                     % activation level (0..1) of the agonist muscles  
    parm.actB = [0.7 0.9 0.7];                     % activation level (0..1) of the antagonist muscles  
    [t,PxC,PyC,QxC,QyC] = IntegrateLimb();
  
    % animate the results
    figure('name','Muscle Co-contraction', 'numbertitle','off', 'position',2*[rand*100 rand*100 480 360], 'color','w');

    axes_background = axes('Position',[0,0,1,1]);
    image(imread('CocontractionDampingBackground.png'));
    axis off;
    
    % initiate plot for arm A
    axes('Position',[0.05,0.4,0.3,0.4]); 
        i=1;
        plotA = plot ( [PxA(i,1), QxA(i,1)] , [PyA(i,1), QyA(i,1)] , 'bo-', ...
                       [PxA(i,2), QxA(i,2)] , [PyA(i,2), QyA(i,2)] , 'bo-' , ...
                       [PxA(i,3), QxA(i,3)] , [PyA(i,3), QyA(i,3)] , 'bo-' );
        axis equal
        ylim([-3 2]);
        xlim([-0.5 3]);
        set(gca,'XLimMode','manual');
        grid on
        xlabel('X coordinate (m)', 'FontSize',14);
        ylabel('Y coordinate (m)', 'FontSize',14);
        set(gca,'XTick', [-3 -2 -1 0 1 2 3]);
        set(gca,'YTick', [-3 -2 -1 0 1 2 3]);
        title('Medium Co-contraction', 'FontWeight','bold', 'FontSize',18)
        timeA = text(2.9,-2.8,[' ',num2str(t(1),'%5.2f sec')], 'Color',[0.7 0.7 0.7], 'FontName','-*-times-bold-r-*-*-24', 'HorizontalAlignment','right');

    % initiate plot for arm B
    axes('Position',[0.51-0.15,0.4,0.3,0.4]);  
        i=1;
        plotB = plot ( [PxB(i,1), QxB(i,1)] , [PyB(i,1), QyB(i,1)] , 'bo-', ...
                       [PxB(i,2), QxB(i,2)] , [PyB(i,2), QyB(i,2)] , 'bo-', ...
                       [PxB(i,3), QxB(i,3)] , [PyB(i,3), QyB(i,3)] , 'bo-', ...
                       'LineWidth',1 );
        axis equal
        ylim([-3 2]);
        xlim([-0.5 3]);
        set(gca,'XLimMode','manual');
        grid on
        xlabel('X coordinate (m)', 'FontSize',14);
        ylabel('Y coordinate (m)', 'FontSize',14);
        set(gca,'XTick', [-3 -2 -1 0 1 2 3]);
        set(gca,'YTick', [-3 -2 -1 0 1 2 3]);
        title('Strong Co-contraction', 'FontWeight','bold', 'FontSize',18)
        timeB = text(2.9,-2.8,[' ',num2str(t(1),'%5.2f sec')], 'Color',[0.7 0.7 0.7], 'FontName','-*-times-bold-r-*-*-24', 'HorizontalAlignment','right');

    % initiate plot for arm C
    axes('Position',[0.97-0.3,0.4,0.3,0.4]);  
        i=1;
        plotC = plot ( [PxC(i,1), QxC(i,1)] , [PyC(i,1), QyC(i,1)] , 'bo-', ...
                       [PxC(i,2), QxC(i,2)] , [PyC(i,2), QyC(i,2)] , 'bo-' , ...
                       [PxC(i,3), QxC(i,3)] , [PyC(i,3), QyC(i,3)] , 'bo-' );
        axis equal
        ylim([-3 2]);
        xlim([-0.5 3]);
        set(gca,'XLimMode','manual');
        grid on
        xlabel('X coordinate (m)', 'FontSize',14);
        ylabel('Y coordinate (m)', 'FontSize',14);
        set(gca,'XTick', [-3 -2 -1 0 1 2 3]);
        set(gca,'YTick', [-3 -2 -1 0 1 2 3]);
        title('Extreme Co-contraction', 'FontWeight','bold', 'FontSize',18)
        timeC = text(2.9,-2.8,[' ',num2str(t(1),'%5.2f sec')], 'Color',[0.7 0.7 0.7], 'FontName','-*-times-bold-r-*-*-24', 'HorizontalAlignment','right');

    drawnow;

    if exist('mov','var')
       % show the initial conditions for the first second
       for ii=1:fps
            mov = addframe( mov, getframe(gcf) );
       end
    end
        
        
    % animate both arms simultaneously
    for i = 2:numel(t)
        % update arm A
        set(plotA(1),'XData', [PxA(i,1), QxA(i,1)]);
        set(plotA(1),'YData', [PyA(i,1), QyA(i,1)]);
        set(plotA(2),'XData', [PxA(i,2), QxA(i,2)]);
        set(plotA(2),'YData', [PyA(i,2), QyA(i,2)]);
        set(plotA(3),'XData', [PxA(i,3), QxA(i,3)]);
        set(plotA(3),'YData', [PyA(i,3), QyA(i,3)]);
        set(timeA,'String', [' ',num2str(t(i),'%5.2f sec')]);

        % update arm B
        set(plotB(1),'XData', [PxB(i,1), QxB(i,1)]);
        set(plotB(1),'YData', [PyB(i,1), QyB(i,1)]);
        set(plotB(2),'XData', [PxB(i,2), QxB(i,2)]);
        set(plotB(2),'YData', [PyB(i,2), QyB(i,2)]);
        set(plotB(3),'XData', [PxB(i,3), QxB(i,3)]);
        set(plotB(3),'YData', [PyB(i,3), QyB(i,3)]);
        set(timeB,'String', [' ',num2str(t(i),'%5.2f sec')]);

        % update arm C
        set(plotC(1),'XData', [PxC(i,1), QxC(i,1)]);
        set(plotC(1),'YData', [PyC(i,1), QyC(i,1)]);
        set(plotC(2),'XData', [PxC(i,2), QxC(i,2)]);
        set(plotC(2),'YData', [PyC(i,2), QyC(i,2)]);
        set(plotC(3),'XData', [PxC(i,3), QxC(i,3)]);
        set(plotC(3),'YData', [PyC(i,3), QyC(i,3)]);
        set(timeC,'String', [' ',num2str(t(i),'%5.2f sec')]);

        drawnow;
        pause(1/fps);        
        
        if exist('mov','var')
            mov = addframe( mov, getframe(gcf) );
        end

    end

    if exist('mov','var')
        mov = close(mov);    
    end

    
    function [t,Px,Py,Qx,Qy] = IntegrateLimb()
        % initial values
        Sx = [0 0 0];              % euclidean position of centre of mass (x-component)
        Sy = [-0.5 -1.5 -2.5];     % euclidean position of centre of mass (y-component)
        Vx = [0 0 0];              % linear velocity of centre of mass (x-component)
        Vy = [0 0 0];              % linear velocity of centre of mass (y-component)
        theta = [pi/2 pi/2 pi/2];  % angular position of centre of mass (in radians)
        omega = [0 0 0];           % angular velocity of centre of mass (in radians per sec)

        % integrate
        tstep = 1/fps;
        trange = [0:tstep:10];
        [t,Sx,Sy,Vx,Vy,theta,omega]=marm3ode(trange,Sx,Sy,Vx,Vy,theta,omega,parm);    
        
        % determine the endpoints of the rods (for plotting)
        [Px,Py,Qx,Qy] = endpoints(Sx,Sy,parm.L,theta);
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


