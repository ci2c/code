function yC = dop54d_Lag(phifun,Comp,t,varargin)
% ---------------------------
% This function uses the continuous parameters table to evaluate
% the Comp-th component of the solution at t.
%
% INPUT
% -----
% phiFcn : is the name of the function which evaluate the y values
%          for all t < t0
% Comp   : is the indice of the variable for which the time lag value 
%          must be evaluated
% t      : the variable of the system
%
% OUTPUT
% ------
% yC is the value of the fonction y with indice Comp evaluated at t
% ------------
% See :
%   Solving Differential Equations I  Nonstiff Problems
%  	E. Hairer S.P. Norsett G.Wanner
%	Springer Verlag ISBN  3-540-17145-2  ISBN 0-387-17145-2
%   and
%   Solving Differential Equations II  Stiff and Differential-Algebric Problems
%	E. Hairer G.Wanner
%   Springer Verlag ISBN  3-540-53775-9  ISBN 0-387-53775-9
% See also
%   http://www.unige.ch/~hairer/software.html
%
%	Denis Bichsel 2010-02-20
% ---------------------------

% Search for the interval which contains t  

global tCont_dop54d yCont_dop54d hCont_dop54d

IndMax = length(tCont_dop54d);
if IndMax == 0
  yC = feval(phifun,Comp,t,varargin{:});
else
  Ind    = 1;
  while Ind <= IndMax && t > tCont_dop54d(Ind) 
    Ind = Ind + 1;
  end
  if Ind > 1  
    Ind = Ind -1;
  end
  if t < tCont_dop54d(Ind)  % --> phi
    yC = feval(phifun,Comp,t,varargin{:});
  else
    t1  = tCont_dop54d(Ind);
    h   = hCont_dop54d(Ind);
    S   = (t-t1)/h;    % S is theta in the book
    S1  = 1-S;
    yC  = yCont_dop54d(Ind,Comp,1) + S*(yCont_dop54d(Ind,Comp,2) + ...
          S1*(yCont_dop54d(Ind,Comp,3) + S*(yCont_dop54d(Ind,Comp,4) + ... 
          S1*yCont_dop54d(Ind,Comp,5))));        
  end
end

















