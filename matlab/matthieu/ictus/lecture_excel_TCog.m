
%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas STROKDEM/Trouble_Cog'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valTC=[];

%disp(a)
for i=1:length(b) 
    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b
    valTC = [valTC;mat_surf_ent(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel
      
%         if index ~= 0
%            ageTC = [ageTC;a(i,1)];  
%            sexeTC = [sexeTC;a(i,2)];
%         end
end
