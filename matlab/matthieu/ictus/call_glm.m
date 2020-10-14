%clear all; close all;


Nntc = size(ageNTC,1);
Ntc  = size(ageTC,1);

Y = [valNTC(:,1);valTC(:,1)];

% X = zeros(Nntc+Ntc,4);
% X(1:Nntc,1)=ones(Nntc,1);
% X(Nntc+1:end,1)=zeros(Ntc,1);
% X(1:Nntc,2)=zeros(Nntc,1);
% X(Nntc+1:end,2)=ones(Ntc,1);
% X(:,3) = [ageNTC;ageTC];
% X(:,4) = [sexeNTC;sexeTC];


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
    
M = 1 + Group + Age + Sexe;
%M = 1 + Group + Age;
%M = 1 + Group + Sexe;

%figure; image(M);

slm = SurfStatLinMod( Y, M );

contrast = Group.NTC - Group.TC;

slm = SurfStatT( slm, contrast );

pval = SurfStatP(slm);
disp(pval)