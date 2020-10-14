clear all
subj=textread('/NAS/tupac/protocoles/Strokdem/FMRI/TCog/CluNTC-TC_all_subjs.txt','%s \n');



mat_surf_ent = []; %matrice finale pour les données surfaciques du cortex enthorinal
mat_thick_ent = []; %Matrice finale pour les données d'épaisseur du cortex enthorinal
matt=[];
mats=[];
j=0; 

%Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:length(subj)
	%disp(liste(i).name)
    subjid = char(subj(i));
    
    file=fullfile('/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/',subjid, 'stats/aseg.stats');

        
    % Ouverture du fichier
    fid=fopen(file,'rt');
    
    if fid ~= -1 %Si il arrive à aller chercher le fichier
        j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
        %lecture de la première ligne 
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            a = strread(tline,'%s','delimiter',', ');
                if length(a) > 3 && strcmp(a{3},'IntraCranialVol')
                    mats = str2num(a{7});
                end
             tline = fgetl(fid);
             format ('shortG');
            end
      fclose(fid);
      
      mat_surf_ent(end+1,:) = mats;
      
    end
end