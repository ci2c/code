%clear all; close all;


Nntc = size(ageNTD,1);
Ntc  = size(ageTD,1);

Y = [valNTD(:,2);valTD(:,2)];

% X = zeros(Nntc+Ntc,4);
% X(1:Nntc,1)=ones(Nntc,1);
% X(Nntc+1:end,1)=zeros(Ntc,1);
% X(1:Nntc,2)=zeros(Nntc,1);
% X(Nntc+1:end,2)=ones(Ntc,1);
% X(:,3) = [ageNTD;ageTD];
% X(:,4) = [sexeNTD;sexeTD];


age = [ageNTD;ageTD];
sexe = [sexeNTD;sexeTD];
Age = term(age);
Sexe = term(sexe);
group={};
for k = 1:Nntc
    group{end+1} = 'NTD';
end
for k = 1:Ntc
    group{end+1} = 'TD';
end

Group = term(group);
    
M = 1 + Group + Age + Sexe;
%M = 1 + Group + Age;
%M = 1 + Group + Sexe;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.TD - Group.NTD;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);

disp(pval)