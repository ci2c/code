function [t1map, b0map] = T1_IR_map()

clear all;

% format long;

[fid,chemin]=uigetfile('','MultiSelect', 'on');
% [fid,chemin]=uigetfile('');


if ~ischar(fid)
    nbfile=size(fid, 2);
else
    nbfile=1;
end
Volume = [];
TI=[];
for n = 1:nbfile,
    if nbfile > 1,
        file=strcat(chemin, char(fid(n)));   
    else
        file=strcat(chemin, char(fid));
    end
    
        eval(['header' num2str(n) '=dicominfo(file)']);
        h = 1:nbfile;
            slope=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.Private_2005_100e']);
%             eval(['TI' num2str(n) '=header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.InversionTime']);
TI(n)=eval(['header' num2str(n) '.PerFrameFunctionalGroupsSequence.Item_1.Private_2005_140f.Item_1.InversionTime']);
TI=TI';

%             file=strcat(chemin, char(fid(n)));
            dicomfile=dicomread(file);
            dicomfile=double(dicomfile);
            dicomfile=dicomfile./slope;
            dicomfile=squeeze(dicomfile); 
            Volume = cat(4, Volume, dicomfile);   
            Volume=double(Volume);

end

tailleVol=size(Volume);
X=TI./1000;

% Initialize the coefficients of the function.
X0=[5 0.1];

tic
 for i = 1:tailleVol(1),
     for j = 1:tailleVol(2),
%      for   k = 1:NBcoupe,
        Y=(squeeze(Volume(i,j,1,:)));
%         Y=Y';
        Y(1:2)=-Y(1:2);
  


% Set an options file for LSQNONLIN to use the
% medium-scale algorithm
options = optimset('MaxFunEvals', 10000);


% Calculate the new coefficients using LSQNONLIN.
x=lsqnonlin(@fonction_exp,X0,[],[],options,X,Y);
t1map(i,j)=x(2);
b0map(i,j)=x(1);
    end
end
toc
