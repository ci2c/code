% va dans le dossier où sont les datas des sujets, extrait le nom de chaque
% et ensuite fait une concatenation pour obtenir l'adresse finale où est
% située le fichier pour les stats. Permettra donc d'aller automatiquement
% chercher le fichier dans chaque dossier.

%% Script pour les datas hippocampe du protocole CogPhenoPark %%

clear all

liste=dir('/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/'); %met dans 'liste' les repertoires du dossier

s1 = '/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/'; 
s3= '/stats/aseg.stats';

matg = []; %matrice pour recevoir les données de l'hippocampe gauche
matd = []; %matrice pour recevoir les données de l'hippocampe droit
%matn = {}; %cellule pour récupérer le numéro du sujet
mat = zeros(67,2); %matrice finale pour les données de l'hippocampe 

%Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:length(liste)
	%disp(liste(i).name)
    
    s2 = liste(i).name;
    s=strcat(s1,s2,s3);
disp (s)

    % Ouverture du fichier
    fid=fopen(s,'rt');
     
    if fid ~= -1 %Si il arrive à aller chercher le fichier
       disp(liste(i).name)
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ');
           
                % On test si la première donnée est la ligne 12 (hippocampe gauche)
                if strcmp(a{1},'12')
                    %on récupère la valeur numérique à la 4e
                    % position sur la ligne 
                    matg = str2num(a{4});
                    %disp(tline)
               end
               if strcmp(a{1},'27') %Même chose pour l'hippocampe droit (ligne 27)
                    %on récupère la valeur numérique à la 4eme 
                    % position sur la ligne 
                    matd = str2num(a{4});
                    %disp(tline)
               end
            tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      matn(i-2)={(liste(i).name)};
      mat(i-2,:) = [matg , matd];
    end
    
end
disp(mat)
%disp(matn)


