function Cg = PreDetection_COR(name,sequence,threshold,maxDef)


%% Get informations from the DICOM image treated %%

Ima1info=dicominfo(name);
Ima1= double(dicomread(Ima1info)); 
taillel=double(Ima1info.Rows);
taillec=double(Ima1info.Columns);
dimpix=double(Ima1info.PixelSpacing);


%% Choice of the MRI sequence %%

if strcmp(sequence,'T1')
    
    %% View original image %%
%     figure (1)
%     imshow(Ima1,[],'InitialMagnification','fit');
    
    %% Create binary mask of the phantom %%
    mask = (Ima1 >= mean(Ima1(:)));
%     figure (2)
%     imshow(mask,[],'InitialMagnification','fit');
    
    sec=strel('disk',2,0);
    mask=imclose(mask,sec);
    figure (3)
    title('Mask of the Phantom','FontSize',12,'FontWeight','bold');hold on;
    imshow(mask,[],'InitialMagnification','fit');
    hold off;
    
    %% Put default value (0) to pixels in non-mask and NaN pixels %%
    Ima2=Ima1(:);
    idx=find(mask(:)==0);
    Ima2(idx)=0;
    Ima2(isnan(Ima2))=0;
    
    Ima2=reshape(Ima2,taillel,taillec);
%     figure (4)
%     imshow(Ima2,[],'InitialMagnification','fit');   
    
    %% Adaptative filter for white noise %%
    Ima3 = wiener2(Ima2,[2 2]);
%     figure (5)
%     imshow(Ima3,[],'InitialMagnification','fit');
    
    %% K-means clustering %%
    idx = find(Ima3(:)>0);
    Ima3=Ima3(:);
    vec=Ima3(idx);
    Ima3=reshape(Ima3,taillel,taillec);
    [cidx,ctrs]=kmeans(vec,2,'Replicate',5);
    
    %% Create image with k-means clustering values %%
    m1=zeros(taillel*taillec,1);
    m1(idx)=cidx;
    m1=reshape(m1,taillel,taillec);
    figure (6); 
    title('K-means clustered image','FontSize',12,'FontWeight','bold');hold on;
    imshow(m1,[],'InitialMagnification','fit');
    hold off;
    
    %% Keep image of the maximum clustering value %%
    [C, I]= max(ctrs);
    m2=(m1==I);
    figure (7); 
    subplot(121)
    title('Maximum clustering value image','FontSize',12,'FontWeight','bold'); hold on;
    imshow(m2,[],'InitialMagnification','fit');
    hold off;
    
    %% Label connected components in 2-D binary inverse image %%
    [L,num]=bwlabel(~m2);
    subplot(122)
    title('Binary image used to compute label connected components','FontSize',12,'FontWeight','bold'); hold on;
    imshow(~m2,[],'InitialMagnification','fit');
    hold off;
    
elseif strcmp(sequence,'T2')
    
    %% Adaptative filter for white noise %%
    Ima2 = wiener2(Ima1,[5 5]);
%     figure (1)
%     imshow(Ima2,[],'InitialMagnification','fit');

    %% Structural element definition and Bottom-hat filtering %%
    sebh = strel('disk',16,0); 
    Ima3 = imbothat(Ima2,sebh);
    figure (2)
    title('Bottom-hat image','FontSize',12,'FontWeight','bold'); hold on;
    imshow(Ima3,[],'InitialMagnification','fit');
    hold off;

    %% Binary image %%
    Ima4 = (Ima3 >= (mean(Ima3(:)))+threshold);
    figure (3)
    title('Binary image','FontSize',12,'FontWeight','bold');hold on;
    imshow(Ima4,'InitialMagnification','fit');
    hold off;
    
    %% Delete 8-connexity pixels on the image edge %%
    Ima5=imclearborder(Ima4);
%     figure (4)
%     imshow(Ima5,'InitialMagnification','fit');    
    
    %% Label connected components in 2-D binary image %%
    [L,num]=bwlabel(Ima5);
   
end  


%% Measure properties of image regions : Centroïds and Areas %%

reg=regionprops(L,'Centroid','Area','MajorAxisLength','MinorAxisLength');
Cg=zeros(length(reg),2);
Aire=zeros(length(reg),1);
for i=1:length(reg)           
    Cg(i,:)=[reg(i).Centroid(1) reg(i).Centroid(2)];
    Aire(i)=reg(i).Area;
end
% figure(8)
% imshow(Ima1,[],'InitialMagnification','fit');hold on;
% plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
% hold off


%% Surface area and compactedness criterions %%

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

    if (reg(i).MajorAxisLength/reg(i).MinorAxisLength)>2.1
        cc(i)=1;
    else
        cc(i)=0;
    end
end

csc=cs+cc;  
sc=find(csc>0);  

res=unique(sc);
if isempty(res)==0
    Cg(res,:)=[];
    Aire(res,:)=[];
end

% figure(9)
% imshow(Ima1,[],'InitialMagnification','fit');hold on;
% plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
% hold off


%% Surface area criterion for T1 image : delete the central disk label %%
if strcmp(sequence,'T1')
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
    end

    sc=find(cs>0);  

    res=unique(sc);
    if isempty(res)==0
        Cg(res,:)=[];
    end

%     figure(10)
%     imshow(Ima1,[],'InitialMagnification','fit');hold on;
%     plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
%     hold off
end


%% Distance criterion %%

cdis=zeros(size(Cg,1),1);
for i=1:size(Cg,1)
    D=[(Cg(:,1)-Cg(i,1))*dimpix(1) (Cg(:,2)-Cg(i,2))*dimpix(2)];
    D(i,:)=[];
    Dn=zeros(size(D,1),1);
    for j=1:size(D,1)
        Dn(j)=norm(D(j,:));
    end  
    if length(find(Dn<16-maxDef))>1
        cdis(i)=1;
    end
    if min(Dn)>(23+maxDef)
        cdis(i)=cdis(i)+1;
    end       
end

dc=find(cdis>0);
res=unique(dc);
if isempty(res)==0
    Cg(res,:)=[];
end


%% Line/Column criterion %%

lc=zeros(size(Cg,1),1);
for i=1:size(Cg,1)
    Dx=abs(Cg(:,1)-Cg(i,1))*dimpix(1);
    Dz=abs(Cg(:,2)-Cg(i,2))*dimpix(2);
    Dx(i)=[];
    Dz(i)=[];
    indX=Dx<maxDef;
    indZ=Dz<maxDef;

    if sum(indX)==0 || sum(indZ)==0
        lc(i)=1;
    end   
end

lc=find(lc>0);
res=unique(lc);
if isempty(res)==0
    Cg(res,:)=[];
end

figure(11)
imshow(Ima1,[],'InitialMagnification','fit');hold on;
title('Automated control points detected','FontSize',12,'FontWeight','bold')
plot(Cg(:,1),Cg(:,2),'.g','MarkerSize',12);
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize);
hold off