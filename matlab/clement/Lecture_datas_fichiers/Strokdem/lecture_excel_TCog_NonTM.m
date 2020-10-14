
%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/Trouble_Cog_NonTM'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valTCNTM=[];
ageNTC=a(:,1);
sexeNTC=a(:,2);
ICVNTC=a(:,3);

%disp(a)
for i=1:length(b)


    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b

valTCNTM = [valTCNTM;mat_thick_ent(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel
% ageTCNTM= [a(:,1)];
% sexeTCNTM= [a(:,2)];
% 
% ageNTC= ageTCNTM;
% sexeNTC= sexeTCNTM;
% valNTC= valTCNTM;

%donc val = volume des hp des sujets ayant des troubles de la mémoire

% disp(b(i))
% disp(mat(index,:))

end


%disp(valTC)