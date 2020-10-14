% F = marmFl(psi, psi_mid, k_l) returns the normalised maximal force exerted
% by the contractile element according to the muscles force-length relationship
% where
%      psi = muscle length (in terms of joint angle).
%      psi_mid = resting muscle length (in terms of joint angle).
%      k_l = slope of gaussian force-length curve.
%
% Reference:
%      Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
%      and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.
%
% Copyright (C) 2012 Stewart Heitmann <heitmann@ego.id.au>
%     This program is distributed freely under the terms of the GNU General 
%     Public License (version 3). See http://www.gnu.org/licenses/
%
function F = marmFl(psi, psi_mid, k_l)
        F = exp( -(psi-psi_mid).^2 ./ k_l );
end
