clear all, close all 

path='/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/Results/left/TC';
D = dir(path) ; % récupère un tableau de structure
D = D(~cell2mat({D(:).isdir})) ; % filter pour ne garder que les noms de fichiers
Liste = {D(:).name} ; % transformer en un tableau de cellules texte
j=0;
Results=[];

disp(path)

for z = 1:length(Liste)
    
disp(Liste(z))

%% Troubles Cog
path='/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/Results/left/TC';
D = dir(path) ; % récupère un tableau de structure
D = D(~cell2mat({D(:).isdir})) ; % filter pour ne garder que les noms de fichiers
Liste = {D(:).name} ; % transformer en un tableau de cellules texte
j=0;

Dep_meanTC=[];
FoTC=[];

s = char(strcat(path,'/',Liste(z))); %Concatène le chemin et le transforme en char pour être lu par fopen
fid=fopen(s,'rt'); %lecture fichier
[A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/TMemoire.xls');   %Pour après récupérer les ages+sexe
    
    if fid ~= -1 %Si il arrive à aller chercher le fichier
       
        fseek(fid,0,'bof');
        tline = fgetl(fid);
            while tline~=-1
            j=j+1;
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ');  
            % Stocke dans Dep_meanTC la valeur de profondeur du sillon +
            % covar 
                for i=1:length(B)
                    if strcmp(B(i),a(1)) == 1
                    Dep_meanTC=[Dep_meanTC;str2num(a{25}),A(i,2),A(i,1)];
                    end
                end
            %Stocke dans FoTC la valeur de Fold opening du sillon + covar
               for i=1:length(B)
                    if strcmp(B(i),a(1)) == 1
                    FoTC=[FoTC;str2num(a{33}),A(i,2),A(i,1)];
                    end
               end
            tline = fgetl(fid);
            end
      fclose(fid);
     
    end
clear path D j a abr A B C  
%% Non Troubles Cog
path='/home/fatmike/Protocoles_3T/Strokdem/BrainVisa/Results/left/TC';
D = dir(path) ; % récupère un tableau de structure
D = D(~cell2mat({D(:).isdir})) ; % filter pour ne garder que les noms de fichiers
Liste = {D(:).name} ; % transformer en un tableau de cellules texte
j=0;
FoNTC=[];
Dep_meanNTC=[];


s = char(strcat(path,'/',Liste(z))); %Concatène le chemin et le transforme en char pour être lu par fopen
fid=fopen(s,'rt'); %lecture fichier
[A,B,C] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog_NonTM.xls');


if fid ~= -1 %Si il arrive à aller chercher le fichier
       
        fseek(fid,0,'bof');
        tline = fgetl(fid);
                    while tline~=-1
            j=j+1;
            % On récupère toutes les données de la ligne séparées
            a = strread(tline,'%s','delimiter',' ');  
            % Stocke dans Dep_meanTC la valeur de profondeur du sillon +
            % covar 
                for i=1:length(B)
                    if strcmp(B(i),a(1)) == 1
                    Dep_meanNTC=[Dep_meanNTC;str2num(a{25}),A(i,2),A(i,1)];
                    end
                end
            %Stocke dans FoTC la valeur de Fold opening du sillon + covar
               for i=1:length(B)
                    if strcmp(B(i),a(1)) == 1
                    FoNTC=[FoNTC;str2num(a{33}),A(i,2),A(i,1)];
                    end
               end
            tline = fgetl(fid);
            end
      fclose(fid);
end

% Elagage des valeurs == 0 et aberrantes
        %On retire les valeurs == 0
        
        %TC
        abr = find(FoTC(:,1)==0);
        for i=1:size(abr)
        FoTC=[FoTC(1:(abr(1)-1),:);FoTC((abr(1)+1):end,:)];
        abr = find(FoTC(:,1)==0);
        end
clear abr
        abr = find(Dep_meanTC(:,1)==0);
        for i=1:size(abr)
        Dep_meanTC=[Dep_meanTC(1:(abr(1)-1),:);Dep_meanTC((abr(1)+1):end,:)];
        abr = find(Dep_meanTC(:,1)==0);
        end
clear abr
        %NTC
        abr = find(FoNTC(:,1)==0);
        
        for i=1:size(abr)
        FoNTC=[FoNTC(1:(abr(1)-1),:);FoNTC((abr(1)+1):end,:)];
        abr = find(FoNTC(:,1)==0);
        end
clear abr
    
        abr = find(Dep_meanNTC(:,1)==0);
        
        for i=1:size(abr)
        Dep_meanNTC=[Dep_meanNTC(1:(abr(1)-1),:);Dep_meanNTC((abr(1)+1):end,:)];
        abr = find(Dep_meanNTC(:,1)==0);
        end
clear abr

        %On retire les valeurs aberrantes
        %TC
        abr = [find(FoTC(:,1) > (mean(FoTC(:,1))+3*(std(FoTC(:,1)))));find(FoTC(:,1) < (mean(FoTC(:,1))-3*(std(FoTC(:,1)))))];
        
        for i=1:size(abr)
        FoTC=[FoTC(1:(abr(1)-1),:);FoTC((abr(1)+1):end,:)];
        abr = [find(FoTC(:,1) > (mean(FoTC(:,1))+3*(std(FoTC(:,1)))));find(FoTC(:,1) < (mean(FoTC(:,1))-3*(std(FoTC(:,1)))))];
        end
clear abr 

        abr = [find(Dep_meanTC(:,1) > (mean(Dep_meanTC(:,1))+3*(std(Dep_meanTC(:,1)))));find(Dep_meanTC(:,1) < (mean(Dep_meanTC(:,1))-3*(std(Dep_meanTC(:,1)))))];

        for i=1:size(abr)
        Dep_meanNTC=[Dep_meanTC(1:(abr(1)-1),:);Dep_meanTC((abr(1)+1):end,:)];
        abr = [find(Dep_meanTC(:,1) > (mean(Dep_meanTC(:,1))+3*(std(Dep_meanTC(:,1)))));find(Dep_meanTC(:,1) < (mean(Dep_meanTC(:,1))-3*(std(Dep_meanTC(:,1)))))];
        end
        
        
        %NTC
        
        abr = [find(FoNTC(:,1) > (mean(FoNTC(:,1))+3*(std(FoNTC(:,1)))));find(FoNTC(:,1) < (mean(FoNTC(:,1))-3*(std(FoNTC(:,1)))))];
        
        for i=1:size(abr)
        FoNTC=[FoNTC(1:(abr(1)-1),:);FoNTC((abr(1)+1):end,:)];
        abr = [find(FoNTC(:,1) > (mean(FoNTC(:,1))+3*(std(FoNTC(:,1)))));find(FoNTC(:,1) < (mean(FoNTC(:,1))-3*(std(FoNTC(:,1)))))];
        end
clear abr 

        abr = [find(Dep_meanNTC(:,1) > (mean(Dep_meanNTC(:,1))+3*(std(Dep_meanNTC(:,1)))));find(Dep_meanNTC(:,1) < (mean(Dep_meanNTC(:,1))-3*(std(Dep_meanNTC(:,1)))))];

        for i=1:size(abr)
        Dep_meanNTC=[Dep_meanNTC(1:(abr(1)-1),:);Dep_meanNTC((abr(1)+1):end,:)];
        abr = [find(Dep_meanNTC(:,1) > (mean(Dep_meanNTC(:,1))+3*(std(Dep_meanNTC(:,1)))));find(Dep_meanNTC(:,1) < (mean(Dep_meanNTC(:,1))-3*(std(Dep_meanNTC(:,1)))))];
        end
clear abr 


%% Stats call_GLM

format('shortG');
%
ageNTC = FoNTC(:,3);
sexeNTC = FoNTC(:,2);
ageTC = FoTC(:,3);
sexeTC = FoTC(:,2);

Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];
Age = term(age);
Sexe = term(sexe);
group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

