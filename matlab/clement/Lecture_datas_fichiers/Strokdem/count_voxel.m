format('shortG')

%% NTC 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
voxNTC=[];

ageNTC =[]; 
sexeNTC =[];
ICVNTC =[];
MocaNTC=[];
% ATTENTION mettre le ICV au bon stade

s1='/NAS/tupac/protocoles/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpd/NTC/NTC_';
s2='M6_hpd.nii';

clear i
for i=1:length(b)
    
    file=char(strcat(s1,b(i),s2));
    
    if exist(file) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);

      voxNTC=[voxNTC;count];
      
      ageNTC=[ageNTC;a(i,1)];
      sexeNTC=[sexeNTC;a(i,2)];
      
      s5 = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/'; 
      s4= '_M6/stats/aseg.stats';
      s3 = s2(1:end-3);
      s=char(strcat(s5,b(i),s4));

      fid=fopen(s,'rt');
      
      if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            z = strread(tline,'%s','delimiter',', ');
                if length(z) > 3 && strcmp(z{3},'IntraCranialVol')
                    mats = str2num(z{7});
                end
             tline = fgetl(fid);
             format ('shortG');
            end
            fclose(fid);
      end
      
      ICVNTC=[ICVNTC;mats];
      %MocaNTC=[MocaNTC;a(i,4)];
    end

end


%% TC


[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
voxTC=[];

ageTC =[]; 
sexeTC =[];
ICVTC =[];
MocaTC=[];

s1='/NAS/tupac/protocoles/Strokdem/Shape_Analysis/M6/TCog_NTCog/hpd/TC/TC_';
s2='M6_hpd.nii';

for i=1:length(b)
    
    file=char(strcat(s1,b(i),s2));
    
    if exist(file) ~= 0 && a(i,4) ~= 0
      nii=load_nii(file);
      count=sum(nii.img(:)~=0);

      voxTC=[voxTC;count];
      
      ageTC=[ageTC;a(i,1)];
      sexeTC=[sexeTC;a(i,2)];
      
      s5 = '/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask/'; 
      s4= '_M6/stats/aseg.stats';
      s3 = s2(1:end-3);
      s=char(strcat(s5,b(i),s4));

      fid=fopen(s,'rt');
      
      if fid ~= -1
            j=j+1;
            fseek(fid,0,'bof');
            tline = fgetl(fid);
            
            while tline~=-1
            z = strread(tline,'%s','delimiter',', ');
                if length(z) > 3 && strcmp(z{3},'IntraCranialVol')
                    mats = str2num(z{7});
                end
             tline = fgetl(fid);
             format ('shortG');
            end
            fclose(fid);
      end
      ICVTC=[ICVTC;mats];
      %MocaTC=[MocaTC;a(i,4)];
    end

end

ICV=[ICVNTC;ICVTC];

valSS=[]
valNTC=[];
valTC=[];


for i=1:length(voxNTC)
    
    valNTC=[valNTC;((voxNTC(i)/ICVNTC(i))*mean(ICV))];
end



for i=1:length(voxTC)
    
    valTC=[valTC;((voxTC(i)/ICVTC(i))*mean(ICV))];

end


%% GLM

Nntc = size(ageSS,1);
Ntc  = size(ageNTC,1);

Y = [valSS(:,1);valNTC(:,1)];

age = [ageSS;ageNTC];
sexe = [sexeSS;sexeNTC];
icv= [ICVSS;ICVNTC];

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
    
%M = 1 + Group + Age + Sexe + ICV;
M = 1 + Group + Age + Sexe;
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)




