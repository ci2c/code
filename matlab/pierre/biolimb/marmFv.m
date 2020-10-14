% F = marmFv(omega, k_v) returns the maximum normalised force exerted by
% the contractile element according to the force-velocity relationship.
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
%
function F = marmFv(omega, k_v)
    F = 1.3130 * tanh(exp(k_v.*omega));     % Here (e^2+1)/(e^2-1)=1.313035286
end
