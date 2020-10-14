function [options] = dopset (varargin)
%  Copyright (C) 2010, Denis Bichsel <dbichsel@infomaniak.ch>
%  DopPkg - A package for solving ordinary differential equations 
%           and ordinary delay differential equation in using
%           Dormand and Prince with dense output method.
% 
%  This program is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%
% DOPSET PROPERTIES
% -----------------
%
% RelTol - Relative error tolerance RelTol (1e-3 by default)
%
% AbsTol - Absolute error tolerance AbsTol (all components are 1e-6 by
%    default)
%
% NormContol - With this property on, the solvers control the error in 
%    each integration step with norm(e) <= max(RelTol*norm(y),AbsTol). 
%    By default the solvers use a more stringent componentwise error 
%    control.
%
% NonNegative - This options is a vector of components indices which
%   force these components to be >= 0. 
%    
% OutputFcn - Name of installable output function  [ function handle or 
%   string ]. This output function is called by the solver after each time
%   step. When a solver is called with no output arguments, OutputFcn 
%   defaults to 'odeplot'.  Otherwise, OutputFcn defaults to ''.
%   
% OutputSel - Output selection indices  [ vector of integers ]
%   This vector of indices specifies which components of the solution vector
%   are passed to the OutputFcn.  OutputSel defaults to all components.
% 
% DenseOutputFcn - Name of installable dense output function  [ string ]
%   This dense output function is called by the solver after each loop of
%   the solver. The inputs of this function are: t, y, h, yCont
%   t is the last beginning time in the loop
%   y is the solution value at t
%   h is the step size beginning at t
%   yCont are the parameters used to evaluate the solution at times 
%   between t and t+ h. See example
%   
% DenseOutputSel - Output selection indices  [ vector of integers ]
%   This vector of indices specifies which components of the solution 
%   vector are passed to the DenseOutputFcn.  DenseOutputSel defaults to 
%   all components.
%
% Stats - Allow to get some statistical information about the quality of
%   the solution:
%   nsteps  : number of necessary steps to get the solution
%   nfailed : number of failed steps
%   nfeval  : number of evaluation of the odefcn
%
% InitialStep - fixes the value of initial step size. If this value is
%   bigger of MaxStep, it will be put to MaxStep
%
% MaxStep - Biggest allowed value for the step size.
% 
% Events - Name of an event function. If such a function name is given, 
%   the events are tested and depending on the parameters, the calculation
%   will be stopped or not
%   
% Mass - A matrix or a function such that My' = f(t,y)is given
%   The matrix or matrix function must be regular
%
% MStateDependance - swith 'none' or 'on' (or anything else) if 
%   MStateDependance = 'none' or is empty, the Mass function does'nt
%   depend on y, else the calculation of the Mass function depends on y.
%
% MaxIter - Maximal number of iterations of the solver (default 1e6)
%   this value allows endless calculation. 
%
%   See also DOP54, DOP853, DOP54D, DOP853 DOPGET.

OpNames = ['RelTol            '; ...
           'AbsTol            '; ...
           'NormControl       '; ...
           'NonNegative       '; ...
           'OutputFcn         '; ...
           'OutputSel         '; ...
           'DenseOutputFcn    '; ...
           'DenseOutputSel    '; ...
           'Stats             '; ...
           'InitialStep       '; ...
           'MaxStep           '; ...
           'Events            '; ...
           'Mass              '; ...
           'MStateDependence  '; ...
           'MaxIter           '];
     
OpHelp = ['scalar or vector           '; ...      % RelTol
          'scalar or vector           '; ...      % AbsTol
          '''on'' or ''off''              '; ...  % NormControl
          'vector of integers         '; ...      % NonNegative
          'function handle or string  '; ...      % OutputFcn
          'vector of integers         '; ...      % OutputSel
          'function handle or string  '; ...      % DenseOutputFcn
          'vector of integers         '; ...      % DenseOutputSel
          '''on'' or ''off''              '; ...  % Stats
          'scalar                     '; ...      % InitialStep
          'scalar                     '; ...      % MaxStep
          'function handle or string  '; ...      % Events
          'matrix or function         '; ...      % mass
          '''on'' or ''off''              '; ...  % MStateDependance
          'Integer number 1e10        '];         % Nbr max of loops
     
if (nargin == 0) & (nargout == 0)  % Print out possible values of properties.
  OpSize = size(OpNames);
  fprintf(1,'\n Parameters of dopset \n \n')  
  for k = 1:OpSize(1)
    fprintf(1,[OpNames(k,:),OpHelp(k,:),'\n']);
  end
  return;
end

[m,n] = size(OpNames);
names = lower(deblank(OpNames));

options = [];
i = 1;
while i <= nargin
  arg = varargin{i};
  if isstr(arg)                         % arg is an option name
    break;
  end
  if ~isempty(arg)                      % [] is a valid options argument
    if ~isa(arg,'struct')
      error(sprintf(['Expected argument %d to be a string property name ' ...
                     'or an options structure\ncreated with GNISET.'], i));
    end
    if isempty(options)
      options = arg;
    else
      for j = 1:m
        val = getfield(arg,OpNames(j,:));
        if ~isequal(val,[])             % empty strings '' do overwrite
          options = setfield(options,OpNames(j,:),val);
        end
      end
    end
  end
  i = i + 1;
end

if isempty(options)
  for j = 1:m
    options = setfield(options,OpNames(j,:),[]);
  end
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
  error('Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
  arg = varargin{i};
    
  if ~expectval
    if ~isstr(arg)
      error(sprintf('Expected argument %d to be a string property name.', i));
    end
    
    lowArg = lower(arg);
    j = strmatch(lowArg,names);
    if isempty(j)                       % if no matches
      error(sprintf('Unrecognized property name ''%s''.', arg));
    elseif length(j) > 1                % if more than one match
      % Check for any exact matches (in case any names are subsets of others)
      k = strmatch(lowArg,names,'exact');
      if length(k) == 1
        j = k;
      else
        msg = sprintf('Ambiguous property name ''%s'' ', arg);
        msg = [msg '(' deblank(Names(j(1),:))];
        for k = j(2:length(j))'
          msg = [msg ', ' deblank(Names(k,:))];
        end
        msg = sprintf('%s).', msg);
        error(msg);
      end
    end
    expectval = 1;                      % we expect a value next
    
  else
    options = setfield(options,OpNames(j,:),arg);
    expectval = 0;
      
  end
  i = i + 1;
end

if expectval
  error(sprintf('Expected value for property ''%s''.', arg));
end
