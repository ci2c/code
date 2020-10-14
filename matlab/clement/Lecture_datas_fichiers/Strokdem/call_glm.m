Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

Y = [valNTC(:,1);valTC(:,1)];

age = [ageNTC;ageTC];
sexe = [sexeNTC;sexeTC];
icv= [ICVNTC;ICVTC];

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
%M = 1 + Group;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)