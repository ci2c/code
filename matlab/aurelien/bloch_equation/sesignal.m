% 
%	function [Msig,Mss] = sesignal(T1,T2,TE,TR,dfreq)
% 
%	Calculate the steady state signal at TE for a spin-echo
%	sequence, given T1,T2,TR,TE in ms.  Force the
%	transverse magnetization to zero before each excitation.
%	dfreq is the resonant frequency in Hz.  flip is in radians.
%

function [Msig,Mss] = sesignal(T1,T2,TE,TR,dfreq)

Rflip = yrot(pi/2);
Rrefoc = xrot(pi);

[Atr,Btr] = freeprecess(TR-TE,T1,T2,dfreq);
[Ate2,Bte2] = freeprecess(TE/2,T1,T2,dfreq);

% Neglect residual transverse magnetization prior to excitation.
Atr = [0 0 0;0 0 0;0 0 1]*Atr;

% Let 	M1 be the magnetization just before the 90.
%	M2 be just before the 180.
%	M3 be at TE.
%	M4 = M1
%
% then
%	M2 = Ate2*Rflip*M1 + Bte2
%	M3 = Ate2*Rrefoc*M2 + Bte2
%	M4 = Atr * M3 + Btr
%
% Solve for M3...
%

Mss = inv(eye(3)-Ate2*Rrefoc*Ate2*Rflip*Atr) * (Bte2+Ate2*Rrefoc*(Bte2+Ate2*Rflip*Btr));

Msig = Mss(1)+i*Mss(2);

