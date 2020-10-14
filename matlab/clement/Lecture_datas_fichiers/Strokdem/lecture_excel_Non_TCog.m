

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Non_Trouble_Cog_hip.xls'); 
valNTC=[];

ageNTC=[];
sexeNTC=[];
ICVNTC=[];


ageNTC =a(:,1); 
sexeNTC =a(:,2);
ICVNTC =a(:,3);


for i=1:length(b)
index=find(ismember(matn,b(i))); 
    valNTC = [valNTC;mat_surf_ent(index,:)];

%     if index ~= 0
%        
%        ageNTC = [ageNTC;a(i,1)];  
%        sexeNTC = [sexeNTC;a(i,2)];
%        ICVNTC = [ICVNTC;a(i,3)];
%     end



end



