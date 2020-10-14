function [varargout] = dop54d(OdeFcn,tspan,y0,varargin)
% ------------------------------------------------------------------------
% Solver Name :  dop54d.
% -----------
%
% Important: The variables:  "tCont_dop54d"  and "yCont_dop54"  are global
%            variables. Do'nt use these names for function or variables.
%
%	[tout,yout,ParamOut] = dop54d('OdeFcn',tspan,y0,options,varargin)
% integrates the system of ordinary differential equations y' = f(t,y)
% described by the M-file 'odefun.m', over the interval tinitial = tspan(1)
% to tfinal = tspan(end), with initial conditions y0 using a Dormand and
% Prince of order 5 with dense output of order 4. 	
%
%	INPUT:
% ------
% OdeFcn   : is a string ('OdeFcn') or a function_handle ( @OdeFcn ).
%
% tspan    : is a vector with 2 components : [tinitial tfinal] 
%            or with Ltspan > 2 components :[tinitial,t1,t2, ... , tfinal].
%            In the 2 components case, the output t values are not 
%            prescribed and the software will chose the t values 
%            in function of the options. In the other case, the solution 
%            will be returned at and only at the prescribed t values.
%            tspan must be strictly monotonic increasing or decreasing.
%
% y0       : Initial values vector.
% 
% varargin : Parameters to be send to the odefile function, and (or) to
%            the OutputFcn and (or) the DenseOutputFcn and (or) to the 
%            Events function.
%
% Important: If the first component of varargin is an options strucure 
%            returned by dopset, these options will be taken into account
%            by dop54d (see dopset). If the first component of varargin 
%            is not such a structure, this component of varargin, as all
%            the others will be passed down to : OdeFcn, OutputFcn,
%            DenseOutputFcn and EventFcn
%
% OUTPUT
% ------
% Case 1)  One output variable: Sol
%          Sol = dop54d(OdeFcn,tspan,y0,varargin)
% 
%          Sol.x      = t variable returned by dop54d (column vector)
%          Sol.y      = y solution evaluated at each component of t
%                       (one row vector per time step)
%          Sol.solver = 'dop54d'
%
%          If the options Stats is 'on'
%          Sol.stats.nsteps  = number of solver's steps (loops)
%          Sol.stats.nfailed = number of solver's failed steps
%          Sol.stats.nfevals = number of vfun evaluations
%
%          If an Events function is present,%          
%          Sol.te  = teout;  Times of the events
%          Sol.ye  = yeout;  y value at the events
%          Sol.ie  = ieout;  Indice of the function which produces the
%          events
%
% Case 2)  Two output variables: t and y
%          [t,y] = dop54d(OdeFcn,tspan,y0,varargin)
%          t = time at which the solution is evaluated
%          y = solution (one row vector par time step)
%
% Case 3)  Three output variables: t, y and S
%          [t,y,S] = dop54d(OdeFcn,tspan,y0,varargin)
%          t and y like in Case 2)
%          S like Sol.stats in Case 1)
%   
% Case 4)  Five output variables
%          [t,y,te,ye,ie] = dop54d(OdeFcn,tspan,y0,varargin}
%          t,y like case2
%          te,ye,ie like Sol.te, Sol.ye, Sol.ie in Case 1

% Case 5)  Six output variables
%          [t,y,te,ye,ie,Stats] = dop54d(OdeFcn,tspan,y0,varargin}
%          t,y,te,ye,ie like in Case 4
%          Stats.nsteps, Stats.nfailed, Case.nfevals like in Case 1
%  
% See DOP54 DOP853 DOP853D DOPGET DOPSET
% ------------------------------------------------------------------------
% This solver is essentially a portage of the FORTRAN code written by
% 
%    E. Hairer and G. Wanner
%    Universite de Geneve, Dept. de Mathematiques
%    CH-1211 Geneve 24, SWITZERLAND 
%    email:  hairer@divsun.unige.ch, wanner@divsun.unige.ch
%
%    See
%    Solving Differential Equations I  Nonstiff Problems
%  	 E. Hairer S.P. Norsett G.Wanner
%	   Springer Verlag ISBN  3-540-17145-2  ISBN 0-387-17145-2
%      and
%    Solving Differential Equations II  Stiff and 
%    Differential-Algebric Problems
%	   E. Hairer G.Wanner
%    Springer Verlag ISBN  3-540-53775-9  ISBN 0-387-53775-9
%
%    See also http://www.unige.ch/~hairer/software.html
%
% and an adaptation to the Matlab - Ocatve usage
%
% done by
%
%      Denis Bichsel
%      Rue des Deurres 58
%      2000 Neuchâtel
%      Suisse
%      email: dbichsel@infomaniak.ch
%	
% Version : 2010-03-10
% ------------------------------------------------------------------------
% Warning :
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS 
% IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED 
% TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR 
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% ------------------------------------------------------------------------  
Solver_Name = 'dop54d';

if (nargin <3 )    %  dopxx('odefile',tspan,y0) 
  error ([Solver_Name,': Number of input arguments must be at least equal to 3.']);
end   

% nargin >= 3
if ~isa (OdeFcn, 'function_handle') && ~(exist(OdeFcn) == 2)
  error ([Solver_Name,': First input argument must be a valid function handle or name']);        
