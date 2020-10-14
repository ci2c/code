function Imac = corr_inter_TRS(choix,name1,cp,repertoire)

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

    %% Correction à partir de l'atlas de déformations 2D axial obtenu à
    %% partir des centres de gravités détectés automatiquement + ajout
    %% manuel %%
    
if choix == 'm'
    
    % Chargement de l'atlas de déformation axial
    
    load defintm;
    
    % Tri de l'atlas par z croissant et localisation de la coupe que l'on
    % souhaite corriger entre deux cartes de déformations
    
    for i=1:length(defintm)
        z(i)=defintm(i,1).Position_z;
    end
    [z,ind]=sort(z);
    defintm=defintm(ind);
    
    if (z0<min(z)) || (z0>max(z))
        error('interpolation entre deux plans de coupes impossible : en dehors des limites');
        
    else
        d=z-z0;
        for i=1:length(d)
            dn(i)=norm(d(i));
        end
        [mind,k]=min(dn);
        
        if z0>z(k)
            
            zf=[z(k);z(k+1)];
            
            % Définition de la grille régulière
            
            xgrille = defintm(k,1).Grille_reguliere_1;
            ygrille = defintm(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % cartes concernées
            
            dx1=defintm(k,1).Valeurs_deformation_1;
            dy1=defintm(k,1).Valeurs_deformation_2;
            dx2=defintm(k+1,1).Valeurs_deformation_1;
            dy2=defintm(k+1,1).Valeurs_deformation_2;
            
            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))
            
                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dx1,length(dx1(:)),1);
                dx2r = reshape(dx2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                % interpolation de la déformation dx en z0
            
                dxi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dxf;                                
                ynd=ygrille+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            else
   
                % Interpolation sur la grille définie par l'image à corriger
                
                xn = zeros(1,taillec);
                yn = zeros(1,taillel);
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                
                dyn1=interp2(xgrille,ygrille,dy1,xn,yn,'spline');
                dyn2=interp2(xgrille,ygrille,dy2,xn,yn,'spline');
                dxn1=interp2(xgrille,ygrille,dx1,xn,yn,'spline');
                dxn2=interp2(xgrille,ygrille,dx2,xn,yn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dxn1,length(dx1(:)),1);
                dx2r = reshape(dxn2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées et correction
            
                xnd=xn+dxf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
            
        elseif z0<z(k)
            
            zf=[z(k-1);z(k)];
            
            % Définition de la grille régulière
            
            xgrille = defintm(k-1,1).Grille_reguliere_1;
            ygrille = defintm(k-1,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dx1=defintm(k-1,1).Valeurs_deformation_1;
            dy1=defintm(k-1,1).Valeurs_deformation_2;
            dx2=defintm(k,1).Valeurs_deformation_1;
            dy2=defintm(k,1).Valeurs_deformation_2;
            
            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))
                
                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dx1,length(dx1(:)),1);
                dx2r = reshape(dx2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                % interpolation de la déformation dx en z0
            
                dxi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dxf;                               
                ynd=ygrille+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
                
            else
   
                % Interpolation sur la grille définie par l'image à corriger
                
                xn = zeros(1,taillec);
                yn = zeros(1,taillel);
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                
                dyn1=interp2(xgrille,ygrille,dy1,xn,yn,'spline');
                dyn2=interp2(xgrille,ygrille,dy2,xn,yn,'spline');
                dxn1=interp2(xgrille,ygrille,dx1,xn,yn,'spline');
                dxn2=interp2(xgrille,ygrille,dx2,xn,yn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dxn1,length(dx1(:)),1);
                dx2r = reshape(dxn2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées et correction
            
                xnd=xn+dxf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
        else
            
            zf=z(k);
            
            % Définition de la grille régulière
            
            xgrille = defintm(k,1).Grille_reguliere_1;
            ygrille = defintm(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dx=defintm(k,1).Valeurs_deformation_1;
            dy=defintm(k,1).Valeurs_deformation_2;
            
            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))

                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dx;                                
                ynd=ygrille+dy;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            else

            % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                dxn=interp2(xgrille,ygrille,dx,xn,xn,'spline');
                dyn=interp2(xgrille,ygrille,dy,xn,yn,'spline');

                % Obtention des coordonnées déformées et correction

                xnd=xn+dxn;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyn;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);

                figure (1)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end     
            
        end
        
    end

    %% Correction à partir de l'atlas de déformations 2D axial obtenu à
    %% partir des centres de gravités issus du fit polynomial %%
    
