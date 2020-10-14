function [varargout] = dop853d(OdeFcn,tspan,y0,varargin)
% ------------------------------------------------------------------------
% Solver Name :  dop853d.
% -----------
%
% Important: The variables:  "tCont_dop853d"  and "yCont_dop853d"  are global
%            variables. Do'nt use these names for functions or variables.
%
%	[tout,yout,ParamOut] = dop853d('OdeFcn',tspan,y0,options,varargin)
% integrates the system of ordinary differential equations y' = f(t,y)
% described by the M-file 'OdeFcn.m', over the interval tinitial = tspan(1)
% to tfinal = tspan(end), with initial conditions y0 using a Dormand and
% Prince of order 8 with dense output of order 7. 	
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
% varargin : Parameters to be send to the OdeFcn function, and (or) to
%            the OutputFcn and (or) the DenseOutputFcn and (or) to the 
%            Events function.
%
% Important: If the first components of varargin is an options strucure 
%            returned by dopset, these options will be taken into account
%            by dop853d (see dopset). If the first component of varargin 
%            is not such a structure, this component of varargin, as all
%            the others will be passed down to : OdeFcn, OutputFcn and
%            DenseOutputFcn and EventFcn        
%
% OUTPUT
% ------
% Case 1)  One output variable: Sol
%          Sol = dop853d(OdeFcn,tspan,y0,varargin)
% 
%          Sol.x      = t variable returned by dop853d (column vector)
%          Sol.y      = y solution evaluated at each component of t
%                       (one row vector per time step)
%          Sol.solver = 'dop853d'
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
%          [t,y] = dop853d(OdeFcn,tspan,y0,varargin)
%          t = time at which the solution is evaluated
%          y = solution (one row vector par time step)
%
% Case 3)  Three output variables: t, y and S
%          [t,y,S] = dop853d(OdeFcn,tspan,y0,varargin)
%          t and y like in Case 2)
%          S like Sol.stats in Case 1)
%   
% Case 4)  Five output variables
%          [t,y,te,ye,ie] = dop853d(OdeFcn,tspan,y0,varargin}
%          t,y like case2
%          te,ye,ie like Sol.te, Sol.ye, Sol.ie in Case 1

% Case 5)  Six output variables
%          [t,y,te,ye,ie,Stats] = dop853d(OdeFcn,tspan,y0,varargin}
%          t,y,te,ye,ie like in Case 4
%          Stats.nsteps, Stats.nfailed, Case.nfevals like in Case 1
%  
% See DOP54 DOP54D DOP853 DOPGET DOPSET
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
Solver_Name = 'dop853d';

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
    % varargin{1:len} are parameters for odefile, OutputFcn and
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
  OutputSel = true(size(y0(:)));
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

global tCont_dop853d yCont_dop853d hCont_dop853d

% ---------------------------
% Coefficients values for dop853d
% See Hairer Université de Genève
% ---------------------------
% c: time increment coefficients
c     = zeros(1,16); 
c(2)  = 0.526001519587677318785587544488e-1;
c(3)  = 0.789002279381515978178381316732e-1;
c(4)  = 0.118350341907227396726757197510;
c(5)  = 0.281649658092772603273242802490;
c(6)  = 0.333333333333333333333333333333;
c(7)  = 0.25;
c(8)  = 0.307692307692307692307692307692;
c(9)  = 0.651282051282051282051282051282;
c(10) = 0.6;
c(11) = 0.857142857142857142857142857142;
c(12) = 1;
c(13) = 1;
c(14) = 0.1;
c(15) = 0.2;
c(16) = 0.777777777777777777777777777778;
% ---------------------------
% a: slope calculation coefficients 
a        =    zeros(12,12);
a(1,1)   =    5.26001519587677318785587544488e-2;
a(2,1)   =    1.97250569845378994544595329183e-2;
a(2,2)   =    5.91751709536136983633785987549e-2;
a(3,1)   =    2.95875854768068491816892993775e-2;
a(3,3)   =    8.87627564304205475450678981324e-2;
a(4,1)   =    2.41365134159266685502369798665e-1;
a(4,3)   =   -8.84549479328286085344864962717e-1;
a(4,4)   =    9.24834003261792003115737966543e-1;
a(5,1)   =    3.7037037037037037037037037037e-2;
a(5,4)   =    1.70828608729473871279604482173e-1;
a(5,5)   =    1.25467687566822425016691814123e-1;
a(6,1)   =    3.7109375e-2;
a(6,4)   =    1.70252211019544039314978060272e-1;
a(6,5)   =    6.02165389804559606850219397283e-2;
a(6,6)   =   -1.7578125e-2;

