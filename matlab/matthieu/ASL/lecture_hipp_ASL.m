clear all; close all;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% Get back brain characteristics %%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% fid = fopen('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/subjects.txt','r');
% P = textscan(fid,'%s');
% fclose(fid);
% 
% %% Hyppocampal volumes and TIV
% 
% % matg = []; %matrice pour recevoir les données de l'hippocampe gauche
% % matd = []; %matrice pour recevoir les données de l'hippocampe droit
% % mateTIV = []; %matrice pour recevoir les données d'estimation du volume total intracranial
% % mat = []; %matrice finale pour les données de l'hippocampe 
% % j=0; 
% % 
% % %Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
% % for i=1:length(P{1})
% %     
% % %     s2 = liste(i).name;
% % %     s3 = s2(1:end-3);
% % %     s=strcat(s1,s3,s4);
% %     s = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3',P{1}{i},'stats/aseg.stats');
% %         
% %     % Ouverture du fichier
% %     fid=fopen(s,'rt');
% %      
% %     if fid ~= -1 %Si il arrive à aller chercher le fichier
% %         j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
% %         %lecture de la première ligne 
% %         fseek(fid,0,'bof');
% %         tline = fgetl(fid);
% %             while tline~=-1
% %                 % On récupère toutes les données de la ligne séparées
% %                 a = strread(tline,'%s','delimiter',' ');
% %                 % On test si la première donnée est la ligne EstimatedTotalIntraCranialVol (eTIV)
% %                 if size(a,1) >= 3
% %                     if strcmp(a{3}(1:end-1),'EstimatedTotalIntraCranialVol')
% %                         % on récupère la valeur numérique à la 9e
% %                         % position sur la ligne 
% %                         mateTIV = str2num(a{9}(1:end-1));
% %                         %disp(tline)
% %                     end
% %                 end
% %                 % On test si la première donnée est la ligne 12 (hippocampe gauche)
% %                 if strcmp(a{1},'12')
% %                     %on récupère la valeur numérique à la 4e
% %                     % position sur la ligne 
% %                     matg = str2num(a{4});
% %                     %disp(tline)
% %                 end
% %                 if strcmp(a{1},'27') %Même chose pour l'hippocampe droit (ligne 27)
% %                     %on récupère la valeur numérique à la 4eme 
% %                     % position sur la ligne 
% %                     matd = str2num(a{4});
% %                     %disp(tline)
% %                 end
% %                 tline = fgetl(fid);
% %                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
% %             end
% %         fclose(fid);
% %         mat(j,:) = [matg , matd , mateTIV];
% %     end
% % end
% % saveascii(mat,'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/HyppoVolumes.txt',6);
% % % save('/NAS/dumbo/protocoles/ictus/Data/PATIENTS_64dir/Description_files/HypoVolumes.txt', 'S', '-ASCII');
% 
% %% Cortex surfaces : entorhinal, parahippocampal and temporal
% 
% matg = []; %matrice pour recevoir les données de l'hémisphère gauche
% matd = []; %matrice pour recevoir les données de l'hémisphère droit
% mateTIV = []; %matrice pour recevoir les données d'estimation du volume total intracranial
% mat = []; %matrice finale pour les surfaces du cortex
% j=0; 
% k=0;
% l=0;
% 
% %Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
% for i=1:length(P{1})
%     
%     s = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3',P{1}{i},'stats/lh.aparc.stats');
%         
%     % Ouverture du fichier
%     fid=fopen(s,'rt');
%      
%     if fid ~= -1 %Si il arrive à aller chercher le fichier
%         j=j+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
%         %lecture de la première ligne 
%         fseek(fid,0,'bof');
%         tline = fgetl(fid);
%             while tline~=-1
%                 % On récupère toutes les données de la ligne séparées
%                 a = strread(tline,'%s','delimiter',' ');
%                 if strcmp(a{1},'entorhinal')
%                     %on récupère la valeur numérique à la 3ème position sur la ligne 
%                     s_ent = str2num(a{3});
%                 end
%                 if strcmp(a{1},'parahippocampal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_parahyp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'inferiortemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_inftemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'middletemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_midtemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'superiortemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_suptemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'temporalpole') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_poletemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'transversetemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_transtemp = str2num(a{3});
%                 end
%                 tline = fgetl(fid);
%                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
%             end
%         fclose(fid);
%         matg(j,:) = [s_ent s_parahyp (s_inftemp+s_midtemp+s_suptemp+s_poletemp+s_transtemp)];
%     end
%     
%     s = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3',P{1}{i},'stats/rh.aparc.stats');
%         
%     % Ouverture du fichier
%     fid=fopen(s,'rt');
%      
%     if fid ~= -1 %Si il arrive à aller chercher le fichier
%         k=k+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
%         %lecture de la première ligne 
%         fseek(fid,0,'bof');
%         tline = fgetl(fid);
%             while tline~=-1
%                 % On récupère toutes les données de la ligne séparées
%                 a = strread(tline,'%s','delimiter',' ');
%                 if strcmp(a{1},'entorhinal')
%                     %on récupère la valeur numérique à la 3ème position sur la ligne 
%                     s_ent = str2num(a{3});
%                 end
%                 if strcmp(a{1},'parahippocampal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_parahyp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'inferiortemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_inftemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'middletemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_midtemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'superiortemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_suptemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'temporalpole') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_poletemp = str2num(a{3});
%                 end
%                 if strcmp(a{1},'transversetemporal') 
%                     %on récupère la valeur numérique à la 3ème position sur la ligne  
%                     s_transtemp = str2num(a{3});
%                 end
%                 tline = fgetl(fid);
%                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
%             end
%         fclose(fid);
%         matd(k,:) = [s_ent s_parahyp (s_inftemp+s_midtemp+s_suptemp+s_poletemp+s_transtemp)];
%     end
%     
%     s = fullfile('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3',P{1}{i},'stats/aseg.stats');
%         
%     % Ouverture du fichier
%     fid=fopen(s,'rt');
%      
%     if fid ~= -1 %Si il arrive à aller chercher le fichier
%         l=l+1; %On fait une nouvelle incrementation pour la matrice de reception "mat", comme ça les valeurs s'ajoutent à la suite
%         %lecture de la première ligne 
%         fseek(fid,0,'bof');
%         tline = fgetl(fid);
%             while tline~=-1
%                 % On récupère toutes les données de la ligne séparées
%                 a = strread(tline,'%s','delimiter',' ');
%                 % On test si la première donnée est la ligne EstimatedTotalIntraCranialVol (eTIV)
%                 if size(a,1) >= 3
%                     if strcmp(a{3}(1:end-1),'EstimatedTotalIntraCranialVol')
%                         % on récupère la valeur numérique à la 9e
%                         % position sur la ligne 
%                         mateTIV = str2num(a{9}(1:end-1));
%                         %disp(tline)
%                     end
%                 end
%                 tline = fgetl(fid);
%                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
%             end
%         fclose(fid);
%         if (j == k) && (k == l)
%             mat(l,:) = [matg(j,:) matd(k,:) mateTIV];
%         else
%             error('Incoherence between lines : num2str(j) num2str(k) num2str(l)');
%         end
%     end
% end
% saveascii(mat,'/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/CorticalSurf/CorticalSurfaces.txt',6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Statistical group analysis %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Load group data from file "glim_HyppoVolumes_eTIV.txt"
% [LVolHyp, RVolHyp, tiv, group, sex, age] = textread('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/HyppoVolumes/glim_HyppoVolumes_eTIV.txt', '%f %f %f %s %s %f');
% 
% %% Read group CT data and view meanCT
% Y = LVolHyp;
% % Y = RVolHyp;
% % Y = age;
% 
% %% Fitting the linear model
% Group = term(group);
% TIV = term(tiv);
% Age = term(age);
% Sex = term(sex);
% M=1+Group+TIV+Age+Sex;
% 
% figure(6)
% image(M);
% 
% slm = SurfStatLinMod( Y, M );
% 
% %% Main effect of Group
% contrast = Group.control-Group.left;
% slm = SurfStatT( slm, contrast );
% 
% %% View the P-values for each vertex
% pval = SurfStatP(slm);
% 
% disp(pval)

%% Load group data from file "glim_CorticalSurf_eTIV.txt"
[Lenth, Lparahyp, Ltemp, Renth, Rparahyp, Rtemp, tiv, group, age, sex] = textread('/NAS/dumbo/matthieu/ASL_Epilepsy/FS_5.3/Description_files/CorticalSurf/glim_CorticalSurf_eTIV.txt', '%f %f %f %f %f %f %f %s %f %s');

%% Read group CT data and view meanCT
Y = Renth;
% Y = RVolHyp;
% Y = age;

%% Fitting the linear model
Group = term(group);
TIV = term(tiv);
Age = term(age);
Sex = term(sex);
M=1+Group+Age+Sex+TIV;

% figure(6)
% image(M);

slm = SurfStatLinMod( Y, M );

%% Main effect of Group
contrast = Group.control-Group.right;
slm = SurfStatT( slm, contrast );

%% View the P-values for each vertex
pval = SurfStatP(slm);

disp(pval)