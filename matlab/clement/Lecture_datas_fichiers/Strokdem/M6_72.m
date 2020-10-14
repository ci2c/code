%% Script pour calculer la différence entre M6 et 72h 





[~, subjidTC, b] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog_hip.xls');
[~, subjidNTC, c] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Trouble_Cog_hip.xls');


valTC72=[];
valNTC72=[];

valTC6=[];
valNTC6=[];


ind_excludeTC=[];
ind_excludeNTC=[];

%Chez les TC, prend uniquement les sujets qui ont un 72h + M6

for j=1:length(subjidTC)
    M6TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTC(j)),'_M6/stats/aseg.stats'];
    H72TC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidTC(j)),'_72H/stats/aseg.stats'];
    
     A=exist(M6TC,'file');
     B=exist(H72TC,'file');
     
    %Exclus les ID de sujets qui ne remplissent pas cette condition
    if (A==0) || (B==0)
        ind_excludeTC=[ind_excludeTC j];
    end
end

clear j


% Idem, pour les NTC prend uniquement les sujets qui ont un 72h + M6
for j=1:length(subjidNTC)
    M6NTC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidNTC(j)),'_M6/stats/aseg.stats'];
    H72NTC=['/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/',char(subjidNTC(j)),'_72H/stats/aseg.stats'];
    A=exist(M6NTC,'file');
    B=exist(H72NTC,'file');
    
     
    %Exclus les sujets qui ne remplissent pas cette condition
    if (A==0 ) || (B==0)
        ind_excludeNTC=[ind_excludeNTC j];
    end
end


j=1;

%Défini dans Subjid les ID des sujets que l'on va prendre
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

j=1;

 if length(ind_excludeNTC)==0
     SubjidNTC=subjidNTC;
 else
    for i=1:length(subjidNTC)
        if (i~=ind_excludeNTC)
            SubjidNTC(j)=subjidNTC(i);
            ind_S(j)=i;
            j=j+1;
        end
    end
 end

 
 clear i j
 
 j=0;
 


%Récupération du sexe pour les TC
sexeTC=[];
e=1;


for z=1:length(b)

    if strcmp(SubjidTC(e),b(z)) == 1
       sexeTC=[sexeTC;b(z,3)];
       e=e+1;
    end
end
clear e z

%Récupération du sexe pour les NTC
sexeNTC=[];
e=1;

for z=1:length(c)

    if strcmp(SubjidNTC(e),c(z)) == 1
       sexeNTC=[sexeNTC;c(z,3)];
       e=e+1;
    end
end 

sexeTC=cell2mat(sexeTC);
sexeNTC=cell2mat(sexeNTC);
 
 for i=1:length(SubjidTC)

    s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/';
    s4 = '_72H/stats/lh.aparc.stats';
    
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
              a = strread(tline,'%s','delimiter',' ');
                if strcmp(a{1},'entorhinal')
                    %on récupère la valeur numérique à la 2e
                    % position sur la ligne = surface
                    mats = str2num(a{3});
                    %disp(tline)
               end
               if strcmp(a{1},'entorhinal') 
                    %on récupère la valeur numérique à la 5eme 
                    % position sur la ligne = epaisseur
                    matt = str2num(a{5});
                    %disp(tline)
               end
             tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      valTC72_surf(j,1) = [mats];
      valTC72_thick(j,1)=[matt];

    end
     
     
     
 end 

clear i j mats matt
j=0;
 
for i=1:length(SubjidNTC)

    
    s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/';
    s4 = '_72H/stats/lh.aparc.stats';
    
    s=char(strcat(s1,SubjidNTC(i),s4));
        
    % Ouverture du fichier
    fid=fopen(s,'rt');
     
    if fid ~= -1 %Si il arrive à aller chercher le fichier
        j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ');
                if strcmp(a{1},'entorhinal')
                    %on récupère la valeur numérique à la 2e
                    % position sur la ligne = surface
                    mats = str2num(a{3});
                    %disp(tline)
               end
               if strcmp(a{1},'entorhinal') 
                    %on récupère la valeur numérique à la 5eme 
                    % position sur la ligne = epaisseur
                    matt = str2num(a{5});
                    %disp(tline)
               end
             tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      valNTC72_surf(j,1) = [mats];
      valNTC72_thick(j,1)= [matt];

    end
     
    

end 
clear i j
j=0;

%% M6

for i=1:length(SubjidTC)

    s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/';
    s4 = '_M6/stats/lh.aparc.stats';
    
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
            a = strread(tline,'%s','delimiter',' ');
                if strcmp(a{1},'entorhinal')
                    %on récupère la valeur numérique à la 2e
                    % position sur la ligne = surface
                    mats = str2num(a{3});
                    %disp(tline)
               end
               if strcmp(a{1},'entorhinal') 
                    %on récupère la valeur numérique à la 5eme 
                    % position sur la ligne = epaisseur
                    matt = str2num(a{5});
                    %disp(tline)
               end
             tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      valTC6_surf(j,1) = [mats];
      valTC6_thick(j,1)=[matt];
    end
     
     
     
end 

clear i j
j=0;
for i=1:length(SubjidNTC)

    
    s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/';
    s4 = '_M6/stats/lh.aparc.stats';
    
    s=char(strcat(s1,SubjidNTC(i),s4));
        
    % Ouverture du fichier
    fid=fopen(s,'rt');
     
    if fid ~= -1 %Si il arrive à aller chercher le fichier
        j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ');
                if strcmp(a{1},'entorhinal')
                    %on récupère la valeur numérique à la 2e
                    % position sur la ligne = surface
                    mats = str2num(a{3});
                    %disp(tline)
               end
               if strcmp(a{1},'entorhinal') 
                    %on récupère la valeur numérique à la 5eme 
                    % position sur la ligne = epaisseur
                    matt = str2num(a{5});
                    %disp(tline)
               end
             tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      valNTC6_surf(j,1) = [mats];
      valNTC6_thick(j,1)=[matt];
      
    end
     
   
end 

%% Calcul de la différence M6-72H

%Surface
valTCd_surf=valTC72_surf-valTC6_surf;
valNTCd_surf=valNTC72_surf-valNTC6_surf;

%Epaisseur
valTCd_thick=valTC72_thick-valTC6_thick;
valNTCd_thick=valNTC72_thick-valNTC6_thick;