else
  OdeFcnArg = abs(nargin(OdeFcn)) > 2;
end

if (~isvector (tspan) || length (tspan) < 2)
  error ([Solver_Name,': Second input argument must be a valid vector']);
elseif (~isvector (y0) || ~isnumeric (y0))
  error ([Solver_Name,': Third input argument must be a valid vector']);
end
% odefile, tspan, y0 existent

% Test de tspan
tspan  = tspan(:);    % Column vector
if length(tspan) < 2
  error([Solver_Name,': tspan must have more than one component']);
end
PosNeg = sign(tspan(end) - tspan(1));  % Monoticity checking 
if any(PosNeg*diff(tspan)) <= 0
  error([Solver_Name,': Time vector must be strictly monotonic']);
end
    
y0 = y0(:);           % Column vector

% Initialisation des arguments pour OdeFcn, OutputFcn et DenseOuputFcn
Args   = {};
OptUsr = [];
if  nargin >= 4
  if (~isstruct (varargin{1}))
    % varargin{1:len} are parameters for odefile, OutputFcn,
    % DenseOutputFcn and EventFcn 
    if isempty(varargin{1}) && length(varargin) > 1
      OptUsr = [];
      Args = {varargin{2:length(varargin)}};
    end
  elseif (length (varargin) > 1)
    % varargin{1} is an dopPkg options structure
    OptUsr = varargin{1};
    Args   = {varargin{2:length(varargin)}};
  else
    OptUsr = varargin{1};
    Args   = {}; 
  end  
end

% Initialisation des options par défaut

% Valeurs par défaut       
RelToldef           = 1e-3;
AbsToldef           = 1e-6;
NormControldef      = [];
NonNegativedef      = [];
OutputFcndef        = [];
OutputSeldef        = [];
DenseOutputFcndef   = [];
DenseOutputSeldef   = [];
Statsdef            = [];
InitialStepdef      = [];
MaxStepdef          = tspan(end) - tspan(1);
Eventsdef           = [];
Massdef             = [];
MStateDependencedef = [];
MaxIterdef          = 1e10;

RelTol           = dopget(OptUsr,'RelTol',RelToldef);
AbsTol           = dopget(OptUsr,'AbsTol',AbsToldef);
NormControl      = dopget(OptUsr,'NormControl',NormControldef);
NonNegative      = dopget(OptUsr,'NonNegative',NonNegativedef);
OutputFcn        = dopget(OptUsr,'OutputFcn',OutputFcndef);
OutputSel        = dopget(OptUsr,'OutputSel',OutputSeldef);
DenseOutputFcn   = dopget(OptUsr,'DenseOutputFcn',DenseOutputFcndef);
DenseOutputSel   = dopget(OptUsr,'DenseOutputSel',DenseOutputSeldef);
Stats            = dopget(OptUsr,'Stats',Statsdef);
InitialStep      = dopget(OptUsr,'InitialStep',InitialStepdef );
MaxStep          = dopget(OptUsr,'MaxStep',MaxStepdef);
EventsFcn        = dopget(OptUsr,'Events',Eventsdef);
Mass             = dopget(OptUsr,'Mass',Massdef);
MStateDependence = dopget(OptUsr,'MStateDependence',MStateDependencedef);
MaxIter          = dopget(OptUsr,'MaxIter',MaxIterdef);

% Test sur les options

if ~isempty(RelTol) 
  RelTol = RelTol(:);     % Create column vector
  if (~isvector (RelTol) || ~isnumeric (RelTol))
    error ([Solver_Name, ...
    ': "RelTol" must be a vector or a number > 0']);
  end
else
  RelTol = RelTolDef;  
  warning ([Solver_Name, ...
  ': "RelTol" set to default value ',num2str(RelToldef)]);
end

if ~isempty(AbsTol)
  AbsTol = AbsTol(:);     % Create column vector
  if (~isvector (AbsTol) || ~isnumeric (AbsTol))
    error ([Solver_Name, ...
    ': "AbsTol" must be a vector or a number > 0']);
  end
else
  AbsTol = AbsToldef;  
  warning ([Solver_Name, ...
  ': "AbsTol" set to default value ',num2str(AbsToldef)]);   
end

if (strcmp (NormControl, 'on')) % NormControl
  vnormcontrol = true;
else
  vnormcontrol = false; 
end

if ~isempty(NonNegative)    % NonNegative
  if isempty (Mass)          % Mass 
    vhavenonnegative = true;
  else
    vhavenonnegative = false;
    warning ([Solver_Name, ...
    ': "NonNegative" will be ignored if mass is set']);
  end
else
  vhavenonnegative = false;
end

if nargout == 0 & isempty(OutputFcn) & isempty(DenseOutputFcn)  
  OutputFcn    = @odeplot;
  OutputFcnOk  = true;
  OutputFcnArg = false;
elseif isempty(OutputFcn)
  OutputFcnOk = false;
else  
  if ~isa(OutputFcn, 'function_handle')
    OutFcnType = exist(OutputFcn);
    if ~(OutFcnType == 2 || OutFcnType == 5)
     error([Solver_Name, ...
     ': "OutputFcn" must be a valid function name or function_handle'])
    end
  end  
  OutputFcnOk  = true;
  OutputFcnArg = abs(nargin(OutputFcn)) > 3;
