liste=dir('/NAS/dumbo/matthieu/PreClinique/Florent/Volume_24h_controle/Vol');

s1='/NAS/dumbo/matthieu/PreClinique/Florent/Volume_24h_controle/Vol/';

vox=[];
name={};

j=1;
for i=1:length(liste)
    s2=liste(i).name;
    file=strcat(s1,s2);
    if exist(file) ~= 0 && strcmp(liste(i).name,'.') == 0 && strcmp(liste(i).name,'..') == 0
    
    nii=load_nii(file);
    count=sum(nii.img(:)~=0);

    disp(liste(i).name)
    disp(count)
    end
   
end