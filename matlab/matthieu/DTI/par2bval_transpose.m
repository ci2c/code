% -----------------------------------------------------------------------------%
%                  par2bval by Julien Dumont & Pierre Besson
%
%   Convert Philips par file to bvec & bval files
%   @par_file    string    input par path
%   Required : dcm2nii, fslsplit, fslmerge
%
%   v.1.0 + 2013-03-28
%         + 2013-04-02  - JD : Fix minnor bug : B0 first or last postion in par
%         + 2013-04-04  - JD : Add exist file test
%                       - PB : Normalisation de la norme des directions
%         + 2013-04-09  - JD : Add gen nii file with b0 good order
%                              Remove b mean dynamique      
%         + 2013-12-12  - MV : Transpose bvec and bval
% ------------------------------------------------------------------------------%

function par2bval_transpose( par_file )

if ~exist(par_file,'file')
    warning('Le fichier n existe pas');
else
% Analyse du fichier
    [rep,fich,ext] = fileparts(par_file);
% Preparation des temp
    rep_temp = [rep,'/','temp_',fich];
    system(['mkdir -p ',rep_temp,'/nii']);
    fichier_temp = [rep,'/','temp_',fich,'/','temp_',fich,'.txt'];
    % On verifie la class de l'extension pour donner la bonne au rec
        if strcmp(ext,'.par')
            ext_rec='.rec';
        else
            ext_rec='.REC';
        end
    rec_file = [rep,'/',fich,ext_rec];
    % Copy des fichiers dans le temp
        system(['cp ',par_file,' ',rep_temp]);
        system(['cp ',rec_file,' ',rep_temp]);
    % Creation nii
        if exist(rec_file,'file')==2
            cmd_convert = ['dcm2nii -f n -g n -r n -x n -v n -o ',rep_temp,'/nii ', rep_temp,'/',fich,ext];
            system(cmd_convert);
            [~,fichier_nii]=system(['ls ', rep_temp,'/nii/']);
            fichier_nii=[rep_temp,'/nii/',strtrim(fichier_nii)];
        else
            warning('Pas de fichier REC, le fichier nii ne sera pas cree');
        end    
% Extraction tableau
    % On cherche la premiere ligne du tableau
        cmd_sed_debut= ['sed -n ''/= IMAGE INFORMATION =/='' ',par_file];
        [~,extract_debut]=system(cmd_sed_debut);
        ligne_debut=str2num(extract_debut) + 3;
    % On cherche la derniere ligne du tableau
        cmd_sed_fin=  ['sed -n ''/# === END OF DATA DESCRIPTION FILE =/='' ',par_file];
        [~,extract_fin]=system(cmd_sed_fin);
        ligne_fin=str2num(extract_fin) -2 ;
    % On extrait le tableau
        cmd_sed_extract=['sed -n ''',num2str(ligne_debut),',',num2str(ligne_fin),'p'' ',par_file];
        [~,extract_tab]=system(cmd_sed_extract);
        tab=char(extract_tab);
    % On sauvegarde le fichier temporaire    
        fid=fopen(fichier_temp,'wt');
        fprintf(fid,tab);
        fclose(fid);
    % On recupere les rotations
        search_this_info='Angulation midslice';
        awk_cmd = ['awk ''/',search_this_info,'/'' ',par_file];
        [~,extract] =system(awk_cmd);
        my_split=regexp(extract,':','split');
        angle =  eval(['[',char(strrep(strtrim(my_split(2)),'  ',';')),']']);
