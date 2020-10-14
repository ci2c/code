% [Tm,psi,dpsi_dt] = marmMuscleTorque(theta,omega,Otheta,parm)
% returns the muscle torques Tm=[Tm1,...,TmN] induced on each of N arm segments
% as well as the joint angles psi=[psi1,...,psiN] and joint opening velocities
% dpsi_dt=[dpsi1/dt,...,dpsiN/dt] wrt the A muscle
% where
%   theta = [theta1,...,thetaN] = angular orientation of each arm element 
%   omega = [omega1,...,omegaN] = angular velocity of each arm element = domega/dt
%   parm.actA = [actA1,..,actAN] = activation level (0..1) of the A muscles (flexors).  
%   parm.actB = [actB1,..,actBN] = activation level (0..1) of the B muscles (extensors).  
%   parm.FmaxA = [FmaxA1,..,FmaxAN] = maximal force of the A muscles.  
%   parm.FmaxB = [FmaxB1,..,FmaxBN] = maximal force of the B muscles.
%   parm.KpeA = [KpeA1,...,KpeAN] = Passive Force-Length parameters for the A muscles.
%   parm.KpeB = [KpeB1,...,KpeBN] = Passive Force-Length parameters for the B muscles.
%   parm.KlA = [KlA1,...,KlAN] = Active Force-Length parameters for the A muscles.
%   parm.KlB = [KlB1,...,KlBN] = Active Force-Length parameters for the B muscles.
%   parm.KvA = [KvA1,...,KvAN] = Active Force-Velocity parameters for the A muscles.
%   parm.KvB = [KvB1,...,KvBN] = Active Force-Velocity parameters for the B muscles.
%   parm.momarmA = [momarmA1,...,momarmAN)] = moment arm of muscle insertion a (from proximal muscle A)
%   parm.momarmB = [momarmB1,...,momarmBN)] = moment arm of muscle insertion b (from proximal muscle B)
%   parm.momarmC = [momarmC1,...,momarmCN)] = moment arm of muscle insertion c (from distal muscle A)
%   parm.momarmD = [momarmD1,...,momarmDN)] = moment arm of muscle insertion d (from distal muscle B)
%   parm.psiminA = [psiminA1,...,psiminAN)] = lower limit of each joint angle wrt muscle A
%   parm.psimaxA = [psimaxA1,...,psimaxAN)] = upper limit of each joint angle wrt muscle A
%   parm.psiminB = 2*pi-parm.psimaxA = lower limit of each joint angle wrt muscle B
%   parm.psimaxB = 2*pi-parm.psiminA = upper limit of each joint angle wrt muscle B
%   parm.psimidA = [psimidA1,...,psimidAN)] = resting joint angle (length) of muscle A
%   parm.psimidB = [psimidB1,...,psimidBN)] = resting joint angle (length) of muscle B
%   parm.Otheta = angular orientation of the contact point (treated as though it were another arm element)
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
%
function [Tm,psi,dpsi_dt] = marmMuscleTorque(theta,omega,parm)

    % thetashift contains the theta values of each element's proximal neighbour
    thetashift = circshift(theta,[0,1]); 
    thetashift(1) = parm.Otheta;
    
    % Compute the joint angles (psi) for muscle A
    % We assume the length of the muscle A is proportional to its joint angle.
    psiA = pi + thetashift - theta;

    % Restrict the joint angles within their legal limits to prevent muscle forces
    % from straying across asymptotic boundaries (especially Fpe).
    psiA = max(psiA, parm.psiminA);
    psiA = min(psiA, parm.psimaxA);

    % Compute the matching joint angles for the extensor (B) muscles.
    psiB = 2*pi - psiA;
    
    % omegashift contains the omega values of each element's proximal neighbour
    omegashift = circshift(omega,[0,1]); 
    omegashift(1) = 0;  % the contact point with external world always has zero angular velocity

    % Compute the joint opening velocity (dpsi_dt) for muscle A.
    % We assume the lengthening velocity of muscle A is proportional to the joint opening velocity.
    % The joint opening velocity for the muscle B is -dpsi_dt.
    dpsi_dt = omegashift - omega;

    % Active muscle force-length relationship
    Fl_a = marmFl(psiA, parm.psimidA, parm.KlA);     % muscle A
    Fl_b = marmFl(psiB, parm.psimidB, parm.KlB);     % muscle B

    % Passive muscle force-length relationship
    Fpe_a = marmFpe(psiA, parm.psiminA,  parm.psimaxA,  parm.KpeA);     % muscle A
    Fpe_b = marmFpe(psiB, parm.psiminB,  parm.psimaxB,  parm.KpeB);     % muscle B

    % Enforce an upper limit on extreme forces to prevent inf calculations
    Fpe_a = min(Fpe_a, 1e5); 
    Fpe_b = min(Fpe_b, 1e5);
    
    % Active muscle force-velocity relationship
    Fv_a = marmFv( dpsi_dt, parm.KvA);    % muscle A
    Fv_b = marmFv(-dpsi_dt, parm.KvB);    % muscle B   

    % Compute total force exerted by each muscle
    F_a = parm.actA .* parm.FmaxA .* Fl_a .* Fv_a  +  parm.FmaxA .* Fpe_a;
    F_b = parm.actB .* parm.FmaxB .* Fl_b .* Fv_b  +  parm.FmaxB .* Fpe_b;

    % Each element's distal muscle A force (F_c) corresponds to its distal
    % neighbour's proximal muscle A force (F_a)
    F_c = circshift(F_a,[0,-1]);
    F_c(end) = 0; 

    % Each element's distal muscle B force (F_d) corresponds to its distal
    % neighbour's proximal muscle B force (F_b)
    F_d = circshift(F_b,[0,-1]);
    F_d(end) = 0; 
    
    % Compute the muscle torque on the centre of mass of each rod.
    Tm = F_a .* parm.momarmA  +  F_b .* parm.momarmB  +  F_c .* parm.momarmC  +  F_d .* parm.momarmD;
end
