function P = FMRI_Hier2Partition(hier,par,opt)

% usage : P = FMRI_Hier2Partition(hier,par,[opt])
%
% Inputs :
%    hier       : 2D array defining a hierarchy
%    par        : 1- threshold value for thresholding the hierarchy (opt=0)
%                  2- number of classes (opt=1)
%                  3- the minimal size of one element of the partition
%                  (otherwise) 
%
% Options :
%    opt        : 0=threshold, 1=nb of elements, 2=minimal size. Default: 0
%
% Output :
%    P          : Matrix of the partition
%
% Renaud Lopes @ CHRU Lille, Mar 2012

if nargin ~= 2 && nargin ~= 3
    error('invalid usage');
end

default_opt = 0;

% check args
if nargin < 2
    opt = default_opt;
end

N             = hier(1,4)-1;
nb_partitions = hier(end,4)-N;
objets        = 1:N;
P             = eye(N)>0;
taille        = ones([size(P,1),1]);
niveau        = zeros([size(P,1),1]);

if opt == 0
    while ((~isempty(hier))&(hier(1,1)<par))
        x         = find(objets == hier(1,2));
        y         = find(objets == hier(1,3));
        P(:,x)    = P(:,x) | P(:,y);
        objets(x) = max(objets)+1;
        objets    = objets(1:size(P,2) ~= y);
        P         = P(:,1:size(P,2) ~= y)>0;
        hier      = hier(2:size(hier,1),:);
    end
end    

if opt == 1
    while ((~isempty(hier))&(size(P,2)>par))
        x         = find(objets == hier(1,2));
        y         = find(objets == hier(1,3));
        P(:,x)    = P(:,x) | P(:,y);
        objets(x) = max(objets)+1;
        objets    = objets(1:size(P,2) ~= y);
        P         = P(:,1:size(P,2) ~= y)>0;
        hier      = hier(2:size(hier,1),:);
    end
end    

if opt == 2
    while ((~isempty(hier))&(max(taille)<par))
        x         = find(objets == hier(1,2));
        y         = find(objets == hier(1,3));
        P(:,x)    = P(:,x) | P(:,y);
        objets(x) = max(objets)+1;
        objets    = objets(1:size(P,2) ~= y);
        taille(x) = taille(x)+taille(y);
        taille    = taille(1:size(P,2) ~= y);        
        P         = P(:,1:size(P,2) ~= y)>0;
        hier      = hier(2:size(hier,1),:);
    end    
end    

tmp = zeros([size(P,1),1]);

for i = 1:size(P,2)
    tmp(P(:,i)>0) = i;
end
P = tmp;
