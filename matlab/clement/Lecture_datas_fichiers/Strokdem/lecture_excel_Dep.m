%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas STROKDEM/Depressifs'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valTD=[];
%disp(a)
for i=1:length(b)


    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b

    
valTD = [valTD;mat(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel
%donc val = volume des hp des sujets ayant des troubles de la mémoire

ageTD = a(:,1);
sexeTD = a(:,2);
ScoreDep = a(:,3);


end

%disp(valTD)