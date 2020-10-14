%Chop ele fichier xls avec les ID des sujets 

[a,b,c] = xlsread('/home/clement/Documents/Datas_Strokdem/TMemoire'); %Fichier xls où j'ai mis l'ID des sujets avec Trouble Mem
valTM=[];
ageTC=a(:,1);;
sexeTC=a(:,2);
ICVTC=a(:,3);
%disp(a)
for i=1:length(b)

    if find(ismember(matn,b(i))) ~= 0
    
    index=find(ismember(matn,b(i))); %Défini l'index dans lequel est situé l'ID dans b

    valTM = [valTM;mat_thick_ent(index,:)]; %Matrice 1x2 où sont les datas des sujets dont il est question dans l'excel

    else

    end
end
% ageTM= [a(:,1)];
% sexeTM= [a(:,2)];
% 
% ageTC=ageTM;
% sexeTC=sexeTM;
% valTC=valTM;

%disp(valTC)