end
 
if ~isempty(OutputSel)  
  if ~isnumeric(OutputSel)    
    error([Solver_Name, ... 
    ': "OutputSel" must be an integer value or an integer vector']);
  end  
  OutputSel = uint32(OutputSel);  
  for k = 1:length(OutputSel)
    if OutputSel(k) < 1 | OutputSel(k) > length(y0)
      error([Solver_Name,': "OutputSel", component ', num2str(OutputSel(k)),' does not exist !'])
    end
  end  
else
  OutputSel = true(size(y0));
end

if isempty (DenseOutputFcn)
  DenseOutputFcnOk = false;
else  
  if ~isa (DenseOutputFcn,'function_handle') && ~(exist(DenseOutputFcn) == 2)
    error([Solver_Name, ...
    ': "DenseOutputFcn" must be a valid function name or function_handle'])
  end
  DenseOutputFcnOk = true;
  DenseOuputFcnArg = abs(nargin(DenseOutputFcn)) > 5;
end

if ~isempty (DenseOutputSel) 
  if ~isnumeric(DenseOutputSel)
    error([Solver_Name, ...
    ': "DenseOutputSel" must be an integer value or an integer vector']);
  end
  DenseOutputSel = uint32(DenseOutputSel);
  for k = 1:length(DenseOutputSel)
    if DenseOutputSel(k) < 1 | DenseOutputSel(k) > length(y0)
      error([Solver_Name, ...
      ': "DenseOutputSel", component ',num2str(DenseOutputSel(k)),' does not exist !'])
    end
  end
else
  DenseOutputSel = true(size(y0(:))); 
end
  
if (strcmp (Stats, 'on'))  
  vhavestats = true;
else
  vhavestats = false;
end

if (~isempty (InitialStep) && InitialStep ~= 0)  
  InitialStepToDo = false;
else
  InitialStepToDo = true;
  warning ([Solver_Name, ...
  ': "InitialStep" not set, new value evaluated by InitialStepFcn'])
end
 
if isempty (MaxStep) 
  MaxStep = tspan(end) - tspan(1);
  warning ([Solver_Name, ...
  ': "MaxStep" not set, new value ',num2str(MaxStep),' is used']);
end

if isempty (EventsFcn)
  EventsOk = false;
else
  EventsOk = true;  
  if ~isa (EventsFcn,'function_handle') && ~(exist(EventsFcn) == 2)
    error([Solver_Name, ...
    ': "EventsFcn" must be a valid function name or function_handle'])
  end
end

if (isempty(MaxIter))
  MaxIter = MaxIterdef;
  warning ([Solver_Name, ...
  ': "MaxIter" set to default value ',num2str(MaxIterdef)]);
end

vmass        = [];
MassFcn      = [];
vhavemass    = false;
if ~isempty (Mass)
  vhavemass = true;
  if isnumeric (Mass)
    vmass   = Mass;        % constant mass
  elseif (isa (Mass, 'function_handle') || ...
          exist(Mass) == 2)
    MassFcn = Mass;
  end
end

vmassdependence = true;
if isempty(MStateDependence) || (strcmp (MStateDependence, 'none'))
  vmassdependence = false;
end

if ~isempty(MassFcn)
  MassFcnArg = false;
  MassNargin = abs(nargin(MassFcn));
  if ~vmassdependence
    if MassNargin > 1
      MassFcnArg = true;
    end
  elseif MassNargin > 2
    MassFcnArg = true;
  end
end
    
global tCont_dop54d yCont_dop54d hCont_dop54d

% ---------------------------
% Coefficients values for dop54d
% See Hairer Université de Genève
% ---------------------------
% c: time increment coefficients
c     = zeros(1,8); 
c(1)  = 0;
c(2)  = 0.2;
c(3)  = 0.3; 
c(4)  = 0.8;
c(5)  = 8/9;
c(6)  = 1;
c(7)  = 1;
% ---------------------------
% a: slope calculation coefficients 
a      =  zeros(7,7);
a(2,1) =  0.2;
a(3,1) =  3/40;
a(3,2) =  9/40;
a(4,1) =  44/45;
a(4,2) = -56/15;
a(4,3) =  32/9;
a(5,1) =  19372/6561;
a(5,2) = -25360/2187;
a(5,3) =  64448/6561;
a(5,4) = -212/729;
a(6,1) =  9017/3168;
a(6,2) = -355/33;
a(6,3) =  46732/5247;
a(6,4) =  49/176;
a(6,5) = -5103/18656;
a(7,1) =  35/384;
a(7,3) =  500/1113;
a(7,4) =  125/192;
a(7,5) = -2187/6784;
a(7,6) =  11/84;
% ---------------------------
% Dense output coefficients
d = zeros(1,7);
d(1) = -12715105075/11282082432;
d(3) =  87487479700/32700410799;
d(4) = -10690763975/1880347072;
d(5) =  701980252875/199316789632;
d(6) = -1453857185/822651844;
d(7) =  69997945/29380423;
% ---------------------------
% Error calculation coefficients
er(1) =  71/57600;
er(2) =  0.0;
er(3) = -71/16695;
er(4) =  71/1920;
er(5) = -17253/339200;
er(6) =  22/525;
er(7) = -1/40;
% ---------------------------

