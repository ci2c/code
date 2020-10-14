% Script pour avoir le delta 72-M6 du volume de l'hippocampe chez TOUS les
% sujets strokdem (pas tenir compte du TC)


liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask'); %met dans 'liste' les repertoires du dossier


s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 


matg = []; %matrice pour recevoir les données de l'hippocampe gauche
matd = []; %matrice pour recevoir les données de l'hippocampe droit
%matn = {}; %cellule pour récupérer le numéro du sujet
mat6 = [];
mat72 = [];
j=0; 

ind_excludeTC=[];

%% Recupération des ID qui ont 72 + M6
subjidTC=[];

for i=1:length(liste)
    
    subjidTC=[subjidTC;{liste(i).name(1:end-3)}];
end


for z=1:length(liste)
    
    M6TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTC(z)),'_M6/stats/aseg.stats'];
    H72TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTC(z)),'_72H/stats/aseg.stats'];
    
     A=exist(M6TC,'file');
     B=exist(H72TC,'file');
     
    %Exclu les ID de sujets qui ne remplissent pas cette condition
    if (A==0) || (B==0)
        ind_excludeTC=[ind_excludeTC z];
    end
end

j=1;

 if length(ind_excludeTC)==0
     SubjidTC=subjidTC;
 else
    for i=1:length(subjidTC)
        if (i~=ind_excludeTC)
            SubjidTC(j)=subjidTC(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end
 
 clear j

%% Récupération des valeurs M6
 j=0;
%Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:length(SubjidTC)
	%disp(liste(i).name)
    s4= '_M6/stats/aseg.stats'; %Pour M6
    
    s2 = liste(i).name;
    s3 = s2(1:end-3);
    s=char(strcat(s1,SubjidTC(i),s4));
        
    % Ouverture du fichier
    fid=fopen(s,'rt');
     
    if fid ~= -1 %Si il arrive à aller chercher le fichier
        j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ,');
                % On test si la première donnée est la ligne 12 (hippocampe gauche)
                sizeA=size(a);
                if  sizeA(:,1)>1 & strcmp(a{3},'IntraCranialVol')==1
                    %on récupère la valeur numérique à la 4e
                    % position sur la ligne 
                    matg = str2num(a{7});
                    %disp(tline)
                end
            tline = fgetl(fid);
            format ('short'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);

      mat6 = [mat6;matg];


    end
      
end

matg = [];
matd = [];


%% Récupération des valeurs 72H 
 j=0;
%Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:length(SubjidTC)
	%disp(liste(i).name)
    s4= '_72H/stats/aseg.stats'; %Pour M6
    
    s2 = liste(i).name;
    s3 = s2(1:end-3);
    s=char(strcat(s1,SubjidTC(i),s4));
        
    % Ouverture du fichier
    fid=fopen(s,'rt');
     
    if fid ~= -1 %Si il arrive à aller chercher le fichier
        j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ,');
                % On test si la première donnée est la ligne 12 (hippocampe gauche)
                sizeA=size(a);
                if  sizeA(:,1)>1 & strcmp(a{3},'IntraCranialVol')==1
                    %on récupère la valeur numérique à la 4e
                    % position sur la ligne 
                    matg = str2num(a{7});
                    %disp(tline)
                end
            tline = fgetl(fid);
            format ('short'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);

      mat72 = [mat72;matg];
    end
      
end

%% Delta

Delta = mat72 - mat6;