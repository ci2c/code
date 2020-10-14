
%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_hip.xls'); 
valTC=[];


ageTC =a(:,1); 
sexeTC =a(:,2);
ICVTC =a(:,3);
seq=a(:,4);

% ageTC=[];
% sexeTC=[];
% ICVTC=[];


for i=1:length(b) 
    index=find(ismember(matn,b(i))); 
     valTC = [valTC;mat_thick_ent(index,:)];
    

%         if index ~= 0
%            
%            ageTC = [ageTC;a(i,1)];  
%            sexeTC = [sexeTC;a(i,2)];
%            ICVTC = [ICVTC;a(i,3)];
%         end
%          
end




 