a(7,1)   =    3.70920001185047927108779319836e-2;
a(7,4)   =    1.70383925712239993810214054705e-1;
a(7,5)   =    1.07262030446373284651809199168e-1;
a(7,6)   =   -1.53194377486244017527936158236e-2;
a(7,7)   =    8.27378916381402288758473766002e-3;
a(8,1)   =    6.24110958716075717114429577812e-1;
a(8,4)   =   -3.36089262944694129406857109825;
a(8,5)   =   -8.68219346841726006818189891453e-1;
a(8,6)   =    2.75920996994467083049415600797e1;
a(8,7)   =    2.01540675504778934086186788979e1;
a(8,8)   =   -4.34898841810699588477366255144e1;
a(9,1)  =    4.77662536438264365890433908527e-1;
a(9,4)  =   -2.48811461997166764192642586468;
a(9,5)  =   -5.90290826836842996371446475743e-1;
a(9,6)  =    2.12300514481811942347288949897e1;
a(9,7)  =    1.52792336328824235832596922938e1;
a(9,8)  =   -3.32882109689848629194453265587e1;
a(9,9)  =   -2.03312017085086261358222928593e-2;

a(10,1)  =  -9.3714243008598732571704021658e-1;
a(10,4)  =   5.18637242884406370830023853209;
a(10,5)  =   1.09143734899672957818500254654;
a(10,6)  =  -8.14978701074692612513997267357;
a(10,7)  =  -1.85200656599969598641566180701e1;
a(10,8)  =   2.27394870993505042818970056734e1;
a(10,9)  =   2.49360555267965238987089396762;
a(10,10) =  -3.0467644718982195003823669022;
a(11,1)  =   2.27331014751653820792359768449;
a(11,4)  =  -1.05344954667372501984066689879e1;
a(11,5)  =  -2.00087205822486249909675718444;
a(11,6)  =  -1.79589318631187989172765950534e1;
a(11,7)  =   2.79488845294199600508499808837e1;
a(11,8)  =  -2.85899827713502369474065508674;
a(11,9)  =  -8.87285693353062954433549289258;
a(11,10) =   1.23605671757943030647266201528e1;
a(11,11) =   6.43392746015763530355970484046e-1;
% ------------------------------------------
a141 =  5.61675022830479523392909219681e-2;
a147 =  2.53500210216624811088794765333e-1;
a148 = -2.46239037470802489917441475441e-1;
a149 = -1.24191423263816360469010140626e-1;
a1410 =  1.5329179827876569731206322685e-1;
a1411 =  8.20105229563468988491666602057e-3;
a1412 =  7.56789766054569976138603589584e-3;
a1413 = -8.298e-3;

a151 =  3.18346481635021405060768473261e-2;
a156 =  2.83009096723667755288322961402e-2;
a157 =  5.35419883074385676223797384372e-2;
a158 = -5.49237485713909884646569340306e-2;
a1511 = -1.08347328697249322858509316994e-4;
a1512 =  3.82571090835658412954920192323e-4;
a1513 = -3.40465008687404560802977114492e-4;
a1514 =  1.41312443674632500278074618366e-1;
a161 = -4.28896301583791923408573538692e-1;
a166 = -4.69762141536116384314449447206;
a167 =  7.68342119606259904184240953878;
a168 =  4.06898981839711007970213554331;
a169 =  3.56727187455281109270669543021e-1;
a1613 = -1.39902416515901462129418009734e-3;
a1614 =  2.9475147891527723389556272149;
a1615 = -9.15095847217987001081870187138;
% ---------------------------
% Final assembly coefficients
b1  =  5.42937341165687622380535766363e-2;
b6  =  4.45031289275240888144113950566;
b7  =  1.89151789931450038304281599044;
b8  = -5.8012039600105847814672114227;
b9  =  3.1116436695781989440891606237e-1;
b10 = -1.52160949662516078556178806805e-1;
b11 =  2.01365400804030348374776537501e-1;
b12 =  4.47106157277725905176885569043e-2;

