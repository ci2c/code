function [hier] = FMRI_HierarchicalClustering(X,type,p)

% usage : hier = FMRI_HierarchicalClustering(X,[type,p])
%
% Inputs :
%    X           : data 2D array T*N
%
% Options :
%    type        : similarity measure ('norm2','corr','abscorr'). Default:
%                  'norm2'
%    p           : weightening for each individual. Default: 1/N
%
% Output :
%    hier        : 2D array defining a hierarchy
%
% Renaud Lopes @ CHRU Lille, Mar 2012

[T,N] = size(X);

if nargin ~= 1 && nargin ~= 2 && nargin ~= 3
    error('invalid usage');
end

default_type = 'norm2';
default_p    = (1/N)*ones([N,1]);

% check args
if nargin < 2
    type = default_type;
end

if nargin < 3
    p = default_p;
end

if strcmp(type,'norm2')
    g  = X;
    nX = sum(X.^2,1);
    D  = (ones([N,1])*nX + nX'*ones([1 N]) -2* X'*X);
    D  = D .* ((p*p')./(p*ones([1,N])+ones([N,1])*p'));    
    D(eye(size(D))==1) = Inf;
end

if strcmp(type,'corr')
    C = zeros(N,N);
    for pp=1:N
        for qq=1:N
            C(pp,qq) = X(:,pp)'*X(:,qq);
        end
    end
    S = (1/(T-1)).*C;
    clear C
    R = S./sqrt(diag(S)*diag(S)');
    clear S
    R(R<0) = 0;
    D = sqrt(1-R);
    clear R
    D(eye(size(D))==1) = Inf;
    g = X;
    clear X
end

if strcmp(type,'abscorr')
    C = zeros(N,N);
    for pp=1:N
        for qq=1:N
            C(pp,qq) = X(:,pp)'*X(:,qq);
        end
    end
    S = (1/(T-1)).*C;
    clear C
    R = S./sqrt(diag(S)*diag(S)');
    clear S
    D = sqrt(1-abs(R));
    %D = 1-R.*R;
    D(eye(size(D))==1) = Inf;
    %g = X;
    clear X
end

nb_ind = size(D,1);
objets = 1:nb_ind;          % On initialise les labels d'objets.
hier   = [];                % On initialise la hierarchie. 

while (length(objets)>1)&(min(D(:))~=Inf)
    
    %fprintf('%d - ',length(objets))
    % On calcule les partitions les plus proches et on les fusionne.
    [X,Y] = find(D==min(D(:)));
    if length(X)==1
        X(1) = X;
        X(2) = Y;
        Y(1) = Y;
        Y(2) = X(1);
    end
    hier = [hier ; D(X(1),Y(1)) objets(X(1)) objets(Y(1)) max(objets)+1];
    
    % On met la matrice de distances a jour
    D(X(1),:)    = (1./(p'+p(X(1))+p(Y(1)))).*((p'+p(X(1))).*D(X(1),:)+(p'+p(Y(1))).*D(Y(1),:)-p'*D(X(1),Y(1)));    
    D(:,X(1))    = D(X(1),:)';
    D(X(1),X(1)) = Inf; 
    
    % On met la liste de taille a jour
    p(X(1)) = p(X(1))+p(Y(1));
    
    % On recupere les objets interessants.
    D = D(1:size(D,1) ~= Y(1),1:size(D,1) ~= Y(1));
    
    p = p((1:length(p))~=Y(1));
    
    % On met la liste d'objets a jour
    objets(X(1)) = max(objets)+1;    
    objets       = objets(1:length(objets) ~= Y(1));    
    
end

       
