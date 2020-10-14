%% Read

M = textread('groupe_ville_nonrange.mat','','headerlines',5);

M = M(:,1:9);


PL  = M(:,1)~=0;  
PP  = M(:,2)~=0;
SL  = M(:,3)~=0;
TP  = M(:,4)~=0;
TPL  = M(:,5)~=0;
TSL = M(:,6)~=0;
SP = M(:,7)~=0;

age = M(:,8);
id  = M(:,9);

APL = (age.*PL) - mean(age(PL)).*PL;
APP = (age.*PP) - mean(age(PP)).*PP;
ASL = (age.*SL) - mean(age(SL)).*SL;
ASP = (age.*SP) - mean(age(SP)).*SP;
ATP = (age.*TP) - mean(age(TP)).*TP;
ATPL = (age.*TPL) - mean(age(TPL)).*TPL;
ATSL = (age.*TSL) - mean(age(TSL)).*TSL;

ID = id - mean(id);

%% Re-group

NewMat = [ PL+PP SL+SP TP+TPL+TSL APL APP ASL ASP ATP ATPL ATSL ID ];


%% Create design and contrast

fid = fopen('design.mat','Wt');
fprintf(fid,'/NumWaves\t%d\n/NumPoints\t%d\n/PPheights\t',size(NewMat,2),size(NewMat,1));
for i = 1:size(NewMat,2)
    fprintf(fid,'%d\t',1);
end
fprintf(fid,'\n\n/Matrix\n');
for i = 1:size(NewMat,1)
    for j = 1:size(NewMat,2)
        fprintf(fid,'%f\t',NewMat(i,j));
    end
    fprintf(fid,'\n');
end
fclose(fid);


fid = fopen('design.con','Wt');


% /ContrastName1	TvsPS
% /ContrastName2	TvsS
% /ContrastName3	PSvsS
% /ContrastName4	SvsPS
% /ContrastName5	PSvsT
% /ContrastName6	SvsT
% /NumWaves	9
% /NumContrasts	6
% /PPheights		1.004285e+00	1.080542e+00	8.178624e-01	8.178624e-01	1.004285e+00	1.080542e+00
% /RequiredEffect		3.027	2.966	1.410	1.410	3.027	2.966
% 
% /Matrix

fprintf(fid,'/ContrastName1\t TvsS\n');
fprintf(fid,'/ContrastName2\t SvsT\n');
fprintf(fid,'/ContrastName3\t TvsPS\n');
fprintf(fid,'/ContrastName4\t PSvsT\n');
fprintf(fid,'/ContrastName5\t PSvsS\n');
fprintf(fid,'/ContrastName6\t SvsPS\n');
fprintf(fid,'/NumWaves\t%d',size(NewMat,2));
fprintf(fid,'/NumContrasts\t6\nPPheights');
for i = 1:size(NewMat,2)
    fprintf(fid,'%d\t',1);
end
fprintf(fid,'\nRequiredEffect');
for i = 1:size(NewMat,2)
    fprintf(fid,'%d\t',1);
end
fprintf(fid,'\n\n/Matrix\n');

fprintf(fid,'0 -1 1 0 0 0 0 0 0 0 0\n');
fprintf(fid,'0 1 -1 0 0 0 0 0 0 0 0\n');
fprintf(fid,'-1 0 1 0 0 0 0 0 0 0 0\n');
fprintf(fid,'1 0 -1 0 0 0 0 0 0 0 0\n');
fprintf(fid,'1 -1 0 0 0 0 0 0 0 0 0\n');
fprintf(fid,'-1 1 0 0 0 0 0 0 0 0 0\n');




