bhh1 = 0.244094488188976377952755905512;
bhh2 = 0.733846688281611857341361741547;
bhh3 = 0.220588235294117647058823529412e-1;
% ---------------------------
% Dense output coefficients
d41  = -0.84289382761090128651353491142e+1;
d46  =  0.56671495351937776962531783590;
d47  = -0.30689499459498916912797304727e+1;
d48  =  0.23846676565120698287728149680e+1;
d49  =  0.21170345824450282767155149946e+1;
d410 = -0.87139158377797299206789907490;
d411 =  0.22404374302607882758541771650e+1;
d412 =  0.63157877876946881815570249290;
d413 = -0.88990336451333310820698117400e-1;
d414 =  0.18148505520854727256656404962e+2;
d415 = -0.91946323924783554000451984436e+1;
d416 = -0.44360363875948939664310572000e+1;
d51  =  0.10427508642579134603413151009e+2;
d56  =  0.24228349177525818288430175319e+3;
d57  =  0.16520045171727028198505394887e+3;
d58  = -0.37454675472269020279518312152e+3;
d59  = -0.22113666853125306036270938578e+2;
d510 =  0.77334326684722638389603898808e+1;
d511 = -0.30674084731089398182061213626e+2;
d512 = -0.93321305264302278729567221706e+1;
d513 =  0.15697238121770843886131091075e+2;
d514 = -0.31139403219565177677282850411e+2;
d515 = -0.93529243588444783865713862664e+1;
d516 =  0.35816841486394083752465898540e+2;
d61 =  0.19985053242002433820987653617e+2;
d66 = -0.38703730874935176555105901742e+3;
d67 = -0.18917813819516756882830838328e+3;
d68 =  0.52780815920542364900561016686e+3;
d69 = -0.11573902539959630126141871134e+2;
d610 =  0.68812326946963000169666922661e+1;
d611 = -0.10006050966910838403183860980e+1;
d612 =  0.77771377980534432092869265740;
d613 = -0.27782057523535084065932004339e+1;
d614 = -0.60196695231264120758267380846e+2;
d615 =  0.84320405506677161018159903784e+2;
d616 =  0.11992291136182789328035130030e+2;
d71  = -0.25693933462703749003312586129e+2;
d76  = -0.15418974869023643374053993627e+3;
d77  = -0.23152937917604549567536039109e+3;
d78  =  0.35763911791061412378285349910e+3;
d79  =  0.93405324183624310003907691704e+2;
d710 = -0.37458323136451633156875139351e+2;
d711 =  0.10409964950896230045147246184e+3;
d712 =  0.29840293426660503123344363579e+2;
d713 = -0.43533456590011143754432175058e+2;
d714 =  0.96324553959188282948394950600e+2;
d715 = -0.39177261675615439165231486172e+2;
d716 = -0.14972683625798562581422125276e+3;
% ---------------------------
% Error calculation coefficients
er1  =  0.1312004499419488073250102996e-1;
er6  = -0.1225156446376204440720569753e+1;
er7  = -0.4957589496572501915214079952;
er8  =  0.1664377182454986536961530415e+1;
er9  = -0.3503288487499736816886487290;
er10 =  0.3341791187130174790297318841;
er11 =  0.8192320648511571246570742613e-1;
er12 = -0.2235530786388629525884427845e-1;
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
Fac1     = 1/3;   % FAC1 Fac1 < hNew/hOld < Fac2
Fac2     = 6;     % FAC2  
Expo1    = 1/8;                 % EXPO1
Facc1    = 1/Fac1;              % FACC1
Facc2    = 1/Fac2;              % FACC2
hLamb    = 0;
IaSti    = 0;
Uround   = eps; % Smallest value as 1+uround ~= u

