The matlab scripts herein were used to simulate the three-link biomechanical
limb published in 

  Heitmann, Ferns and Breakspear (2012) Muscle co-contraction modulates damping
  and joint stability in a three-link biomechanical limb. Front Neurorob. 5:5.

Please cite this reference when using this software.

These programs are distributed freely under the terms of the GNU
General Public License (version 3). A copy of the GNU General Public
License is provided (see GeneralPublicLicenseV3.txt) and is also
available on-line from <http://www.gnu.org/licenses/>.

Contents
--------
"ArmMuscleDemo.m" implements an interactive demo of a three-link biomechanical limb.

"CocontractionDampingMovie.m" generates an animated movie of muscle co-contraction
   modulating limb damping.

"CocontractionStabilityMovie.m" generates an animated movie of muscle co-contraction
   modulating bistability in joint position.

"marm3ode.m" integrates the equations of motion for the biomechanical limb.

"marmFl.m", "marmFpe.m" and "marmFv.m" define the force-length-velocity properties
   of contractile muscle tissue.

"marmMuscleTorque.m" is a help function used by "marm3ode.m" to translate muscle
   contraction forces into angular joint torques.

--
Stewart Heitmann <heitmann@ego.id.au>
23rd Jan 2012