Group = term(group);
    
M = 1+ Group + Age + Sexe;
%M = 1 + Group + Age;
%M = 1 + Group + Sexe;

%figure; image(M);

Y = [FoNTC(:,1);FoTC(:,1)];

slm = SurfStatLinMod( Y, M );

contrast = Group.TC - Group.NTC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

FoPval = pval.P;


% Dep_mean

ageNTC = Dep_meanNTC(:,3);
sexeNTC = Dep_meanNTC(:,2);
ageTC = Dep_meanTC(:,3);
sexeTC = Dep_meanTC(:,2);

Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];
Age = term(age);
Sexe = term(sexe);
group={};
for k = 1:Nntc
    group{end+1} = 'NTC';
end
for k = 1:Ntc
    group{end+1} = 'TC';
end

Group = term(group);
    
M = 1+ Group + Age + Sexe;
%M = 1 + Group + Age;
%M = 1 + Group + Sexe;

%figure; image(M);


Y = [Dep_meanNTC(:,1);Dep_meanTC(:,1)];


slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

Dep_meanPval = pval.P;


%% Extraction des résultats dans une matrice

Results = [Results; FoPval, mean(FoTC(:,1)), std(FoTC(:,1)), mean(FoNTC(:,1)), std(FoNTC(:,1)), Dep_meanPval, mean(Dep_meanTC(:,1)), std(Dep_meanTC(:,1)), mean(Dep_meanNTC(:,1)), std(Dep_meanNTC(:,1))];


%% Fin du Script
fclose('all');
end 
disp(Results)