% ---------------------------
% Variables initialisation
% ---------------------------
t0       = tspan(1);
t        = t0;
tfinal   = tspan(end);
y        = y0(:);
yDim     = length(y);
K        = zeros(yDim,size(a,1)); % <-- dim(a)
hMax     = abs(MaxStep);
Ordre    = 8;

if (vhavenonnegative) && y0(NonNegative) <0
  error([Solver_Name,': Non-negativity constraint violated at t0.'])
end

y = y0(:);

% h initialisation
OdeFcnVar = {OdeFcn,t,y};
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

if InitialStepToDo
  h = InitStepFcn(OdeFcn,t0,y0,PosNeg,Ordre,hMax, ...
                  RelTol,AbsTol,vhavemass,vmass,...                                      
                  MassFcn,vmassdependence,K(:,1),Args{:});                                                   
  nfevals = nfevals + 1;  
else
  h = InitialStep;
end
Reject = false;

% hMax must be <= min(abs(tLag)) 
[yprime,tLag] = feval(OdeFcnVar{:}); % We want just tLag
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
    
Done = false;
tCont_dop853d = [];

while ~Done   
  % -------------------------
  % The twelve stages
  % ------------------------- 
  nsteps = nsteps + 1;
  if nsteps > MaxIter
    Message = [Solver_Name,': nsteps > MaxIter, calculation stopped \n'];
    fprintf(1,Message);        
    break
  end
  if (0.1*abs(h) <= abs(t)*Uround)
    Message = [Solver_Name,': Too small step size, calculation stopped \n'];
    fprintf(1,Message)
    break
  end   
