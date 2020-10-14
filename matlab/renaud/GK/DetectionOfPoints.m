clear all; close all;

[hdr,vol]=niak_read_vol('/home/renaud/NAS/matthieu/Distorsions/Fantôme_Elekta/PerOpératoire/Test2/SE000000/20140711_162141001GammaKnifeAnts002a1001.nii');
[hm,mask] = niak_read_vol('/home/renaud/NAS/matthieu/Distorsions/Fantôme_Elekta/PerOpératoire/Test2/SE000000/t1_mask.nii');

dim = size(vol);
vol=vol(:);
idx=find(mask(:)==0);
vol(idx)=0;
vol(isnan(vol))=0;

idx = find(vol>0);

threshold=200;

vec = vol(idx);
figure; hist(vec);

vol=reshape(vol,dim(1),dim(2),dim(3));
% 
% hdr.file_name = '/home/renaud/NAS/matthieu/Distorsions/Fantôme_Elekta/PerOpératoire/Test2/SE000000/t1m.nii';
% niak_write_vol(hdr,vol);

Ima1 = vol(:,:,88);


Ima2 = wiener2(Ima1,[5 5]);
figure (2)
subplot(121)
imshow(Ima2,[],'InitialMagnification','fit');

% %% Définition de l'élément structurant et opération bottom hat
% 
% sebh = strel('disk',8,0);  %ES forme disque de rayon lissé
% Ima3 = imbothat(Ima2,sebh);
% subplot(122)
% imshow(Ima3,[],'InitialMagnification','fit');
% 
% Ima5 = (Ima3 >= (mean(Ima3(:))+threshold));
% figure (3)
% subplot(121)
% imshow(Ima5,'InitialMagnification','fit');
% 
% [L,num]=bwlabel(Ima5);
% reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
% Cg=zeros(length(reg),2);
% Aire=zeros(length(reg),1);
% for i=1:length(reg)           
%     Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
%     Aire(i)=reg(i).Area;
% end
% %     figure(21)
% subplot(122)
% imshow(Ima1,[],'InitialMagnification','fit');hold on;
% plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
% hold off

idx = find(Ima1(:)>0);
Ima2=Ima2(:);
vec=Ima2(idx);
[cidx,ctrs]=kmeans(vec,2,'Replicate',5);
m1=zeros(dim(1)*dim(2),1);
m1(idx)=cidx;

m1=reshape(m1,dim(1),dim(2));
figure; imagesc(m1); 

m1=double(m1==2);
figure; imagesc(m1); 

% se = strel('line',11,90);
% erodedBW = imerode(m1,se);
% figure; imagesc(erodedBW); 

[L,num]=bwlabel(~m1);
reg=regionprops(L,'Centroid','EquivDiameter','Area','MajorAxisLength','MinorAxisLength');
Cg=zeros(length(reg),2);
Aire=zeros(length(reg),1);
for i=1:length(reg)           
    Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
    Aire(i)=reg(i).Area;
end
%     figure(21)
figure;
imshow(Ima1,[],'InitialMagnification','fit');hold on;
plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
hold off

% Critère de distance

cdis=zeros(size(Cg,1),1);
for i=1:size(Cg,1)
    D=[Cg(:,1)-Cg(i,1) Cg(:,2)-Cg(i,2)];
    D(i,:)=[];
    Dn=zeros(size(D,1),1);
    for j=1:size(D,1)
        Dn(j)=norm(D(j,:));
    end  
    if length(find(Dn<15))>1
        cdis(i)=1;
    end
end
dc=find(cdis>0);

% Critère de surface et compacité

moy=mean(Aire);
et=std(Aire);
cs=zeros(size(Cg,1),1);
cc=zeros(size(Cg,1),1);
for i=1:size(Cg,1)
    if (Aire(i)>moy+2*et) || (Aire(i)<moy-2*et)
        cs(i)=1;
    else
        cs(i)=0;
    end
%             if (Aire(i) == max(Aire(:)))
%                 cs(i)=1;
%             else
%                 cs(i)=0;
%             end
%             cs=zeros(size(Cg,1),1);
    if (reg(i).MajorAxisLength/reg(i).MinorAxisLength)>2.1
        cc(i)=1;
    else
        cc(i)=0;
    end
end

csc=cs+cc;  
%         csc=[];
sc=find(csc>0);  
%         dc=[];
res=[dc;sc];
res=unique(res);
if isempty(res)==0
    Cg(res,:)=[];
end

but=1;
n=0;
xy=[];
figure (4) 
clf
imshow(Ima1,[],'InitialMagnification','fit');hold on;
plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
while but == 1
    [xi,yi,but] = ginput(1);
    if but==1
    plot(xi,yi,'.r','MarkerSize',12)
    n = n+1;
    xy(n,:) = [xi yi];
    end
end
hold off
Cg=[Cg;xy];

% remove point
but=1;
n=0;
xy=[];
figure (4) 
clf
imshow(Ima1,[],'InitialMagnification','fit');hold on;
plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
while but == 1
    [xi,yi,but] = ginput(1);
    if but==1
    plot(xi,yi,'.r','MarkerSize',12)
    n = n+1;
    xy(n,:) = [xi yi];
    end
end
hold off
for k = 1:n
    tmp(:,1) = Cg(:,1)-xy(k,1);
    tmp(:,2) = Cg(:,2)-xy(k,2);
    [Y,I] = min(sum(abs(tmp),2));
    Cg = [Cg(1:I-1,:);Cg(I+1:end,:)];
end

figure (4);
imshow(Ima1,[],'InitialMagnification','fit');hold on;
plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
hold off

%%

Cgt = Tri_AXIAL(Cg);

name3='MR000055';
name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Elekta/PerOpératoire/Test2/SE000000/';
name=strcat(name1,name3);

[R,q,dep,Pf,error,CG,Cth] = Recalage_AXIAL(name,Cgt);

[dX,dY,dR,Xv,Yv,Ima1info,z0]= Deformations_AXIAL(name,Pf,CG,Cgt);
