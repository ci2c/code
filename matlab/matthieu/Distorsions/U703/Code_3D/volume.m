function V = volume(name1,name3,coupeini,nbcoupes,taillel,taillec)

V = zeros(taillel,taillec,nbcoupes);

for cpt=coupeini:(coupeini+nbcoupes-1)
    
    name=strcat(name1,int2str(cpt),name3);
    Imainfo=dicominfo(name);
    Ima = dicomread(Imainfo);
    V(:,:,cpt-coupeini+1)=Ima;
  
end