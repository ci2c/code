% F = marmFpe(psi, psi_min, psi_max, k_pe) returns the maximum normalised force
% exerted by the passive elastic element according to the force-length relationship
% where
%      psi = muscle length (joint angle)
%      psi_min = min muscle length (joint angle)
%      psi_max = max muscle length (joint angle)
%      k_pe = slope of the gaussian curve
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
%
function F = marmFpe(psi, psi_min, psi_max, k_pe)
    F = k_pe.*(psi - psi_min)./(psi_max - psi);
end