% ---------------------------
% Initialiation method parameters.
% ---------------------------
Ltspan   = length(tspan);
nfevals  = 0;     % NFCN
nsteps   = 0;     % NSTEP
naccept  = 0;     % naccept
nfailed  = 0;     % nfailed
NonStiff = 1000;  % NSTIFF
Safe     = 0.9;   % SAFE
Fac1     = 0.2;   % FAC1 Fac1 < hNew/hOld < Fac2
Fac2     = 10;    % FAC2
Expo1    = 1/8;                 % EXPO1
Facc1    = 1/Fac1;              % FACC1
Facc2    = 1/Fac2;              % FACC2
hLamb    = 0;
IaSti    = 0;
Uround   = eps; % Smallest value as 1+uround ~= u

% ---------------------------
% Variables initialisation
% ---------------------------
t0     = tspan(1);
t      = t0;
tfinal = tspan(end);
yDim   = length(y0);
K      = zeros(yDim,size(a,1));
y1     = K;
hMax   = abs(MaxStep);
Ordre  = 5;

if (vhavenonnegative) && y0(NonNegative) <0
  error('Non-negativity constraint violated at t0.')
end

y = y0(:);

% h initialisation
if InitialStepToDo; 
  h = InitStepFcn(OdeFcn,t0,y0,PosNeg,Ordre,hMax,RelTol,AbsTol, ...
                  vhavemass,vmass,MassFcn,vmassdependence,Args{:}); 
  nfevals = nfevals + 2; 
else
  h = InitialStep;
end
Reject = false;

OdeFcnVar = {OdeFcn,t,y0};
if (OdeFcnArg)
  OdeFcnVar = {OdeFcnVar{:}, Args{:}};
end
if vhavemass
  if ~isempty(MassFcn)   
    MassFcnVar = {MassFcn,t};  % t dependance          
    if vmassdependence
      MassFcnVar = {MassFcnVar{:},y0};   % t,y deppendance
    end
    if MassFcnArg;
      MassFcnVar = {MassFcnVar{:},Args{:}};
    end                   
    vmass = feval(MassFcnVar{:});
  end 
  K(:,1) = vmass \ feval(OdeFcnVar{:});
else         
  K(:,1) = feval(OdeFcnVar{:});   
end
nfevals = nfevals + 1;

% hMax must be <= min(abs(tLag)) 
[yprime,tLag] = feval(OdeFcnVar{:}); % We just want tLag
nfevals       = nfevals + 1;
tLagMin       = min(abs(tLag));
tLagMax       = max(abs(tLag));
hMax          = min(hMax,tLagMin);
Message       = ['The maximal step size has been changed to ',num2str(hMax)];
warning(Message)

if abs(h) > abs(hMax)
  h = hMax;
end

% Important
% ---------
% Si les pas ne traversent pas les multiples des retards
% les résultats des calculs sont bien meilleurs
% Construction des temps correspondant à t0 + k * tLag
%
% Il ne suffit pas, pour augmenter la précision de rapetisser
% le pas, il faut que l'extrémité du pas soit aussi proche 
% que possible d'un multiple de tLag, surtout au début 
% du processus d'intégration, là où la solution a des dérivées
% discntinues.
% Ce qui suit peu utile si la fonction phi est la solution
% exacte du problème. Ce n'est pas le cas en général.

tstop = [];
for k = 1:length(tLag)
  ts    = tspan(1):-tLag(k):tspan(end);
  tstop = [tstop,ts];  
end
tstop  = sort(tstop)';
dt     = tstop(2:end) - tstop(1:end-1);
Ind    = find(dt == 0);
if length(Ind) > 0
  tstopO = tstop(1:Ind(1));
  IndO   = Ind(1);
  for k = 2:length(Ind)
    tstopO = [tstopO; tstop(IndO+2:Ind(k))];
    IndO   = Ind(k);
  end
  tstopO = [tstopO;tstop(IndO+2:end)];  
else 
  tstopO = tstop;
end

tstopO = tstopO(2:end);
if tstopO(end) < tspan(end);
  tstopO = [tstopO,tspan(end)];
end

% ------------
% --- BASIC INTEGRATION STEP  
% ------------

Done         = false;
tCont_dop54d = [];
format long
while ~Done 
  % -------------------------
  % THE FIRST 6 STAGES
  % ------------------------- 
  nsteps= nsteps + 1;
  if nsteps > MaxIter
    Message = [Solver_Name,': nsteps > MaxIter, calculation stopped \n'];
    fprintf(1,Message);    
    Done = true;
  end
  if (0.1*abs(h) <= abs(t)*Uround)
    Message = [Solver_Name,' : Too small step size, calculation stopped \n'];
    fprintf(1,Message)
    Done = true;
  end
   
