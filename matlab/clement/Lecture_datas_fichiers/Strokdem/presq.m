%% TC sans presequelle(s)

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/TC');
voxTCn=[];

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/TC_nopreseq.xls');
ageTCn =a(:,1); 
sexeTCn =a(:,2);
ICVTCn =a(:,3);

s1='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/TC/TC_';
s2='72H_hpg.nii';

for i=1:length(b)
    file=char(strcat(s1,b(i),s2));

    nii=load_nii(file);
    count=sum(nii.img(:)~=0);
    voxTCn=[voxTCn;count];  

end
    
%% TC avec presquelle(s)

liste=dir('/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/TC');
voxTCp=[];

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/TC_preseq.xls');
ageTCp =a(:,1); 
sexeTCp =a(:,2);
ICVTCp =a(:,3);

s1='/home/fatmike/Protocoles_3T/Strokdem/Shape_Analysis/H72/TCog_NTCog/hpg/TC/TC_';
s2='72H_hpg.nii';

for i=1:length(b)
    file=char(strcat(s1,b(i),s2));

    nii=load_nii(file);
    count=sum(nii.img(:)~=0);
    voxTCp=[voxTCp;count];  

end

Nntc = size(ageTCn,1);
Ntc  = size(ageTCp,1);

Y = [voxTCn(:,1);voxTCp(:,1)];

age = [ageTCn;ageTCp];
sexe = [sexeTCn;sexeTCp];
icv= [ICVTCn;ICVTCp];

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
    
M = 1+ Group + Age + Sexe + ICV;
%M = 1 + Group + Age + Sexe;
%M = 1 + Group + Sexe;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp('Moyenne TC sans presq:')
disp(mean(voxTCn))
disp('Moyenne TC avec presq:')
disp(mean(voxTCp))

disp('p value')
disp(pval)
