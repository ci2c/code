clear all

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1'); %met dans 'liste' les repertoires du dossier


s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1/'; 
s4= '_M6/stats/lh.entorhinal_exvivo.stats'; %Pour l'instant le script prend que le M6

mat_surf_ent = []; %matrice finale pour les données surfaciques du cortex enthorinal
mat_thick_ent = []; %Matrice finale pour les données d'épaisseur du cortex enthorinal
matt=[];
mats=[];
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
            a = strread(tline,'%s','delimiter',' ');
                if strcmp(a{1},'lh.entorhinal_exvivo.label')
                    %on récupère la valeur numérique à la 2e
                    % position sur la ligne = surface
                    mats = str2num(a{2});
                    %disp(tline)
               end
               if strcmp(a{1},'lh.entorhinal_exvivo.label') 
                    %on récupère la valeur numérique à la 4eme 
                    % position sur la ligne = epaisseur
                    matt = str2num(a{4});
                    %disp(tline)
               end
             tline = fgetl(fid);
             format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      matn(j)={(liste(i).name(1:end-3))};
      mat_surf_ent(j,1) = [mats];
      mat_thick_ent(j,1)=[matt];

    end
      


end
disp(mat_surf_ent)
disp(mat_thick_ent)
%disp(matn)