load('/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/380126NB_M6/rsfmri/Craddock_Parc/NB31/Connectome_Ck31.mat')

bin=gretna_R2b(Connectome.Cmat,'s',0.3);

G=bin;

su=sum(bin,2);
mat=[su';1:1:313];

SortD=sortrows(mat)';

tmp1=SortD(:,1);
tmp2=SortD(:,2);

SortD(:,1)=tmp1(length(tmp1):-1:1);
SortD(:,2)=tmp2(length(tmp2):-1:1); % Récupère chaque noeud avec sa valeur de degree

clear tmp1 tmp2

ID=find(SortD(:,1) > 2);
test=zeros(313,313);
%% clust

n=length(G);
C=zeros(n,1);

for u=1:length(ID)
    V=find(G(ID(u),:));
    k=length(V);
    if k>=2;                %degree must be at least 2
        S=G(V,V);
        %C(u)=sum(S(:))/(k^2-k); % Calcul le coeff du noeud
        
        test(V,V)=test(V,V)+S;
       
    end
end

imagesc(test);