%   if  (PosNeg * (t + 1.01*h - tfinal) >= 0 )     
%     h = tfinal - t;
%   elseif PosNeg * (t + 1.8*h - tfinal) > 0
%     h = (tfinal - t)*0.5;
%   end
%   
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
  ah = h*a';    % Needed for matrix calculation  
              
  for j = 1:11
    time = t+ch(j+1);
    y1   = y+K*ah(:,j);
    
    OdeFcnVar = {OdeFcn,time,y1};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,time};  % t only dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},y1};   % t, y dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,j+1) = vmass \ feval(OdeFcnVar{:});  
    else        
      K(:,j+1) = feval(OdeFcnVar{:});
    end         
  end;        
  % K2 in Hairer -->  K(:,11)
  % K3 in Hairer -->  K(:,12)
  K(:,4)  = b1*K(:,1) + b6*K(:,6)+ b7*K(:,7) + b8*K(:,8) + ...
            b9*K(:,9) + b10*K(:,10) + b11*K(:,11) + b12*K(:,12);
  K(:,5)  = y + h*K(:,4);
  tph     = t + h;
  nfevals = nfevals  + 11;
  % --- ERROR ESTIMATION   (639)
  if vnormcontrol
    %  norm(e) <= max(RelTol*norm(y),AbsTol)
    Sk = max(AbsTol) + max(RelTol)* max(norm(y),norm(K(:,5)));    
  else  
    Sk = AbsTol + RelTol .* max( abs(y),abs(K(:,5)));          
  end         
  Err2 = sum( ((K(:,4) - bhh1*K(:,1) - bhh2*K(:,9) - bhh3*K(:,12))./Sk).^2);
  Err  = sum((( er1*K(:,1) + er6*K(:,6) + er7*K(:,7) + er8*K(:,8) + er9*K(:,9) +  ...
                er10*K(:,10) + er11*K(:,11) + er12*K(:,12) ) ./ Sk).^2);
  Deno = Err + 0.01*Err2;  
  if Deno <= 0
    Deno = 1.0;
  end
  Err = abs(h)*Err*sqrt(1/(yDim*Deno));
  % --- COMPUTATION OF HNEW -----> 662 Hairer
  Fac11 = Err^Expo1;
  % --- LUND-STABILIZATION
  Fac   = Fac11;
  % --- WE REQUIRE  FAC1 <= HNEW/H <= FAC2
  Fac   = max(Facc2,min(Facc1,Fac/Safe));
  hNew  = h/Fac;

  if(Err < 1.D0)
    % --- STEP IS ACCEPTED          ---> 558   (669 Hairer)
    naccept = naccept + 1;
    
    OdeFcnVar = {OdeFcn,tph,K(:,5)};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,tph};  % t,y dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},K(:,5)};   % t only dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,4) = vmass \ feval(OdeFcnVar{:});  
    else        
      K(:,4) = feval(OdeFcnVar{:});
    end                        
    nfevals = nfevals  + 1;
    % ------- STIFFNESS DETECTION                     675
    if mod(naccept,NonStiff)== 0 | IaSti > 0     
      StNum = sum( (K(:,4) - K(:,12)).^2 );
      StDen = sum( (K(:,5) - y1(:)).^2 );
      if StDen > 0 
        hLamb = abs(h) * sqrt(StNum/StDen);
      end         
      if hLamb > 6.1       
        NonStiff = 0;
        IaSti    = IaSti + 1;
        ParamOut.tStiff(IaSti) = t;        
        if IaSti == 15
          Message = [Solver_Name,': The problem seems to become stiff at t = ', num2str(t)];          
          warning(Message);                
        end
      else
        NonStiff = NonStiff + 1;
        if NonStiff == 6 
          IaSti = 0;
        end
      end
    end
    
    if (vhavenonnegative)           
      K(NonNegative,5) = max(K(NonNegative,5),0); 
    end 
    
    % ------- FINAL PREPARATION FOR DENSE OUTPUT     697 --> 748
    % We must save Cont to be able to evaluate y(t-tau)
    % even if tspan = [t0,tfinal] because we need to 
    % evaluate y at points like t0+h-tau  (time lag) at each step.
    yCont_dop853(:,1) = y;          % Every components of y will be saved
    YDiff             = K(:,5) - y;
    yCont_dop853(:,2) = YDiff;
    Bspl              = h*K(:,1) - YDiff;
    yCont_dop853(:,3) = Bspl;
    yCont_dop853(:,4) = YDiff - h*K(:,4) - Bspl;
    yCont_dop853(:,5) = d41*K(:,1) + d46*K(:,6) +d47*K(:,7) + d48*K(:,8) + ...
                        d49*K(:,9) + d410*K(:,10) + d411*K(:,11) + d412*K(:,12);
    yCont_dop853(:,6) = d51*K(:,1) + d56*K(:,6) + d57*K(:,7) + d58*K(:,8) + ...
                        d59*K(:,9) + d510*K(:,10) + d511*K(:,11) + d512*K(:,12);
    yCont_dop853(:,7) = d61*K(:,1) + d66*K(:,6) + d67*K(:,7) + d68*K(:,8) + ...
                        d69*K(:,9) + d610*K(:,10) + d611*K(:,11) + d612*K(:,12);
    yCont_dop853(:,8) = d71*K(:,1) + d76*K(:,6) + d77*K(:,7) + d78*K(:,8) + ...
                        d79*K(:,9) + d710*K(:,10) + d711*K(:,11) + d712*K(:,12);
    % ---     THE NEXT THREE FUNCTION EVALUATIONS
    y1 = y + h*( a141*K(:,1) + a147*K(:,7) + a148*K(:,8) + ...
                 a149*K(:,9) + a1410*K(:,10) + a1411*K(:,11) + ... 
                 a1412*K(:,12) + a1413*K(:,4));    
    time = t+ch(14);
    OdeFcnVar = {OdeFcn,time,y1};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,time};  % t,y dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},y1};   % t only dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,10) = vmass \ feval(OdeFcnVar{:});  
    else        
      K(:,10) = feval(OdeFcnVar{:});
    end           
     
    y1 = y + h*( a151*K(:,1) + a156*K(:,6) + a157*K(:,7) + ...
                 a158*K(:,8) + a1511*K(:,11) + a1512*K(:,12) + ...
                 a1513*K(:,4) + a1514*K(:,10));                    
    time = t+ch(15);      
    OdeFcnVar = {OdeFcn,time,y1};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,time};  % t,y dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},y1};   % t only dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,11) = vmass \ feval(OdeFcnVar{:});  
    else        
      K(:,11) = feval(OdeFcnVar{:});
    end  
      
    y1 = y + h*( a161*K(:,1) + a166*K(:,6) + a167*K(:,7) + ...
                 a168*K(:,8) + a169*K(:,9) + a1613*K(:,4)+ ...
                 a1614*K(:,10) + a1615*K(:,11));
    time = t+ch(16);
    OdeFcnVar = {OdeFcn,time,y1};
    if (OdeFcnArg)
      OdeFcnVar = {OdeFcnVar{:}, Args{:}};
    end
    if vhavemass
      if ~isempty(MassFcn)        
        MassFcnVar = {MassFcn,time};  % t,y dependance          
        if vmassdependence
          MassFcnVar = {MassFcnVar{:},y1};   % t only dependance
        end
        if MassFcnArg;
          MassFcnVar = {MassFcnVar{:},Args{:}};
        end                   
        vmass = feval(MassFcnVar{:});
      end 
      K(:,12) = vmass \ feval(OdeFcnVar{:});  
    else        
      K(:,12) = feval(OdeFcnVar{:});
    end  
               
    nfevals = nfevals + 3;
    % ---     FINAL PREPARATION        
    yCont_dop853(:,5) = h*(yCont_dop853(:,5) + d413*K(:,4) + d414*K(:,10) + ...
                             d415*K(:,11) + d416*K(:,12));
    yCont_dop853(:,6) = h*(yCont_dop853(:,6) + d513*K(:,4) + d514*K(:,10) + ...
                             d515*K(:,11) + d516*K(:,12));
    yCont_dop853(:,7) = h*(yCont_dop853(:,7) + d613*K(:,4) + d614*K(:,10) + ...
                             d615*K(:,11) + d616*K(:,12));
    yCont_dop853(:,8) = h*(yCont_dop853(:,8) + d713*K(:,4) + d714*K(:,10) + ...
                             d715*K(:,11) + d716*K(:,12));               
     
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
                             yCont_dop853(DenseOutputSel,:),'init'};
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
        EventZeroFcn(EventsFcn,t,y,t,h,yCont_dop853,'init',varargin{:});
      end 
      
    else   % t = tspan(1) est déjà traité t ~= tspan(1)            
      
      if DenseOutputFcnOk   % C'est ici seulement qu'il faut sortir Dense
        DenseOutputFcnVar = {DenseOutputFcn,t,y(DenseOutputSel)', h,...
                             squeeze(yCont_dop853(DenseOutputSel,:)),''};
        if DenseOuputFcnArg
          DenseOutputFcnVar = {DenseOutputFcnVar{:},Args{:}};
        end                   
        if feval(DenseOutputFcnVar{:})
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
          [teout,yeout,ieout,Stop] = EventZeroFcn(EventsFcn,t+h,K(:,5), ...
                                     t,h,yCont_dop853,'',varargin{:});
          if Stop
            break
          end
        end 
      end        
      
    end       % t = tspan(1) et Ltspan == 2 sont traités                                  

    if Ltspan > 2 % We treat the cases Ltspan > 2
      
      while ( PosNeg > 0 & t <= tspan(nout+1) & tspan(nout+1) < tph || ...
              PosNeg < 0 & t >= tspan(nout+1) & tspan(nout+1) > tph)            
        nout   = nout + 1;         
        tCont  = tspan(nout);        
        S      = (tCont-t)/h;    % S is theta in the book
        S1     = 1-S;
        ConPar = yCont_dop853(:,5)+S*(yCont_dop853(:,6)+S1*(yCont_dop853(:,7)+ ...
                 S*yCont_dop853(:,8)));        
        yCont  = yCont_dop853(:,1) + S*(yCont_dop853(:,2) + S1*(yCont_dop853(:,3) + ...
                 S*(yCont_dop853(:,4) + S1*ConPar)));                
        
        if (vhavenonnegative)     
          yCont(NonNegative) = max(yCont(NonNegative),0);      
        end  
        
        if EventsOk
          [teout,yeout,ieout,Stop] = EventZeroFcn(EventsFcn,tCont,yCont, ...
                                     t,h,squeeze(yCont_dop853(:,:)),'',varargin{:});
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
	  % We must save Cont to be able to evaluate y(t-tau)
    % even if tspan = [t0,tfinal] because we need to 
    % evaluate y at points like t0+h-tau  (time lag) at each step.
    IndMax                    = length(tCont_dop853d) + 1;
    tCont_dop853d(IndMax)     = t; 
    yCont_dop853d(IndMax,:,:) = yCont_dop853;
    hCont_dop853d(IndMax)     = h;
    % Free no more useful tCont_dop853d and yCont_dop853d components    
    LtCont_dop853d = length(tCont_dop853d);
    Ind           = 1;      
    while t - tLagMax > tCont_dop853d(Ind) 
      Ind = Ind + 1;
    end
    if Ind > 1
      Ind           = Ind - 1;
      yCont_dop853d = yCont_dop853d(Ind:LtCont_dop853d,:,:);
      tCont_dop853d = tCont_dop853d(Ind:LtCont_dop853d);
      hCont_dop853d = hCont_dop853d(Ind:LtCont_dop853d);
    end
    % ---------------
    % Solution élégante mais bien plus lente
    % tg = tCont_dop853d > t - tLagMax - tCont_dop853d(1);
    % tCont_dop853d = tCont_dop853d(tg>0);    
    % Cont_dop853d  = Cont_dop853d(tg>0,:,:);
    % ---------------
    
    K(:,1) = K(:,4);   
    t      = tph;
    y      = K(:,5);    
    
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

