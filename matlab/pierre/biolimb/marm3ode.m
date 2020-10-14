function [t,Sx,Sy,Vx,Vy,theta,omega] = marm3ode(trange,Sx0,Sy0,Vx0,Vy0,theta0,omega0,parm)  
% [t,X]=marm3ode(trange,Sx0,Sy0,Vx0,Vy0,theta0,omega0,parm) solves the ODE for a three-link arm with muscles
% where
%       parm.L  = [l1,l2,l3] = lengths of arm segments
%       parm.M  = [m1,m2,m3] = masses of arm segments
%       parm.I  = [i1,i2,i3] = moments of inertia of arm segments
%       parm.Gx = [gx1,gx2,gx3] = external linear forces on each arm segment (x component)
%       parm.Gy = [gy1,gy2,gy3] = external linear forces on each arm segment (y component)
%       parm.Te = [te1,te2,te3] = external torques on each arm segment
%       parm.Ox = position of arm contact point (typically Ox=0)
%       parm.Oy = position of arm contact point (typically Oy=0)
%       parm.Otheta = angular orientation of contact point (typically Otheta=pi);
%       parm.Kf  = [kf1,kf2,kf3] = linear damping factor applied to each arm segment
%       parm.Kt  = [kt1,kt2,kt3] = torsional damping factor applied to each arm segment
%       parm.Ks  = mean(parm.M) = joint-spring stiffness constant
%       parm.Kd  = mean(parm.M) = joint-spring damping constant
%       parm.FQx = external linear force at tip (Q) of arm segment (x component)
%       parm.FQy = external linear force at tip (Q) of arm segment (y component)
%       parm.actA  = [actA1,actA2,actA3] = activation levels (range is 0 to 1) of muscles A (flexors)
%       parm.actB  = [actB1,actB2,actB3] = activation levels (range is 0 to 1) of muscles B (extensors)
%       parm.FmaxA = [FmaxA1,FmaxA2,FmaxA3] = maximal force of the muscles A
%       parm.FmaxB = [FmaxB1,FmaxB2,FmaxB3] = maximal force of the muscles B
%       parm.KpeA  = [KpeA1,KpeA2,KpeA3] = PE Force-Length parameters for muscles A
%       parm.KpeB  = [KpeB1,KpeB2,KpeB3] = PE Force-Length parameters for muscles B
%       parm.KlA   = [KlA1,KlA2,KlA3]= CE Force-Length parameters for muscle A
%       parm.KlB   = [KlB1,KlB2,KlB3]= CE Force-Length parameters for muscle B
%       parm.KvA   = [KvA1,KvA2,KvA3] = CE Force-Velocity parameters for muscles A
%       parm.KvB   = [KvB1,KvB2,KvB3] = CE Force-Velocity parameters for muscles B
%       parm.phiA  = [phiA1,phiA2,phiA3] = angles of muscle insertion a (proximal muscle A, typically phiA<0)
%       parm.phiB  = [phiB1,phiB2,phiB3] = angles of muscle insertion b (proximal muscle B, typically phiB>0)
%       parm.phiC  = [phiC1,phiC2,phiC3] = angles of muscle insertion c (distal muscle A, typically phiC>0)
%       parm.phiD  = [phiD1,phiD2,phiD3] = angles of muscel insertion d (distal muscle B, typically phiD<0)
%       parm.psiminA = [psiminA1,psiminA2,psiminA3] = joint angle lower limits wrt muscle A
%       parm.psimaxA = [psimaxA1,psimaxA2,psimaxA3] = joint angle upper limits wrt muscle A
%       parm.psiminB = 2*pi-parm.psimaxB = joint angle lower limits wrt muscle B
%       parm.psimaxB = 2*pi-parm.psiminB = joint angle upper limits wrt muscle B
%       parm.psimidA = [psimidA1,psimidA2,psimidA3] = resting joint angles (lengths) of muscle A
%       parm.psimidB = [psimidB1,psimidB2,psimidB3] = resting joint angles (lengths) of muscle B
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/

    % Calculate the moment arm of each muscle attachment site.
    parm.momarmA = -parm.L/2 .* sin(parm.phiA);
    parm.momarmB = -parm.L/2 .* sin(parm.phiB);
    parm.momarmC = -parm.L/2 .* sin(parm.phiC);
    parm.momarmD = -parm.L/2 .* sin(parm.phiD);

    % Numerical integration is done using ode113 which gives more accuracy than ode45.
    [t,X] = ode113(@odefun,trange, [Sx0,Sy0,theta0,Vx0,Vy0,omega0] );
    
    % Extract the integration results from X
    Sx    = X(:, 1:3);
    Sy    = X(:, 4:6);
    theta = X(:, 7:9);
    Vx    = X(:,10:12);
    Vy    = X(:,13:15);
    omega = X(:,16:18);
    

    % This ODE function defines the equations of motion for a three-segment limb.
    % Herein, each limb segment is referred to as a “rod”.
    function dXdt = odefun(t,X)
        % Extract incoming parameters
        Sx    = X(1:3)';        % Sx = [Sx1,Sx2,Sx3] = positions of centre-of-masses (x-component)
        Sy    = X(4:6)';        % Sy = [Sy1,Sy2,Sy3] = positions of centre-of-masses (y-component)
        theta = X(7:9)';        % theta = [theta1,theta2,theta3] = angular orientations of rods
        Vx    = X(10:12)';      % Vx = [Vx1,Vx2,Vx3] = linear velocities of centre-of-masses (x-component)
        Vy    = X(13:15)';      % Vy = [Vy1,Vy2,Vy3] = linear velocities of centre-of-masses (y-component)
        omega = X(16:18)';      % omega = [omega1,omega2,omega3] = angular velocities of rods
        
        % Local constants
        Rx = parm.L/2 .* cos(theta);            % radius (x-component)
        Ry = parm.L/2 .* sin(theta);            % radius (y-component) 
        OmegaOmegaRx = omega .* omega .* Rx;    % a common expression
        OmegaOmegaRy = omega .* omega .* Ry;    % a common expression

        % Translational damping forces (Fdx,Fdy) are proportional to the translational velocity (Vx,Vy)
        Fdx = -parm.Kf .* Vx;
        Fdy = -parm.Kf .* Vy;

        % Angular damping torques (Td) are proportional to angular velocity (omega)
        Td = -parm.Kt .* omega;
        
        % Calculate the combined muscle torque about each rod.
        Tm = marmMuscleTorque(theta, omega, parm);

        % Calculate end-positions of the rods (P represents the proximal endpoint, Q represents the distal endpoint)
        Px = Sx+Rx ;        % Px(i)=x of i'th rod
        Py = Sy+Ry ;        % Py(i)=y of i'th rod
        Qx = Sx-Rx ;        % Qx(i)=x of i'th rod
        Qy = Sy-Ry ;        % Qy(i)=y of i'th rod

        % VPx,Vpy is the translational velocity at P of i'th rod
        VPx = Vx - Ry.*omega;   % VPx(i)=VPx of i'th rod
        VPy = Vy + Rx.*omega;   % VPy(i)=VPy of i'th rod

        % VQx,VQy is the translational velocity at Q of i'th rod
        VQx = Vx + Ry.*omega;   % VQx(i)=VQx of i'th rod
        VQy = Vy - Rx.*omega;   % VQx(i)=VQx of i'th rod

        % FJx(i) is the joint spring force at P of ith element
        FJx = [ parm.Ks*(Px(1) - 0     ) + parm.Kd*(VPx(1) - 0     )  ,      % P1
                parm.Ks*(Px(2) - Qx(1) ) + parm.Kd*(VPx(2) - VQx(1))  ,      % P2
                parm.Ks*(Px(3) - Qx(2) ) + parm.Kd*(VPx(3) - VQx(2))  ];     % P3

        % FJx(i) is the joint spring force at P of ith element
        FJy = [ parm.Ks*(Py(1) - 0     ) + parm.Kd*(VPy(1) - 0     )  ,      % P1
                parm.Ks*(Py(2) - Qy(1) ) + parm.Kd*(VPy(2) - VQy(1))  ,      % P2
                parm.Ks*(Py(3) - Qy(2) ) + parm.Kd*(VPy(3) - VQy(2))  ];     % P3
        

        % Equations of motion (rod 1)
        % (1a)  m1 * dV1x/dt - FP1x + FP2x = G1x + Fd1x
        % (2a)  m1 * dV1y/dt - FP1y + FP2y = G1y + Fd1y
        % (3a)  I1 * domega1/dt + R1y*FP1x - R1x*FP1y + R1y*FP2x - R1x*FP2y = T1e + Td1 + (T1a+T1b+T1c+T1d)
        %
        % Equations of motion (rod 2)
        % (1b)  m2 * dV2x/dt - FP2x + FP3x = G2x + Fd2x
        % (2b)  m2 * dV2y/dt - FP2y + FP3y = G2y + Fd2y
        % (3b)  I2 * domega2/dt + R2y*FP2x - R2x*FP2y + R2y*FP3x - R2x*FP3y = T2e + Td2 + (T2a+T2b+T2c+T2d)
        %
        % Equations of motion (rod 3)
        % (1c)  m3 * dV3x/dt - FP3x        = G3x + Fd3x
        % (2c)  m3 * dV3y/dt - FP3y        = G3y + Fd3y
        % (3c)  I3 * domega3/dt + R3y*FP3x - R3x*FP3y = T3e + Td3 + (T3a+T3b+T3c+T3d) + R3y*FQ3x - R3x*FQ3y
        %
        % Joint Constraints (rods 1+2)
        % (4a)  dV1x/dt - dV2x/dt + R1y*domega1/dt + R2y*domega2/dt = -omega1*omega1*R1x - omega2*omega2*R2x
        % (5a)  dV1y/dt - dV2y/dt - R1x*domega1/dt - R2x*domega2/dt = -omega1*omega1*R1y - omega2*omega2*R2y
        %
        % Joint Constraints (rods 2+3)
        % (4b)  dV2x/dt - dV3x/dt + R2y*domega2/dt + R3y*domega3/dt = -omega2*omega2*R2x - omega3*omega3*R3x
        % (5b)  dV2y/dt - dV3y/dt - R2x*domega2/dt - R3x*domega3/dt = -omega2*omega2*R2y - omega3*omega3*R3y
        %
        % Contact Constraints (rod 1 only)
        % (6)  dV1x/dt - R1y*domega1/dt = omega1*omega1*R1x
        % (7)  dV1y/dt - R1x*domega1/dt = omega1*omega1*R1y

        %      dV1x   dv2x   dv3x  |  dV1y   dV2y   dV3y  | domega1 domega2 domega3 | FP1x   FP2x   FP3x | FP1y   FP2y   FP3y
        A = [parm.M(1)  0      0        0      0      0        0       0       0       -1      1      0      0      0      0   ;  % Eqn (1a) 
                 0  parm.M(2)  0        0      0      0        0       0       0        0     -1      1      0      0      0   ;  % Eqn (1b)
                 0      0  parm.M(3)    0      0      0        0       0       0        0      0     -1      0      0      0   ;  % Eqn (1c)
               
                 0      0      0    parm.M(1)  0      0        0       0       0        0      0      0     -1      1      0   ;  % Eqn (2a)
                 0      0      0        0  parm.M(2)  0        0       0       0        0      0      0      0     -1      1   ;  % Eqn (2b)               
                 0      0      0        0      0  parm.M(3)    0       0       0        0      0      0      0      0     -1   ;  % Eqn (2c)

                 0      0      0        0      0      0    parm.I(1)   0       0     Ry(1)  Ry(1)     0  -Rx(1) -Rx(1)     0   ;  % Eqn (3a)               
                 0      0      0        0      0      0        0   parm.I(2)   0        0   Ry(2)  Ry(2)     0  -Rx(2) -Rx(2)  ;  % Eqn (3b)               
                 0      0      0        0      0      0        0       0   parm.I(3)    0      0   Ry(3)     0      0  -Rx(3)  ;  % Eqn (3c)               

                 1     -1      0        0      0      0     Ry(1)   Ry(2)      0        0      0      0      0      0      0   ;  % Eqn (4a)
                 0      0      0        1     -1      0    -Rx(1)  -Rx(2)      0        0      0      0      0      0      0   ;  % Eqn (5a)

                 0      1     -1        0      0      0        0    Ry(2)   Ry(3)       0      0      0      0      0      0   ;  % Eqn (4b)
                 0      0      0        0      1     -1        0   -Rx(2)  -Rx(3)       0      0      0      0      0      0   ;  % Eqn (5b)

                 1      0      0        0      0      0    -Ry(1)      0       0        0      0      0      0      0      0   ;  % Eqn (6)
                 0      0      0        1      0      0     Rx(1)      0       0        0      0      0      0      0      0  ];  % Eqn (7)
           

        B = [ parm.Gx(1) + Fdx(1) ;                                                       % Eqn (1a)
              parm.Gx(2) + Fdx(2) ;                                                       % Eqn (1b)
              parm.Gx(3) + Fdx(3) + parm.FQx;                                             % Eqn (1c)
              
              parm.Gy(1) + Fdy(1) ;                                                       % Eqn (2a)
              parm.Gy(2) + Fdy(2) ;                                                       % Eqn (2b)
              parm.Gy(3) + Fdy(3) + parm.FQy ;                                            % Eqn (2c)
              
              parm.Te(1) + Td(1) + Tm(1) ;                                                % Eqn (3a)
              parm.Te(2) + Td(2) + Tm(2) ;                                                % Eqn (3b)
              parm.Te(3) + Td(3) + Tm(3) + Ry(3)*parm.FQx - Rx(3)*parm.FQy ;              % Eqn (3c)
              
              -OmegaOmegaRx(1) - OmegaOmegaRx(2) + FJx(2)/parm.M(1) + FJx(2)/parm.M(2) ;  % Eqn (4a)
              -OmegaOmegaRy(1) - OmegaOmegaRy(2) + FJy(2)/parm.M(1) + FJy(2)/parm.M(2) ;  % Eqn (5a)

              -OmegaOmegaRx(2) - OmegaOmegaRx(3) + FJx(3)/parm.M(2) + FJx(3)/parm.M(3) ;  % Eqn (4b)
              -OmegaOmegaRy(2) - OmegaOmegaRy(3) + FJy(3)/parm.M(2) + FJy(3)/parm.M(3) ;  % Eqn (5b)
              
              OmegaOmegaRx(1) - FJx(1)/parm.M(1) ;                                        % Eqn (6)
              OmegaOmegaRy(1) - FJy(1)/parm.M(1) ];                                       % Eqn (7)

        % Solve A*X=B numerically
        Y = A\B;

        % Return the results
        dXdt = [ Vx' ; Vy' ;  omega' ; Y(1:9) ]; 

    end


end
