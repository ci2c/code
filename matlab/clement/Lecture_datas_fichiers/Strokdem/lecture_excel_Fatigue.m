%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas STROKDEM/Fatigue'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valTF=[];

for i=1:length(b)


    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b

    
valTF = [valTF;mat_surf_sf(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel
%donc val = volume des hp des sujets ayant des troubles de la mémoire

% disp(b(i))
% disp(mat_surf_sf(index,:))

scoreFat=a(:,1);


end