% Extraction des donnees
    % Chargement du fichier temp dans une matrice
        S=load(fichier_temp);
    % Extraction des colonnes et des lignes
        [l,c]=size(S);
    % Extraction des b values pour le bval    
        b_val=S([1:max(S(:,1)):l],c-15);
    % Extraction des coordonn?es pour le bvec    
        S=S([1:max(S(:,1)):l],[(c-3):1:(c-1)]); % On selectionne les 3 colonnes de coordonnees de chaque lignes differentes
    % Correction de l'ordre des B, i.e. le B = 0 doit etre en premier
        % On cherche le b0
            pos_b0=find(b_val==0);
            pos_b0_init=pos_b0; % On garde la position avant replacement
            if length(pos_b0)>1
                warning('Attention plusieurs b0, les fichiers bvec et bval seront erronnes');
            end
            dyn_a_supprimer=[];
        % On cherche les valeur nul dans S autre que B0, i.e. les moyennes des b
            pos_0 = find(S(:,1)==0); length_pos_0 = length(pos_0);
            if length_pos_0 > 1
                for i=1:length_pos_0
                   % Suppression [0 0 0] lorsque ce n'est pas le B0 
                   if (pos_0(i)~= pos_b0(1)) & length(find(S(pos_0(i),:)==[0 0 0]))==3
                    b_val = [b_val([1:1:pos_0(i)-1],1);b_val([pos_0(i)+1:1:end],1)];
                    S = [S([1:1:pos_0(i)-1],:);S([pos_0(i)+1:1:end],:)];
                    dyn_a_supprimer(end+1)=pos_0(i);
                   end    
                end
            end
        % On replace le B0 en premier ligne sauf si c'est deja le cas
            if pos_b0~=1
                pos_b0=find(b_val==0); % On recalcul la place de B0 car il peut avoir change avec la suppression des b moyen
                length_b_val = length(b_val);
                if pos_b0==length_b_val % si le b0 est en derniere position
                    b_val=[b_val(end,1);b_val([1:1:end-1],:)];
                    S=[S(end,[1,2,3]);S([1:1:end-1],:)];
                else % si le b0 est au milieu des autres b
                    b_val=[b_val(pos_b0,1);b_val([1:1:pos_b0-1],1);b_val([pos_b0+1:1:end],1)];
                    S=[S(pos_b0,:);S([1:1:pos_b0-1],:);S([pos_b0+1:1:end],:)];
                end    
            end    
    % Rotation
        angle_x = deg2rad(angle(1));
        angle_y = deg2rad(angle(2));
        angle_z = deg2rad(angle(3));
        rot_x = [1 0 0;0 cos(angle_x) sin(angle_x);0 -sin(angle_x) cos(angle_x)];
        rot_y = [cos(angle_y) 0 -sin(angle_y);0 1 0;sin(angle_y) 0 cos(angle_y)];
        rot_z = [cos(angle_z) sin(angle_z) 0;-sin(angle_z) cos(angle_z) 0;0 0 1];
    % Normalisation de la norme des directions
        Temp=repmat(sqrt(sum(S.*S, 2)), 1, 3);
        S = S ./ Temp;
        S(~isfinite(S)) = 0;
    % On applique les matrices de rotation    
        S=rot_x*rot_y*rot_z*S';
    % Re-classement et modification des signes (-Z +X -Y)
        S=[-S(3,:);S(1,:);-S(2,:)];
% Ecriture des fichiers
    % Ecriture du bvec
        fichier_bvec = [rep,'/',fich,'.bvec'];
        dlmwrite(fichier_bvec,S','delimiter',' ','precision','%.3f');
    % Ecriture du bval
        fichier_bval = [rep,'/',fich,'.bval'];
        dlmwrite(fichier_bval,b_val,'delimiter',' ','precision','%.0f');
    % Ecriture du nii
        % Modification du fichier nii si le B0 pas en premier ou dynamique a supprimer
        if (length(dyn_a_supprimer)>=1  || pos_b0_init ~=1) 
            system(['mkdir -p ',rep_temp,'/split']);
          % Split des dyn
            cmd_fslsplit = ['fslsplit ',fichier_nii,' ',rep_temp,'/split/split_ -t'];
            system(cmd_fslsplit);
          % suppression des dynamiques dans le nii
            if (length(dyn_a_supprimer)>=1)
                for i=1:length(dyn_a_supprimer)
                    cmd_del_dyn = ['rm ',rep_temp,'/split/*',num2str(dyn_a_supprimer(i)-1),'.nii.gz'];
                    system(cmd_del_dyn);
                end
            end
          % Merge des dyn
                cmd_mv=['mv ',rep_temp,'/split/*0',num2str(pos_b0_init-1),'.nii.gz ',rep_temp,'/split/b0.nii.gz'];
                cmd_merge=['fslmerge -t ',rep_temp,'/merge.nii.gz ',rep_temp,'/split/b0.nii.gz',' ',rep_temp,'/split/split_*'];
                cmd_copy_nii=['mv ',rep_temp,'/merge.nii.gz ',rep,'/',fich,'.nii.gz'];        
            system(cmd_mv);
            system(cmd_merge);
            system(cmd_copy_nii);
        else
           cmd_mv_nii =['mv ',fichier_nii,' ',rep,'/',fich,'.nii'];
           system(cmd_mv_nii);
        end
        
           
        
% Suppression du fichier temporaire
        cmd_del=['rm -rf ',rep_temp,'/'];
        system(cmd_del);
end
    
end

