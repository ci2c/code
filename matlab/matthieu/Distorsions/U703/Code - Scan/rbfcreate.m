function options = rbfcreate(x, y, varargin)

tic;

% Affichage des valeurs possibles des propriétés

if (nargin == 0) & (nargout == 0)
  fprintf('               x: [ dim par n matrice des coordonnées aux noeuds ]\n');
  fprintf('               y: [   1 par n vecteur des valeurs aux noeuds ]\n');
  fprintf('     RBFFunction: [ gaussian  | thinplate | cubic | multiquadrics | {linear} ]\n');
  fprintf('     RBFConstant: [ scalaire positif     ]\n');
  fprintf('       RBFSmooth: [ scalaire positif {0} ]\n');
  fprintf('           Stats: [ on | {off} ]\n');
  fprintf('\n');
  return;
end
Names = [
    'RBFFunction      '
    'RBFConstant      '
    'RBFSmooth        '
    'Stats            '
];
[m,n] = size(Names);
names = lower(Names);

options = [];
for j = 1:m
  options.(deblank(Names(j,:))) = [];
end

%**************************************************************************
% Vérification des vecteurs en entrée
%**************************************************************************
[nXDim nXCount]=size(x);
[nYDim nYCount]=size(y);

if (nXCount~=nYCount)
  error(sprintf('x et y devraient avoir le même nombre de lignes'));
end;

if (nYDim~=1)
  error(sprintf('y devrait être un vecteur 1 par n'));
end;

options.('x')           = x;
options.('y')           = y;
%**************************************************************************
% Valeurs par défaut 
%**************************************************************************
options.('RBFFunction') = 'linear';
options.('RBFConstant') = (prod(max(x')-min(x'))/nXCount)^(1/nXDim); % approx. distance moyenne entre les noeuds
options.('RBFSmooth')   = 0;
options.('Stats')       = 'off';

%**************************************************************************
% code d'analyse des arguments : similaire à ODESET.m
%**************************************************************************

i = 1;
% A finite state machine to parse name-value pairs.
if rem(nargin-2,2) ~= 0
  error('Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin-2
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
    options.(deblank(Names(j,:))) = arg;
    expectval = 0;      
  end
  i = i + 1;
end

if expectval
  error(sprintf('Expected value for property ''%s''.', arg));
end

    
%**************************************************************************
% Création des interpolateurs RBF
%**************************************************************************

switch lower(options.('RBFFunction'))
      case 'linear'          
        options.('rbfphi')   = @rbfphi_linear;
      case 'cubic'
        options.('rbfphi')   = @rbfphi_cubic;
      case 'multiquadric'
        options.('rbfphi')   = @rbfphi_multiquadrics;
      case 'thinplate'
        options.('rbfphi')   = @rbfphi_thinplate;
      case 'gaussian'
        options.('rbfphi')   = @rbfphi_gaussian;
    otherwise
        options.('rbfphi')   = @rbfphi_linear;
end

phi       = options.('rbfphi');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul des coefficents RBF  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A=rbfAssemble(x, phi, options.('RBFConstant'), options.('RBFSmooth'));

b=[y'; zeros(nXDim+1, 1)];                       

rbfcoeff=A\b;

options.('rbfcoeff') = rbfcoeff;


if (strcmp(options.('Stats'),'on'))
    fprintf('%d point RBF interpolation was created in %e sec\n', length(y), toc);  
    fprintf('\n');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonction de création de la matrice (n+dim+1)*(n+dim+1) correspondant à 
% l'interpolation RBF constituée de la fonction de base et de la partie 
% polynomiale : fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A]=rbfAssemble(x, phi, const, smooth)
[dim n]=size(x);
A=zeros(n,n);
for i=1:n
    for j=1:i
        r=norm(x(:,i)-x(:,j));
        temp=feval(phi,r, const);
        A(i,j)=temp;
        A(j,i)=temp;
    end
    A(i,i) = A(i,i) - smooth;
end
% Partie polynomiale
P=[ones(n,1) x'];
A = [ A      P
      P' zeros(dim+1,dim+1)];

%**************************************************************************
% Radial Base Functions
%************************************************************************** 
function u=rbfphi_linear(r, const)
u=r;

function u=rbfphi_cubic(r, const)
u=r.*r.*r;

function u=rbfphi_gaussian(r, const)
u=exp(-0.5*r.*r/(const*const));

function u=rbfphi_multiquadrics(r, const)
u=sqrt(1+r.*r/(const*const));

function u=rbfphi_thinplate(r, const)

u=r.*r.*log((r+0.001).^2);