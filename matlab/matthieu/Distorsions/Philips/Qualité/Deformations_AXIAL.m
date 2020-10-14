function table = Deformations_AXIAL(P,X,cp)

    %% Calcul de la déformation suivant x, y et radiale

x=P(:,1);
y=P(:,2);
dx=X(:,1)-x;
dy=X(:,2)-y;      
dr=sqrt(dx.^2+dy.^2);

    %% Valeurs caractéristiques de déformations
    
% Suivant x

[maxx,indxa] = max(abs(dx));    % maximum de distorsion
coordxmx = P(indxa,:);
[minx,indxb] = min(abs(dx));    % minimum
coordxmn = P(indxb,:);
moyx=mean(abs(dx));             % moyenne
sdx = std(abs(dx));             % écart-type

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

tablex = struct('CoupeAXIAL',{cp},'meanx',{moyx},'minx',{minx},'maxx',{maxx},'sdx',{sdx});
tabley = struct('CoupeAXIAL',{cp},'meany',{moyy},'miny',{miny},'maxy',{maxy},'sdy',{sdy});
tabler = struct('CoupeAXIAL',{cp},'meanr',{moyr},'minr',{minr},'maxr',{maxr},'sdr',{sdr});
table = cell(1,3);
table{1} = tablex;
table{2} = tabley;
table{3} = tabler;