elseif choix=='f'
    
    % Chargement de l'atlas de déformation axial
    
    load defintf;
    
    % Tri de l'atlas par z croissant et localisation de la coupe que l'on
    % souhaite corriger entre deux cartes de déformations
    
    for i=1:length(defintf)
        z(i)=defintf(i,1).Position_z;
    end
    [z,ind]=sort(z);
    defintf=defintf(ind);
    
    if (z0<min(z)) || (z0>max(z))
        error('interpolation entre deux plans de coupes impossible : en dehors des limites');
        
    else
        d=z-z0;
        for i=1:length(d)
            dn(i)=norm(d(i));
        end
        [mind,k]=min(dn);
        
        if z0>z(k)
            
            zf=[z(k);z(k+1)];
            
            % Définition de la grille régulière
            
            xgrille = defintf(k,1).Grille_reguliere_1;
            ygrille = defintf(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dx1=defintf(k,1).Valeurs_deformation_1;
            dy1=defintf(k,1).Valeurs_deformation_2;
            dx2=defintf(k+1,1).Valeurs_deformation_1;
            dy2=defintf(k+1,1).Valeurs_deformation_2;
            
            
            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))
                
                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dx1,length(dx1(:)),1);
                dx2r = reshape(dx2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                % interpolation de la déformation dx en z0
            
                dxi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dxf;                              
                ynd=ygrille+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);

            else
   
                % Interpolation sur la grille définie par l'image à corriger
                
                xn = zeros(1,taillec);
                yn = zeros(1,taillel);
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                
                dyn1=interp2(xgrille,ygrille,dy1,xn,yn,'spline');
                dyn2=interp2(xgrille,ygrille,dy2,xn,yn,'spline');
                dxn1=interp2(xgrille,ygrille,dx1,xn,yn,'spline');
                dxn2=interp2(xgrille,ygrille,dx2,xn,yn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dxn1,length(dx1(:)),1);
                dx2r = reshape(dxn2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées et correction
            
                xnd=xn+dxf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
        elseif z0<z(k)
            
            zf=[z(k-1);z(k)];
            
            % Définition de la grille régulière
            
            xgrille = defintf(k-1,1).Grille_reguliere_1;
            ygrille = defintf(k-1,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dx1=defintf(k-1,1).Valeurs_deformation_1;
            dy1=defintf(k-1,1).Valeurs_deformation_2;
            dx2=defintf(k,1).Valeurs_deformation_1;
            dy2=defintf(k,1).Valeurs_deformation_2;
            
            
            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))
                
                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dx1,length(dx1(:)),1);
                dx2r = reshape(dx2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dy1,length(dy1(:)),1);
                dy2r = reshape(dy2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
            
                % interpolation de la déformation dx en z0
            
                dxi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dxf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
 
            else
   
                % Interpolation sur la grille définie par l'image à corriger
                
                xn = zeros(1,taillec);
                yn = zeros(1,taillel);
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                
                dyn1=interp2(xgrille,ygrille,dy1,xn,yn,'spline');
                dyn2=interp2(xgrille,ygrille,dy2,xn,yn,'spline');
                dxn1=interp2(xgrille,ygrille,dx1,xn,yn,'spline');
                dxn2=interp2(xgrille,ygrille,dx2,xn,yn,'spline');

                % Reformatage des matrices pour l'interpolation
            
                dx1r = reshape(dxn1,length(dx1(:)),1);
                dx2r = reshape(dxn2,length(dx2(:)),1);
                dx = [dx1r dx2r]';
            
                dy1r = reshape(dyn1,length(dy1(:)),1);
                dy2r = reshape(dyn2,length(dy2(:)),1);
                dy = [dy1r dy2r]';
                
                % interpolation de la déformation dx en z0
            
                dzi=interp1(zf,dx,z0,'spline');
                dxf = reshape(dxi,taillel,taillec);
            
                % interpolation de la déformation dy en z0
            
                dyi=interp1(zf,dy,z0,'spline');
                dyf = reshape(dyi,taillel,taillec);

                % Obtention des coordonnées déformées et correction
            
                xnd=xn+dxf;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyf;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end
            
        else
            
            zf=z(k);
            
            % Définition de la grille régulière
            
            xgrille = defintf(k,1).Grille_reguliere_1;
            ygrille = defintf(k,1).Grille_reguliere_2;
            
            % Obtention des valeurs de déformations en x et y pour les deux
            % coupes concernées
            
            dx=defintf(k,1).Valeurs_deformation_1;
            dy=defintf(k,1).Valeurs_deformation_2;

            if (x0==xgrille(1,1)) & (y0==ygrille(1,1))
                
                % Obtention des coordonnées déformées correspondantes et correction
            
                xnd=xgrille+dx;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=ygrille+dy;

                Ima2=double(Ima);
                Ima3=interp2(xgrille,ygrille,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);
            
                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
               
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);

            else

                % Interpolation sur la grille définie par l'image à corriger
            
                for j=1:taillel
                    for i=1:taillec
                        yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);        % Récupération coord2D coupe coronale pour chaque pixel   
                        xn(j,i)=z0+(i-1)*dimpix(2)*op(1)+(j-1)*dimpix(2)*op(4);
                    end
                end
                [xn,yn] = meshgrid(xn,yn);
                dxn=interp2(xgrille,ygrille,dx,xn,xn,'spline');
                dyn=interp2(xgrille,ygrille,dy,xn,yn,'spline');

                % Obtention des coordonnées déformées et correction

                xnd=xn+dxn;                                % Obtention des coord2D correspondantes dans image déformée
                ynd=yn+dyn;

                Ima2=double(Ima);
                Ima3=interp2(xn,yn,Ima2,xnd,ynd,'cubic');           % Obtention de l'intensité aux coord2D de la nouvelle image par interpolation sur image déformée
                Imac=uint16(Ima3);

                figure (2)
                subplot(121)
                imshow(Ima,[],'notruesize');
                subplot(122);
                imshow(Imac,[],'notruesize');
                
                % Ecriture de l'image corrigée en format DICOM
        
                dicomwrite(Imac,strcat(repertoire,'TRS.',int2str(cp),'.dcm'),Imainfo);
            
            end            
            
        end
        
    end
    
end