end   % while
  
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

% Output of the last value
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
   
 
function hInit = InitStepFcn(OdeFcn,t,y,PosNeg,Ordre,hMax, ...
                             RelTol,AbsTol,vhavemass,vmass,...                                      
                             MassFcn,vmassdependence,f0,varargin)                                
% ----------------------------------------------------------
% ----  COMPUTATION OF AN INITIAL STEP SIZE GUESS
% ----------------------------------------------------------      
% ---- COMPUTE A FIRST GUESS FOR EXPLICIT EULER AS
% ----   H = 0.01 * NORM (Y0) / NORM (F0)
% ---- THE INCREMENT FOR EXPLICIT EULER IS SMALL
% ---- COMPARED TO THE SOLUTION
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
      MassFcnVar = {MassFcnVar{:},y1};   % t only dependance
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
% ---------------------------
% ---------------------------

function [tout,yout,iout,Stop] = EventZeroFcn(EventFcn,t,y,T0,h, ...
                                 yCont_dop853d,Flag,varargin)
% Cette fonction calcule la position d'un zéro sur l'intervalle [tOld,tNew]
% connaissant yOld, yNew et ayant à disposition yCont qui permet le calcul
% de y(t) sur tout l'intervalle [tOld,tNew]. (1 zero par intervalle)
% La méthode utilisée est la Regula Falsi.
% La fonction est appelée après chaque nouvelle évaluation de (t,y) par
% la fonction dop853d. Elle utilise yCont, qui est spécifique à dop853d.

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
        ConPar = yCont_dop853d(:,5)+S*(yCont_dop853d(:,6)+S1*(yCont_dop853d(:,7)+ ...
                 S*yCont_dop853d(:,8)));        
        yNew   = yCont_dop853d(:,1) + S*(yCont_dop853d(:,2) + S1*(yCont_dop853d(:,3) + ...
                 S*(yCont_dop853d(:,4) + S1*ConPar)));  
                                                                                                               
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



