function table = Deformations_SAG(P,X,cp)

    %% Calcul de la déformation suivant y, z et radiale

z=P(:,3);
y=P(:,2);
dz=X(:,3)-z;
dy=X(:,2)-y;      
dr=sqrt(dz.^2+dy.^2);

    %% Valeurs caractéristiques de déformations
    
% Suivant z

[maxz,indza] = max(abs(dz));        % maximum de distorsion
coordzmx = P(indza,:);
[minz,indzb] = min(abs(dz));        % minimum
coordzmn = P(indzb,:);
moyz=mean(abs(dz));                 % moyenne
sdz = std(abs(dz));                 % écart-type

% Suivant y

[maxy,indya] = max(abs(dy));
coordymx = P(indya,:);
[miny,indyb] = min(abs(dy));
coordymn = P(indyb,:);
moyy=mean(abs(dy));
sdy = std(abs(dy));

% radiale

[maxr,indra] = max(dr);
coordrmx = P(indra,:);
[minr,indrb] = min(dr);
coordrmn = P(indrb,:);
moyr=mean(dr);
sdr = std(abs(dr));


    %% Construction de la table de résultats


tablez = struct('CoupeSAG',{cp},'meanz',{moyz},'minz',{minz},'maxz',{maxz},'sdz',{sdz});
tabley = struct('CoupeSAG',{cp},'meany',{moyy},'miny',{miny},'maxy',{maxy},'sdy',{sdy});
tabler = struct('CoupeSAG',{cp},'meanr',{moyr},'minr',{minr},'maxr',{maxr},'sdr',{sdr});
table = cell(1,3);
table{1} = tabley;
table{2} = tablez;
table{3} = tabler;
