clear all

%% Gauche

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask'); %met dans 'liste' les repertoires du dossier


s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 
s4= '_72H/stats/lh.aparc.stats'; %Pour l'instant le script prend que le M6

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
      matn(j)={(liste(i).name(1:end-3))};
      mat_surf_ent(j,1) = [mats];
      mat_thick_ent(j,1)=[matt];

    end
      


end
% disp(mat_surf_ent)
% disp(mat_thick_ent)
%disp(matn)



%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
valTC_g=[];


ageTC_g=[];
sexeTC_g=[];
ICVTC_g=[];


for i=1:length(b) 
    index=find(ismember(matn,b(i)));     
     if index ~= 0
        valTC_g = [valTC_g;mat_surf_ent(index,:)];   
        ageTC_g=[ageTC_g;a(i,1)];
        sexeTC_g=[sexeTC_g;a(i,2)];
        ICVTC_g=[ICVTC_g;a(i,3)];
     end   
end


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
valNTC_g=[];

ageNTC_g=[];
sexeNTC_g=[];
ICVNTC_g=[];


for i=1:length(b)
index=find(ismember(matn,b(i)));     
    if index ~= 0
       valNTC_g = [valNTC_g;mat_surf_ent(index,:)];   
       ageNTC_g=[ageNTC_g;a(i,1)];
       sexeNTC_g=[sexeNTC_g;a(i,2)];
       ICVNTC_g=[ICVNTC_g;a(i,3)];
    end
end

%% Droite


liste=dir('/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask'); %met dans 'liste' les repertoires du dossier


s1 = '/home/fatmike/Protocoles_3T/Strokdem/FS5.1_T2mask/'; 
s4= '_72H/stats/rh.aparc.stats'; %Pour l'instant le script prend que le M6

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
      matn(j)={(liste(i).name(1:end-3))};
      mat_surf_ent(j,1) = [mats];
      mat_thick_ent(j,1)=[matt];

    end
      


end
% disp(mat_surf_ent)
% disp(mat_thick_ent)
%disp(matn)



%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
valTC_d=[];

ageTC_d=[];
sexeTC_d=[];
ICVTC_d=[];


for i=1:length(b) 
    index=find(ismember(matn,b(i))); 
        if index ~= 0
           valTC_d = [valTC_d;mat_surf_ent(index,:)];   
           ageTC_d=[ageTC_d;a(i,1)];
           sexeTC_d=[sexeTC_d;a(i,2)];
           ICVTC_d=[ICVTC_d;a(i,3)];
        end
         
end

j=1;
k=1;

for i=1:length(valTC_d)
    
    if a(i,4)==1 && a(i,5)==0
        
        TC_ipsi(j,1)=[valTC_g(i)];
        TC_contro(k,1)=[valTC_d(i)];
        ageTC(j,1)=[ageTC_g(i)];
        sexeTC(j,1)=[sexeTC_g(i)];
        ICVTC(j,1)=[ICVTC_g(i)];
        j=j+1;
        k=k+1;
    elseif a(i,4)==0 && a(i,5)==1
        TC_ipsi(j,1)=[valTC_d(i)];
        TC_contro(k,1)=[valTC_g(i)];
        ageTC(j,1)=[ageTC_g(i)];
        sexeTC(j,1)=[sexeTC_g(i)];
        ICVTC(j,1)=[ICVTC_g(i)];
        j=j+1;
        k=k+1;
    end

end


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
valNTC_d=[];

ageNTC_d=[];
sexeNTC_d=[];
ICVNTC_d=[];


for i=1:length(b)
index=find(ismember(matn,b(i))); 
    if index ~= 0
       valNTC_d = [valNTC_d;mat_surf_ent(index,:)];
       ageNTC_d=[ageNTC_d;a(i,1)];
       sexeNTC_d=[sexeNTC_d;a(i,2)];
       ICVNTC_d=[ICVNTC_d;a(i,3)];
    end

end

j=1;
k=1;

for i=1:length(valNTC_d)
    
    if a(i,4)==1 && a(i,5)==0
        
        NTC_ipsi(j,1)=[valNTC_g(i)];
        NTC_contro(k,1)=[valNTC_d(i)];
        ageNTC(j,1)=[ageNTC_g(i)];
        sexeNTC(j,1)=[sexeNTC_g(i)];
        ICVNTC(j,1)=[ICVNTC_g(i)];
        j=j+1;
        k=k+1;
    elseif a(i,4)==0 && a(i,5)==1
        NTC_ipsi(j,1)=[valNTC_d(i)];
        NTC_contro(k,1)=[valNTC_g(i)];
        ageNTC(j,1)=[ageNTC_g(i)];
        sexeNTC(j,1)=[sexeNTC_g(i)];
        ICVNTC(j,1)=[ICVNTC_g(i)];
        j=j+1;
        k=k+1;
    end

end

Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

Y_ipsi = [NTC_ipsi;TC_ipsi];
Y_contro = [NTC_contro;TC_contro];
age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];
icv = [ICVNTC;ICVTC];

Age = term(age);
Sexe = term(sexe);
ICV = term(icv);

group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

Group = term(group);
    
M = 1 + Group + Age + Sexe + ICV;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y_ipsi, M );
contrast = Group.NTC - Group.TC;
slm = SurfStatT( slm, contrast );
pval = SurfStatP(slm);
disp('ipsi : ')
disp(pval)

slm = SurfStatLinMod( Y_contro, M );
contrast = Group.NTC - Group.TC;
slm = SurfStatT( slm, contrast );
pval = SurfStatP(slm);
disp('contro : ')
disp(pval)




