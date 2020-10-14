
liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask'); %met dans 'liste' les repertoires du dossier


s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 
s4= '_M6/stats/aseg.stats'; %Pour l'instant le script prend que le M6

matg = []; %matrice pour recevoir les données de l'hippocampe gauche
matd = []; %matrice pour recevoir les données de l'hippocampe droit
%matn = {}; %cellule pour récupérer le numéro du sujet
mat = []; %matrice finale pour les données de l'hippocampe 
j=0; 

%Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:length(liste)
	%disp(liste(i).name)
    
    s2 = liste(i).name;
    s3 = s2(1:end-3);
    s=strcat(s1,s3,s4);
        
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
                if  sizeA(:,1)>1 & strcmp(a{3},'CorticalWhiteMatter')==1
                    %on récupère la valeur numérique à la 4e
                    % position sur la ligne 
                    matg = str2num(a{10});
                    %disp(tline)
                end
            tline = fgetl(fid);
            format ('short'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      matn(j)={(liste(i).name(1:end-3))};
%       disp(matn(j))
%       disp(matg)
      mat = [mat;matg];

      
    end
      


end
