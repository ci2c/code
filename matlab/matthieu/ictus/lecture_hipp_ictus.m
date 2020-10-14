clear all; close all;

% % liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask'); %met dans 'liste' les repertoires du dossier
% % 
% % 
% % s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 
% % s4= '_M6/stats/aseg.stats'; %Pour l'instant le script prend que le M6
% 
% fid = fopen('/NAS/dumbo/protocoles/ictus/Data/PATIENTS_64dir/Description_files/subjects.txt','r');
% P = textscan(fid,'%s');
% fclose(fid);
% fid = fopen('/NAS/dumbo/protocoles/ictus/Data/TEMOINS/Description_files/subjects.txt','r');
% T = textscan(fid,'%s');
% fclose(fid);
% 
% matg = []; %matrice pour recevoir les données de l'hippocampe gauche
% matd = []; %matrice pour recevoir les données de l'hippocampe droit
% %matn = {}; %cellule pour récupérer le numéro du sujet
% mat = []; %matrice finale pour les données de l'hippocampe 
% j=0; 
% 
% %Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
% for i=1:length(P{1})
%     
% %     s2 = liste(i).name;
% %     s3 = s2(1:end-3);
% %     s=strcat(s1,s3,s4);
%     s = fullfile('/NAS/dumbo/protocoles/ictus/Data/PATIENTS_64dir',P{1}{i},'stats/aseg.stats');
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
%                 % On test si la première donnée est la ligne 12 (hippocampe gauche)
%                 if strcmp(a{1},'12')
%                     %on récupère la valeur numérique à la 4e
%                     % position sur la ligne 
%                     matg = str2num(a{4});
%                     %disp(tline)
%                 end
%                 if strcmp(a{1},'27') %Même chose pour l'hippocampe droit (ligne 27)
%                     %on récupère la valeur numérique à la 4eme 
%                     % position sur la ligne 
%                     matd = str2num(a{4});
%                     %disp(tline)
%                 end
%                 tline = fgetl(fid);
%                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
%             end
%         fclose(fid);
% %       matn(j)={(liste(i).name(1:end-3))};
%         mat(j,:) = [matg , matd];
%     end
% end
% saveascii(mat,'/NAS/dumbo/protocoles/ictus/Data/PATIENTS_64dir/Description_files/HypoVolumes.txt',1);
% % save('/NAS/dumbo/protocoles/ictus/Data/PATIENTS_64dir/Description_files/HypoVolumes.txt', 'S', '-ASCII');
% 
% matg = []; %matrice pour recevoir les données de l'hippocampe gauche
% matd = []; %matrice pour recevoir les données de l'hippocampe droit
% %matn = {}; %cellule pour récupérer le numéro du sujet
% mat = []; %matrice finale pour les données de l'hippocampe 
% j=0; 
% 
% %Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
% for i=1:length(T{1})
%     
% %     s2 = liste(i).name;
% %     s3 = s2(1:end-3);
% %     s=strcat(s1,s3,s4);
%     s = fullfile('/NAS/dumbo/protocoles/ictus/Data/TEMOINS',T{1}{i},'stats/aseg.stats');
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
%                 % On test si la première donnée est la ligne 12 (hippocampe gauche)
%                 if strcmp(a{1},'12')
%                     %on récupère la valeur numérique à la 4e
%                     % position sur la ligne 
%                     matg = str2num(a{4});
%                     %disp(tline)
%                 end
%                 if strcmp(a{1},'27') %Même chose pour l'hippocampe droit (ligne 27)
%                     %on récupère la valeur numérique à la 4eme 
%                     % position sur la ligne 
%                     matd = str2num(a{4});
%                     %disp(tline)
%                 end
%                 tline = fgetl(fid);
%                 format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
%             end
%         fclose(fid);
% %       matn(j)={(liste(i).name(1:end-3))};
%         mat(j,:) = [matg , matd];
%     end
% end
% saveascii(mat,'/NAS/dumbo/protocoles/ictus/Data/TEMOINS/Description_files/HypoVolumes.txt','a',1);
% % save('/NAS/dumbo/protocoles/ictus/Data/TEMOINS/Description_files/HypoVolumes.txt', 'mat', '-ASCII');


%% Load group data from file "glimt_HypoVol.txt"
[LVolHyp, RVolHyp, group, sex, age] = textread('/NAS/dumbo/protocoles/ictus/Data/HypocampicVolumes/glimt_HypoVol.txt', '%f %f %s %s %f');

%% Read group CT data and view meanCT
% Y = LVolHyp;
Y = RVolHyp;
% Y = age;

%% Fitting the linear model
Group = term(group); 
Age = term(age);
Sex = term(sex);
M=1+Group+Age+Sex;

figure(6)
image(M);

slm = SurfStatLinMod( Y, M );

%% Main effect of Group
contrast = Group.temoin-Group.patient;
slm = SurfStatT( slm, contrast );

%% View the P-values for each vertex
pval = SurfStatP(slm);

disp(pval)