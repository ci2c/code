function [f] = rbfinterp(x, options)
tic;
phi       = options.('rbfphi');
rbfconst  = options.('RBFConstant');
nodes     = options.('x');
rbfcoeff  = (options.('rbfcoeff'))';


[dim              n] = size(nodes);
[dimPoints  nPoints] = size(x);

if (dim~=dimPoints)
  error(sprintf('x devrait avoir le m�me nombre de lignes qu une matrice utilis�e pour cr�er une interpolation RBF'));
end;

f = zeros(1, nPoints);
r = zeros(1, n);

for i=1:1:nPoints
	s=0;
    r =  (x(:,i)*ones(1,n)) - nodes;
    r = sqrt(sum(r.*r, 1));
    
    s = rbfcoeff(n+1) + sum(rbfcoeff(1:n).*feval(phi, r, rbfconst));
 
	for k=1:dim
       s=s+rbfcoeff(k+n+1)*x(k,i);     % partie lin�aire
	end
	f(i) = s;
end;

if (strcmp(options.('Stats'),'on'))
    fprintf('Interpolation � %d points a �t� calcul�e en %e sec\n', length(f), toc);    
end;
