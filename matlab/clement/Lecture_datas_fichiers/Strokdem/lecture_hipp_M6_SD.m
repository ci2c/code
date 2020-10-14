%% All Strokdem 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/all_strokdem.xls'); 
valST=[];
valST2=[];

ageST=[];
sexeST=[];
ICVST=[];

for i=1:length(b) 
 
           s1='/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/';
           s4= '_M6/';
           s6='stats/aseg.stats';
           s=char(strcat(s1,b(i),s4,s6));

           fid=fopen(s,'rt');
      
           if fid ~= -1
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            z = strread(tline,'%s','delimiter',' ');
                if strcmp(z{1},'12')
                    matg = str2num(z{4});
               end
               if strcmp(z{1},'27') 
                    matd = str2num(z{4});
               end
            tline = fgetl(fid);
            format ('shortG');
            end
            
            ageST = [ageST;a(i,2)];
            sexeST = [sexeST;a(i,1)];
            valST2=[valST2;matd];
            
                 %ICV
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            clear z 
           while tline~=-1
            z = strread(tline,'%s','delimiter',', ');
              if length(z) > 3 && strcmp(z{3},'IntraCranialVol')
                   ic = str2num(z{7});
              end
            tline = fgetl(fid);
            format ('shortG');
           end
           ICVST=[ICVST;ic];
           fclose(fid);
    end           
end
 




%% Sujets Sains

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Sujets_Sains.xls'); 
valSS2=[];
valSS=[];

ageSS=[];
sexeSS=[];
ICVSS=[];

for i=1:length(b) 
     
           
           
           %Cx ent 
           s1='/NAS/tupac/protocoles/Strokdem/Sujets_Sains/';
           s4= '/FS53';
           s6='/stats/aseg.stats';
           s=char(strcat(s1,b(i),s4,s6));

           fid=fopen(s,'rt');
      
           if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            z = strread(tline,'%s','delimiter',' ');
                % On test si la première donnée est la ligne 12 (hippocampe gauche)
                if strcmp(z{1},'12')
                    %on récupère la valeur numérique à la 4e
                    % position sur la ligne 
                    matg = str2num(z{4});
                    %disp(tline)
               end
               if strcmp(z{1},'27') %Même chose pour l'hippocampe droit (ligne 27)
                    %on récupère la valeur numérique à la 4eme 
                    % position sur la ligne 
                    matd = str2num(z{4});
                    %disp(tline)
               end
            tline = fgetl(fid);
            format ('shortG'); %Si on met pas ce format, mat va afficher des valeurs en puissance de 10
            end
      fclose(fid);
      %mat_surf_ent(j,1) = [mats];
      ageSS = [ageSS;a(i,1)];  
      sexeSS = [sexeSS;a(i,2)];
      valSS2=[valSS2;matd];
                     
      
      %ICV
           s4= '/FS53';
           s6='/stats/aseg.stats';
           s=char(strcat(s1,b(i),s4,s6));

           fid=fopen(s,'rt');
      
           if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
           while tline~=-1
            z = strread(tline,'%s','delimiter',', ');
                if length(z) > 3 && strcmp(z{3},'EstimatedTotalIntraCranialVol')
                    ic = str2num(z{9});
                end
             tline = fgetl(fid);
             format ('shortG');
           end
            fclose(fid);
           end
      ICVSS=[ICVSS;ic];
           end
end

valST2=[valST2(1:107);valST2(109:110);valST2(112:115);valST2(117:126);valST2(128:end)];
ageST=[ageST(1:107);ageST(109:110);ageST(112:115);ageST(117:126);ageST(128:end)];
sexeST=[sexeST(1:107);sexeST(109:110);sexeST(112:115);sexeST(117:126);sexeST(128:end)];
ICVST=[ICVST(1:107);ICVST(109:110);ICVST(112:115);ICVST(117:126);ICVST(128:end)];

ICV=[ICVSS;ICVST];


for i=1:length(valSS2)
    
    valSS=[valSS;((valSS2(i)/ICVSS(i))*mean(ICV))];
end


for i=1:length(valST2)
    
    valST=[valST;((valST2(i)/ICVST(i))*mean(ICV))];
end


%% GLM

NST = size(ageSS,1);
ST  = size(ageST,1);

Y = [valSS(:,1);valST(:,1)];

age = [ageSS;ageST];
sexe = [sexeSS;sexeST];
icv= [ICVSS;ICVST];

Age = term(age);
Sexe = term(sexe);
ICV = term(icv);
group={};
for k = 1:NST
    group{end+1} = 'SS';
end
for k = 1:ST
    group{end+1} = 'ST';
end

Group = term(group);
    
%M = 1 + Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.SS - Group.ST;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)