%   if  (PosNeg * (t + 1.01*h - tfinal) >= 0 )     
%     h = tfinal - t;
%   elseif PosNeg * (t + 1.8*h - tfinal) > 0
%     h = (tfinal - t)*0.5;
%   end
  
  % Much better if the step intervals do not cross the tLag multiples 
  if (t + 1.01*h - tstopO(1) ) >= 0
    h = tstopO(1)-t;
    if length(tstopO) >= 2
      tstopO = tstopO(2:end);
    end
  elseif t+1.8*h - tstopO(1) >= 0
    h = ( tstopO(1) - t )* 0.5;
  end  
  
  ch = h*c;  
  ah = h*a';     % Needed for matrix calculation  
  
  for j = 2:7
    time    = t + ch(j);
    y1(:,j) = y+K*ah(:,j);
    OdeFcnVar = {OdeFcn,time,y1(:,j)};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end    
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,time};  % t only dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},y1(:,j)};   % t, y dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,j) = vmass \ feval(OdeFcnVar{:}); 
    else        
      K(:,j) = feval(OdeFcnVar{:});
    end              
  end;     % for 
  
  ySti = y1(:,6);  
  % K2 in Hairer fortran -->  K(:,7)
  K4   = h * K * er';      %  K4 ~= K(:,4)
  tph  = t + h;
  nfevals = nfevals + 6;
  % --- ERROR ESTIMATION   (450)
  if vnormcontrol
    %  norm(e) <= max(RelTol*norm(y),AbsTol)
    Sk = max(AbsTol) + max(RelTol)* max(norm(y),norm(y1(:,7)));
    Err = norm(K4)/Sk;
  else  
    Sk   = AbsTol + RelTol .* max( abs(y),abs(y1(:,7)));         
    Err  = sqrt( sum((K4./ Sk).^2)/yDim );
  end
  % --- COMPUTATION OF HNEW -----> 662 Hairer
  Fac11 = Err^Expo1;
  % --- LUND-STABILIZATION
  Fac   = Fac11;
  % --- WE REQUIRE  FAC1 <= HNEW/H <= FAC2
  Fac   = max(Facc2,min(Facc1,Fac/Safe));
  hNew  = h/Fac;   
  if(Err < 1.D0)
    % --- STEP IS ACCEPTED          (470 Hairer)
    naccept = naccept + 1;
    % ------- STIFFNESS DETECTION                     675
    if mod(naccept,NonStiff)== 0 | IaSti > 0     
      StNum = sum( (K(:,7) - K(:,6)).^2 );
      StDen = sum( (ySti   - y1(:,7)).^2 ); 
      if StDen > 0 
        hLamb = abs(h) * sqrt(StNum/StDen);
      end         
      if hLamb > 3.25      
        NonStiff = 0;
        IaSti    = IaSti + 1;
        stats.tStiff(IaSti) = t;        
        if IaSti == 15
          Message = [' The problem seems to become stiff at t = ', num2str(t)];
          warning(Message)          
        end
      else
        NonStiff = NonStiff + 1;
        if NonStiff == 6 
          IaSti = 0;
        end
      end
    end    
    
    if (vhavenonnegative)           
      y1(NonNegative,7) = max(y1(NonNegative,7),0); 
    end    
       
    % ------- FINAL PREPARATION FOR DENSE OUTPUT     495       
    YDiff            = y1(:,7)  - y;
    Bspl             = h*K(:,1) - YDiff;
    yCont_dop54(:,1) = y;
    yCont_dop54(:,2) = YDiff;
    yCont_dop54(:,3) = Bspl;
    yCont_dop54(:,4) = -h*K(:,7)+YDiff-Bspl;
    yCont_dop54(:,5) = h* K*d';
           
    if t == tspan(1) % Beginning, initialisation of output
      nout = 1;
      if nargout
        tout = t;
        yout = y';
      end      
      if OutputFcnOk    % Initialize the OutputFcn
        OutputFcnVar = {OutputFcn,tspan,y(OutputSel)','init'};
        if OutputFcnArg
          OutputFcnVar = {OutputFcnVar{:},Args{:}};
        end
        if feval(OutputFcnVar{:}); 
          Message = [Solver_Name,': Error reported from ',OutputFcn,' calculation stopped \n'];
          fprintf(1,Message)
          break;
        end        
      end
      if DenseOutputFcnOk 
        DenseOutputFcnVar = {DenseOutputFcn,tspan,y(DenseOutputSel)', h,...
                             yCont_dop54(DenseOutputSel,:),'init'};
        if DenseOuputFcnArg 
          DenseOutputFcnVar = {DenseOutputFcnVar{:},Args{:}};
        end
        if feval(DenseOutputFcnVar{:});
          Message = [Solver_Name,': Error reported from ',DenseOutputFcn,' calculation stopped \n'];
          fprintf(1,Message)
          break;
        end                         
      end

      if EventsOk       
        EventZeroFcn(EventsFcn,t,y,t,h,yCont_dop54,'init',varargin{:});
      end      
        
    else   % t = tspan(1) est déjà traité t ~= tspan(1)   
      
      if DenseOutputFcnOk   % C'est ici seulement qu'il faut sortir Dense 
        DenseOutputFcnVar = {DenseOutputFcn,t,y(DenseOutputSel)', h,...
                             yCont_dop54(DenseOutputSel,:),''};
        if DenseOuputFcnArg
          DenseOutputFcnVar = {DenseOutputFcnVar{:},Args{:}};
        end 
        if feval(DenseOutputFcnVar{:});
          Message = [Solver_Name,': Error reported from ',DenseOutputFcn,' calculation stopped \n'];
          fprintf(1,Message)
          break;
        end                                    
      end
      
      if Ltspan == 2  % On a tspan = [t0,tend] il faut tout sortir ici 
        
        if nargout
          tout = [tout;t];
          yout = [yout;y'];
        end      
        if OutputFcnOk    % Initialize the OutputFcn
          OutputFcnVar = {OutputFcn,t,y(OutputSel)',''};
          if OutputFcnArg 
            OutputFcnVar = {OutputFcnVar{:},Args{:}};
          end
          if feval(OutputFcnVar{:});
            Message = [Solver_Name,': Error reported from ',OutputFcn,' calculation stopped \n'];
            fprintf(1,Message)
            break;            
          end          
        end 
        
        if EventsOk
          [teout,yeout,ieout,Stop] = EventZeroFcn(EventsFcn,t+h,y1(:,7), ...
                                     t,h,yCont_dop54,'',varargin{:});
          if Stop
            break
          end
        end      
      end 
      
    end       % t = tspan(1) et Ltspan == 2 sont traités                                  
   
    if Ltspan > 2 % We treat the cases Ltspan > 2
      
      while ( PosNeg > 0 && t<= tspan(nout+1) & tspan(nout+1) < tph || ...
              PosNeg < 0 && t>= tspan(nout+1) & tspan(nout+1) > tph)           
        nout  = nout + 1;         
        tCont = tspan(nout);        
        S     = (tCont-t)/h;    % S is theta in the book
        S1    = 1-S;
        yCont = yCont_dop54(:,1) + S*(yCont_dop54(:,2) + ...
                S1*(yCont_dop54(:,3) + S*(yCont_dop54(:,4) +  ...
                S1*yCont_dop54(:,5))));    
				
        if (vhavenonnegative)     
          yCont(NonNegative) = max(yCont(NonNegative),0);      
        end                      
          
        if EventsOk
          [teout,yeout,ieout,Stop] = EventZeroFcn(EventsFcn,tCont,yCont, ...
                                     t,h,yCont_dop54,'',varargin{:});
          if Stop
            break
          end
        end    
        
        if nargout
          tout  = [tout;tCont];  
          yout  = [yout;yCont'];  % Column output
        end          
        if OutputFcnOk    
          OutputFcnVar = {OutputFcn,tCont,yCont(OutputSel)',''};
          if OutputFcnArg
            OutputFcnVar = {OutputFcnVar{:},Args{:}};
          end
          if feval(OutputFcnVar{:});
            Message = [Solver_Name,': Error reported from ',OutputFcn,' calculation stopped \n'];
            fprintf(1,Message)
            break;            
          end                    
        end 
             
      end                                   
    end 
    % ---------------
    % We must save yCont_dop54 to be able to evaluate y(t-tau)
    % even if tspan = [t0,tfinal] because we need to 
    % evaluate y at points like t0+h-tau  (time lag) at each step. 
    IndMax                   = length(tCont_dop54d) + 1;
    tCont_dop54d(IndMax)     = t;   
    yCont_dop54d(IndMax,:,:) = yCont_dop54;
    hCont_dop54d(IndMax)     = h;   
    % Free no more useful tCont_dop54d and yCont_dop54d components    
    LtCont_dop54d = length(tCont_dop54d);
    Ind           = 1;      
    while t - tLagMax > tCont_dop54d(Ind) 
      Ind = Ind + 1;
    end
    if Ind > 1
      Ind          = Ind - 1;
      yCont_dop54d = yCont_dop54d(Ind:LtCont_dop54d,:,:);
      tCont_dop54d = tCont_dop54d(Ind:LtCont_dop54d);
      hCont_dop54d = hCont_dop54d(Ind:LtCont_dop54d);
    end
    % ---------------
    % Solution élégante mais bien plus lente
    % tg = tCont_dop54d > t - tLagMax - tCont_dop54d(1);
    % tCont_dop54d = tCont_dop54d(tg>0);    
    % Cont_dop54d = Cont_dop54d(tg>0,:,:);
    % ---------------
    
    K(:,1) = K(:,7);
    t      = tph;
    y      = y1(:,7);  
    
    if t == tfinal  
      Done    = true;
    end           
    
    if abs(hNew) > hMax
      hNew = PosNeg*hMax;
    end
    if Reject
      hNew = PosNeg*min(abs(hNew),abs(h));
    end
	     
    Reject = false;
	
  else % --- STEP IS REJECTED      depuis 457    (769 Hairer)
  
    Message = [Solver_Name,': Step is reject'];
    warning(Message)
    hNew = h/min(Facc1,Fac11/Safe);
    Reject = true;
    if naccept > 1 
      nfailed = nfailed + 1;
    end    
  end
  h = hNew;

end  % while

% Output of the last value
if t == tspan(end)
  if nargout    
    tout = [tout;t];
    yout = [yout;y'];
  end  
  if OutputFcnOk
    OutputFcnVar = {OutputFcn,t,y(OutputSel)',''};
    if OutputFcnArg 
      OutputFcnVar = {OutputFcnVar{:},Args{:}};
    end
    feval(OutputFcnVar{:});    
  end
end

if OutputFcnOk
  OutputFcnVar = {OutputFcn,[],[],'done'};
  if OutputFcnArg 
    OutputFcnVar = {OutputFcnVar{:},Args{:}};
  end
  feval(OutputFcnVar{:});
end 

if DenseOutputFcnOk
  DenseOutputFcnVar = {DenseOutputFcn,[],[],[],[],'done'};
  if DenseOuputFcnArg
    DenseOutputFcnVar = {DenseOutputFcnVar{:},Args{:}};
  end  
  feval(DenseOutputFcnVar{:});    
end
   

% Print additional information if option Stats is set
if vhavestats
  if ~nargout  % nargout = 0
    vmsg = fprintf (1, 'Number of steps:            %d \n', nsteps);
    vmsg = fprintf (1, 'Number of successful steps: %d \n', naccept);
    vmsg = fprintf (1, 'Number of failed attempts:  %d \n', nfailed);
    vmsg = fprintf (1, 'Number of function calls:   %d \n', nfevals);
  end
end

if (nargout == 1)                 
  varargout{1}.x      = tout; 
  varargout{1}.y      = yout;
  if EventsOk
    varargout{1}.ie   = ieout;
    varargout{1}.te   = teout;
    varargout{1}.ye   = yeout;
  end
  if (vhavestats)
    varargout{1}.stats = struct;
    varargout{1}.stats.nsteps   = nsteps;
    varargout{1}.stats.nfailed  = nfailed;
    varargout{1}.stats.nfevals  = nfevals;    
  end  
  varargout{1}.solver = Solver_name;
elseif (nargout == 2)
  varargout{1} = tout; 
  varargout{2} = yout; 
elseif (nargout == 3)
  varargout{1} = tout; 
  varargout{2} = yout;
  varargout{3}.nsteps   = nsteps;
  varargout{3}.nfailed  = nfailed;
  varargout{3}.nfevals  = nfevals;
elseif (nargout == 5)
  varargout{1} = tout; 
  varargout{2} = yout; 
  varargout{3} = teout; 
  varargout{4} = yeout; 
  varargout{5} = ieout; 
elseif (nargout == 6)
  varargout{1} = tout; 
  varargout{2} = yout; 
  varargout{3} = teout; 
  varargout{4} = yeout; 
  varargout{5} = ieout;
  varargout{6}.nsteps   = nsteps;
  varargout{6}.nfailed  = nfailed;
  varargout{6}.nfevals  = nfevals;  
end

% ---------------------------
% ---------------------------
   

function hInit = InitStepFcn(OdeFcn,t,y,PosNeg,Ordre,hMax,RelTol,AbsTol, ...
                             vhavemass,vmass,MassFcn,vmassdependence, varargin)
% ----------------------------------------------------------
% ----  COMPUTATION OF AN INITIAL STEP SIZE GUESS
% ----------------------------------------------------------      
% ---- COMPUTE A FIRST GUESS FOR EXPLICIT EULER AS
% ----   H = 0.01 * NORM (Y0) / NORM (F0)
% ---- THE INCREMENT FOR EXPLICIT EULER IS SMALL
% ---- COMPARED TO THE SOLUTION

if ~isempty(MassFcn)
  MassFcnArg = false;
  MassNargin = abs(nargin(MassFcn));
  if ~vmassdependence
    if MassNargin > 1
      MassFcnArg = true;
    end
  elseif MassNargin > 2
    MassFcnArg = true;
  end
end


OdeFcnArg = abs(nargin(OdeFcn)) > 2;
OdeFcnVar = {OdeFcn,t,y};
if (OdeFcnArg)
  OdeFcnVar = {OdeFcnVar{:}, varargin{:}};
end   

if vhavemass
  if ~isempty(MassFcn)        
    MassFcnVar = {MassFcn,t};  % t,y dependance          
    if vmassdependence
      MassFcnVar = {MassFcnVar{:},y};   % t only dependance
    end
    if MassFcnArg;
      MassFcnVar = {MassFcnVar{:},varargin{:}};
    end                   
    vmass = feval(MassFcnVar{:});
  end   
  f0 = vmass \ feval(OdeFcnVar{:}); 
else        
  f0 = feval(OdeFcnVar{:});   
end
 
Sk  = AbsTol + RelTol.*abs(y);
Dnf = sum( (f0./Sk).^2 );
Dny = sum( (y./Sk).^2 );
if (Dnf < 1e-10 | Dny < 1e-10)
  h = 1e-6;
else
  h = sqrt(Dny/Dnf) * 0.01; 
end
h = min(h,hMax) * PosNeg;

% ---- PERFORM AN EXPLICIT EULER STEP
y1 = y + h*f0;

OdeFcnVar = {OdeFcn,t+h,y1};
if (OdeFcnArg)
  OdeFcnVar = {OdeFcnVar{:}, varargin{:}};
end 

if vhavemass
  if ~isempty(MassFcn)        
    MassFcnVar = {MassFcn,t+h};  % t only dependance          
    if vmassdependence
      MassFcnVar = {MassFcnVar{:},y1};   % t,y dependance
    end
    if MassFcnArg;
      MassFcnVar = {MassFcnVar{:},varargin{:}};
    end                   
    vmass = feval(MassFcnVar{:});
  end 
  f1 = vmass \ feval(OdeFcnVar{:}); 
else        
  f1 = feval(OdeFcnVar{:});   
end

% ---- ESTIMATE THE SECOND DERIVATIVE OF THE SOLUTION
Sk   = AbsTol + RelTol .* abs(y);
Der2 = sum ( ((f1-f0)./Sk).^2 );   
Der2 = sqrt(Der2)/h;
% ---- STEP SIZE IS COMPUTED SUCH THAT
% ----  H**IORD * MAX ( NORM (F0), NORM (DER2)) = 0.01
Der12 = max(abs(Der2),sqrt(Dnf));
if Der12 <= 1e-15 
  h1 = max(1e-6,abs(h)*1e-3);
else
  h1 = (0.01/Der12)^(1/Ordre);
end
hInit = min([100*abs(h),h1,hMax])*PosNeg;
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

function [tout,yout,iout,Stop] = EventZeroFcn(EventFcn,t,y,T0,h, ...
                                 yCont_dop54,Flag,varargin)
% Cette fonction calcule la position d'un zéro sur l'intervalle [tOld,tNew]
% connaissant yOld, yNew et ayant à disposition yCont qui permet le calcul
% de y(t) sur tout l'intervalle [tOld,tNew]. (1 zero par intervalle)
% La méthode utilisée est la Regula Falsi.
% La fonction est appelée après chaque nouvelle évaluation de (t,y) par
% la fonction dop54d. Elle utilise yCont, qui est spécifique à dop54d.

persistent t1  E1v

tout = [];
yout = [];
iout = [];
Stop = 0;

EventFcnArg = abs(nargin(EventFcn));
EventFcnVar = {EventFcn,t};
if EventFcnArg > 2
  EventFcnVar = {EventFcnVar{:},y,varargin{:}};
elseif EventFcnArg == 2
  EventFcnVar = {EventFcnVar{:},y};
end
  
if strcmp(Flag,'init')
  [E1v,Stopv,Slopev] = feval(EventFcnVar{:});   
  t1 = t; 
  return
end

[E2v,Stopv,Slopev] = feval(EventFcnVar{:});

t2 = t;
ky = length(E1v);

% Y a-t-il un zéro sur l'intervalle?

IterMax = 50;
tAbsTol = 1e-6;
tRelTol = 1e-6;
EAbsTol = 1e-6;

Indk = 0;
for k = 1: ky 
  E1    = E1v(k);
  E2    = E2v(k);
  E12   = E1*E2;
  p12   = (E2-E1)/(t2-t1);
    
  if (E12 < 0) && (p12*Slopev(k) >= 0)
    
    Indk = Indk + 1;   % Indice de stockage   
    Done = false;
    Iter = 0;
    
    tNew = t2; % Pour éviter les ennuis dus à de très petits intervalles
    yNew = y;
    ENew = E2;   
    while ~Done      
      Iter = Iter + 1;
      if Iter >= IterMax 
        fprintf(1,'EventZeroFcn: iteration number > maximal iteration number \n')    
        break
      end
      tRel = abs(t1-t2)*tRelTol < max(abs(t1),abs(t2));
      tAbs = abs(t1-t2) < tAbsTol;
      if (abs(ENew) < EAbsTol) && (tRel & tAbs)  % On a trouvé        
        break
      else    
        % Regula falsi  si possible, sinon dichotomie
        if abs(E1) < 200*EAbsTol || abs(E2) < 100*EAbsTol
          tNew = 0.5*(t1+t2);          
        else          
          tNew = (t1*E2-t2*E1)/(E2-E1);
        end
        S    = (tNew-T0)/h;
        S1   = 1-S;
        yNew = yCont_dop54(:,1) + S*(yCont_dop54(:,2) + S1*(yCont_dop54(:,3) + ...
                                  S*(yCont_dop54(:,4) + S1*yCont_dop54(:,5))));
                                                                                                       
        EventFcnVar = {EventFcn,tNew};
        if EventFcnArg > 2
          EventFcnVar = {EventFcnVar{:},yNew,varargin{:}};
        elseif EventFcnArg == 2
          EventFcnVar = {EventFcnVar{:},yNew};
        end                        
        ENew = feval(EventFcnVar{:});                        
       
        ENew = ENew(k);
        if ENew * E1 > 0 
          t1 = tNew;
          E1 = ENew;
        else
          t2 = tNew;
          E2 = ENew;
        end
      end
    end
    ioutk(Indk)   = k;   
    toutk(Indk)   = tNew;
    youtk(Indk,:) = yNew;
    Stopk(Indk)   = Stopv(k);
  end
end

if exist('toutk')
  if t1 < t2
    [mt,Ind] = min(toutk);
  else
    [mt,Ind] = max(toutk);
  end
  iout = ioutk(Ind(1));
  tout = mt(1);
  yout = youtk(Ind(1),:);
  Stop = Stopk(Ind(1));
end
t1  = t2;
E1v = E2v;
% -------------------------------------------------------------------
% -------------------------------------------------------------------


