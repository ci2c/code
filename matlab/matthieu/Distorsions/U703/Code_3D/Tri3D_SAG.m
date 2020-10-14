% Récupération des centres de gravités dans les coupes SAG

clear all;
close all;

CGS=[];
        name1='Corrigées_fit\SAG.';
        name3='.dcm';

for cp=14:6:56
    
    name=strcat(name1,int2str(cp),name3);
    
    if exist(name)~=0
        
        Imainfo = dicominfo(name);
        x0=Imainfo.ImagePositionPatient(1);
        y0=Imainfo.ImagePositionPatient(2);
        z0=Imainfo.ImagePositionPatient(3);
        op=Imainfo.ImageOrientationPatient;
        dimpix=Imainfo.PixelSpacing;
        
        [Cg,xy] = detection_SAG(name,cp);
        pause;
        
        %% Calcul des coordonnées 3D des points d'intersection
    
        CG=zeros(size(Cg,1),3);    
        for i=1:size(Cg,1)
    
            CG(i,1)=x0+(Cg(i,1)-1)*dimpix(1)*op(1)+(Cg(i,2)-1)*dimpix(2)*op(4);
            CG(i,2)=y0+(Cg(i,1)-1)*dimpix(1)*op(2)+(Cg(i,2)-1)*dimpix(2)*op(5);
            CG(i,3)=z0+(Cg(i,1)-1)*dimpix(1)*op(3)+(Cg(i,2)-1)*dimpix(2)*op(6);
        
        end
        
        CGS = [CGS;CG];
        
    end
    
    close all;
    
end

figure (1)
plot3(CGS(:,1),CGS(:,2),CGS(:,3),'.');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');

ind = find (CGS(:,3)<90 & CGS(:,3)>-90);
CGSb = CGS(ind,:);

figure (2)
plot3(CGSb(:,1),CGSb(:,2),CGSb(:,3),'.');
xlabel('axe x');
ylabel('axe y');
zlabel('axe z');