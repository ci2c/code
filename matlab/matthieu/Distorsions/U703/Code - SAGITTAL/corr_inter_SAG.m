function Imac = corr_inter_SAG(choix,name1,cp,repertoire)

    %% Chargement des informations DICOM de la coupe axiale %%

name3='.dcm';
% cp=33;
name=strcat(name1,int2str(cp),name3);
Imainfo=dicominfo(name);
Ima= dicomread(Imainfo);
x0=Imainfo.ImagePositionPatient(1);
y0=Imainfo.ImagePositionPatient(2);
z0=Imainfo.ImagePositionPatient(3);
op=Imainfo.ImageOrientationPatient;
dimpix=Imainfo.PixelSpacing;
taillec=Imainfo.Columns;
taillel=Imainfo.Rows;

    %% Correction à partir de l'atlas de déformations 2D sagittal obtenu à
    %% partir des centres de gravités détectés automatiquement + ajout
    %% manuel %%
    
if choix == 'm'
    
    % Chargement de l'atlas de déformation sagittal
    
    load defintm;
    
    % Tri de l'atlas par x croissant et localisation de la coupe que l'on
    % souhaite corriger entre deux cartes de déformations
    
    for i=1:length(defintm)
        x(i)=defintm(i,1).Position_x;
    end
    [z,ind]=sort(z);
    defintm=defintm(ind);
    
    if (x0<min(x)) || (x0>max(x))
        error('interpolation entre deux plans de coupes impossible : en dehors des limites');
    else
        d=x-x0;
        for i=1:length(d)
            dn(i)=norm(d(i));
        end
        [mind,k]=min(dn);
        
        if x0>x(k)
            
            xf=[x(k);x(k+1)];
            
            % Définition de la grille régulière
            
            ygrille = defintm(k,1).Grille_reguliere_1;
            zgrille = defintm(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en y et z pour les deux
            % coupes concernées
            
            dy1=defintm(k,1).Valeurs_deformation_1;
            dz1=defintm(k,1).Valeurs_deformation_2;
            dy2=defintm(k+1,1).Valeurs_deformation_1;
            dz2=defintm(k+1,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))
            
                % Reformatage des matrices pour l'interpolation
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                dz1r = reshape(dz1,length(dz1(:)),1);
                dz2r = reshape(dz2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                % interpolation de la déformation dy en x0
            
                dyi=interp1(xf,dy,x0,'spline');
                dyf = reshape(dyi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dzi=interp1(xf,dz,x0,'spline');
                dzf = reshape(dzi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zgrille+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dyf;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
  
            else
   
             % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);
                    end
                end
                
                dyn1=interp2(ygrille,zgrille,dy1,yn,zn,'spline');
                dyn2=interp2(ygrille,zgrille,dy2,yn,zn,'spline');
                dzn1=interp2(ygrille,zgrille,dz1,yn,zn,'spline');
                dzn2=interp2(ygrille,zgrille,dz2,yn,zn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dz1r = reshape(dzn1,length(dz1(:)),1);
                dz2r = reshape(dzn2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(xf,dz,z0,'spline');
                dzf = reshape(dzi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(xf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zn+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
            
            end
            
        elseif x0<x(k)
            
            xf=[x(k-1);x(k)];
            
            % Définition de la grille régulière
            
            ygrille = defintm(k-1,1).Grille_reguliere_1;
            zgrille = defintm(k-1,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dy1=defintm(k-1,1).Valeurs_deformation_1;
            dz1=defintm(k-1,1).Valeurs_deformation_2;
            dy2=defintm(k,1).Valeurs_deformation_1;
            dz2=defintm(k,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))
            
                % Reformatage des matrices pour l'interpolation
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                dz1r = reshape(dz1,length(dz1(:)),1);
                dz2r = reshape(dz2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                % interpolation de la déformation dy en x0
            
                dyi=interp1(xf,dy,x0,'spline');
                dyf = reshape(dyi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zgrille+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dyf;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
                
            else
   
             % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);
                    end
                end
                
                dyn1=interp2(ygrille,zgrille,dy1,yn,zn,'spline');
                dyn2=interp2(ygrille,zgrille,dy2,yn,zn,'spline');
                dzn1=interp2(ygrille,zgrille,dz1,yn,zn,'spline');
                dzn2=interp2(ygrille,zgrille,dz2,yn,zn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dz1r = reshape(dzn1,length(dz1(:)),1);
                dz2r = reshape(dzn2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(xf,dz,z0,'spline');
                dzf = reshape(dzi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(xf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zn+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
        else
            
            xf=x(k);
            
            % Définition de la grille régulière
            
            ygrille = defintm(k,1).Grille_reguliere_1;
            zgrille = defintm(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dy=defintm(k,1).Valeurs_deformation_1;
            dz=defintm(k,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))

                % Obtention des coordonnées déformées et correction
            
                ynd=ygrille+dy;                                % Obtention des coord2D correspondantes dans image déformée
                znd=zgrille+dz;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
            
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            else

                % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);        % Récupération coord2D coupe coronale pour chaque pixel   
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);
                    end
                end
                dzn=interp2(ygrille,zgrille,dz,yn,zn,'spline');
                dyn=interp2(ygrille,zgrille,dy,yn,zn,'spline');

                % Obtention des coordonnées déformées et correction

                znd=zn+dzn;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyn;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);

                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            end            
            
        end
        
    end

elseif choix=='f'
    
    % Chargement de l'atlas de déformation sagittal
    
    load defintf;
    
    % Tri de l'atlas par x croissant et localisation de la coupe que l'on
    % souhaite corriger entre deux cartes de déformations
    
    for i=1:length(defintf)
        x(i)=defintf(i,1).Position_x;
    end
    [x,ind]=sort(x);
    defintf=defintf(ind);
    
    if (x0<min(x)) || (x0>max(x))
        error('interpolation entre deux plans de coupes impossible : en dehors des limites');
    else
        d=x-x0;
        for i=1:length(d)
            dn(i)=norm(d(i));
        end
        [mind,k]=min(dn);
        
        if x0>x(k)
            
            xf=[x(k);x(k+1)];
            
            % Définition de la grille régulière
            
            ygrille = defintf(k,1).Grille_reguliere_1;
            zgrille = defintf(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en y et z pour les deux
            % coupes concernées
            
            dy1=defintf(k,1).Valeurs_deformation_1;
            dz1=defintf(k,1).Valeurs_deformation_2;
            dy2=defintf(k+1,1).Valeurs_deformation_1;
            dz2=defintf(k+1,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))
                
                % Reformatage des matrices pour l'interpolation
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                dz1r = reshape(dz1,length(dz1(:)),1);
                dz2r = reshape(dz2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                % interpolation de la déformation dy en x0
            
                dyi=interp1(xf,dy,x0,'spline');
                dyf = reshape(dyi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dzi=interp1(xf,dz,x0,'spline');
                dzf = reshape(dzi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zgrille+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dyf;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            else
   
                % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);
                    end
                end
                
                dyn1=interp2(ygrille,zgrille,dy1,yn,zn,'spline');
                dyn2=interp2(ygrille,zgrille,dy2,yn,zn,'spline');
                dzn1=interp2(ygrille,zgrille,dz1,yn,zn,'spline');
                dzn2=interp2(ygrille,zgrille,dz2,yn,zn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dz1r = reshape(dzn1,length(dz1(:)),1);
                dz2r = reshape(dzn2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(xf,dz,z0,'spline');
                dzf = reshape(dzi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(xf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zn+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
        elseif x0<x(k)
            
            xf=[x(k-1);x(k)];
            
            % Définition de la grille régulière
            
            ygrille = defintf(k-1,1).Grille_reguliere_1;
            zgrille = defintf(k-1,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dy1=defintf(k-1,1).Valeurs_deformation_1;
            dz1=defintf(k-1,1).Valeurs_deformation_2;
            dy2=defintf(k,1).Valeurs_deformation_1;
            dz2=defintf(k,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))
                
                % Reformatage des matrices pour l'interpolation
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                dz1r = reshape(dz1,length(dz1(:)),1);
                dz2r = reshape(dz2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                % interpolation de la déformation dy en x0
            
                dyi=interp1(xf,dy,x0,'spline');
                dyf = reshape(dyi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zgrille+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dyf;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            else
   
             % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);
                    end
                end
                
                dyn1=interp2(ygrille,zgrille,dy1,yn,zn,'spline');
                dyn2=interp2(ygrille,zgrille,dy2,yn,zn,'spline');
                dzn1=interp2(ygrille,zgrille,dz1,yn,zn,'spline');
                dzn2=interp2(ygrille,zgrille,dz2,yn,zn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dz1r = reshape(dzn1,length(dz1(:)),1);
                dz2r = reshape(dzn2,length(dz2(:)),1);
                dz = [dz1r dz2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(xf,dz,z0,'spline');
                dzf = reshape(dzi,256,256);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(xf,dy,z0,'spline');
                dyf = reshape(dyi,256,256);

                % Obtention des coordonnées déformées et correction
            
                znd=zn+dzf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            end         
            
        else
            
            xf=x(k);
            
            % Définition de la grille régulière
            
            ygrille = defintf(k,1).Grille_reguliere_1;
            zgrille = defintf(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dy=defintf(k,1).Valeurs_deformation_1;
            dz=defintf(k,1).Valeurs_deformation_2;
            
            if (y0==ygrille(1,1)) & (z0==zgrille(1,1))

                % Obtention des coordonnées déformées et correction
            
                ynd=ygrille+dy;                                % Obtention des coord2D correspondantes dans image déformée
                znd=zgrille+dz;

                Ima2=double(Ima1);
                Ima3=interp2(ygrille,zgrille,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima1,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);

            else

            % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:256
                    for i=1:256
                        zn(j,i)=z0+(i-1)*dimpix(1)*op(3)+(j-1)*dimpix(2)*op(6);        % Récupération coord2D coupe coronale pour chaque pixel   
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);
                    end
                end
                dzn=interp2(ygrille,zgrille,dz,yn,zn,'spline');
                dyn=interp2(ygrille,zgrille,dy,yn,zn,'spline');

                % Obtention des coordonnées déformées et correction

                znd=zn+dzn;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyn;

                Ima2=double(Ima);
                Ima3=interp2(yn,zn,Ima2,ynd,znd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);

                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'SAG.',int2str(cp),'.dcm'),Imainfo);
            
            end            
            
        end
        
    end
    
end