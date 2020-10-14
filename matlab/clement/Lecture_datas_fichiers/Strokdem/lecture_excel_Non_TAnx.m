%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas STROKDEM/Non_Trouble_Anx'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valNTA=[];
for i=1:length(b)


    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b

 
valNTA = [valNTA;mat(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel
%donc val = volume des hp des sujets ayant des troubles de la mémoire

ageNTA = a(:,1);
sexeNTA = a(:,2);

end

%disp(valNTA)