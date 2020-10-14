% va dans le dossier où sont les datas des sujets, extrait le nom de chaque
% et ensuite fait une concatenation pour obtenir l'adresse finale où est
% située le fichier pour les stats. Permettra donc d'aller automatiquement
% chercher le fichier dans chaque dossier.

clear all

liste=dir('/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/'); %met dans 'liste' les repertoires du dossier

s1 = '/NAS/dumbo/protocoles/CogPhenoPark/FS5.3/'; 
s3= '/stats/';

i=1:size(liste,1); %Entre une matrice faisant la taille équivalente au nombre de repertoire dans le dossier
for i=1:size(liste,1)
	%disp(liste(i).name)
    
    s2 = liste(i).name;
    s=strcat(s1,s2,s3)
end




