clear all
% Ouverture du fichier
fid=fopen('/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/340531NS060613/stats/aseg.stats','rt');

%lecture de la première ligne
fseek(fid,0,'bof');
tline = fgetl(fid);
matg = []; %matrice pour recevoir les données de l'hippocampe gauche
matd = []; %matrice pour recevoir les données de l'hippocampe droit
mat = []; %matrice finale pour les données de l'hippocampe 

while tline~=-1
    % On récupère toutes les données de la ligne séparées
    a = strread(tline,'%s','delimiter',' ');
    % On test si la première donnée est la colonne 12 (hippocampe gauche)
    if strcmp(a{1},'12')
        %on récupère la valeur numérique à la 4e
        % position sur la ligne 
        matg = [matg a{4}];
        matg = str2num(matg);
        disp(tline)
    end
    if strcmp(a{1},'27') %Même chose pour l'hippocampe droit
        %on récupère la valeur numérique à la 4eme 
        % position sur la ligne 
        matd = [matd a{4}];
        matd = str2num(matd);
        disp(tline)
    end
    tline = fgetl(fid);
    format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
    mat = [matg,matd];
end
fclose(fid);
