clear all;
close all;

%% Caractérisation de la disorsion radiale sur une coupe axiale %%

    name1='/home/matthieu/NAS/matthieu/Distorsions/Code - CORONAL/IM-0004-00';
    cp=25;
    name3='.dcm';
    name=strcat(name1,int2str(cp),name3);
    Imainfo = dicominfo(name);
    Ima = dicomread(Imainfo);
    x0=Imainfo.ImagePositionPatient(1);
    y0=Imainfo.ImagePositionPatient(2);
    z0=Imainfo.ImagePositionPatient(3);
    op=Imainfo.ImageOrientationPatient;
    dimpix=Imainfo.PixelSpacing;
    
%     % Détermination de la droite de mesure de déformation radiale : choix
%     % de 2 points
%     
%     X = [95;218];
%     Y = [294;191];
%     
%     p = polyfit(X,Y,1);
%     xi = linspace(X(1),X(2),100);
%     yi = polyval(p,xi); 
%     Cgi = [xi' yi'];
%     
%     % Visualisation des cercles limites et de la droite de mesure
%     
%     figure (1)
%     imshow(Ima,[],'InitialMagnification','fit');hold on
%     circle(109.7133,[218 191],'--b',138.9702,[218 191],'--r');
%     plot(X,Y,'.');
%     plot(X,Y,'g');
% %     plot(xi,f,'.g');
%     hold off
    
    % Interpolation des valeurs de déformations suivant l'axe radial
%    
%     CG=zeros(size(Cgi,1),2);    
%     for i=1:size(Cgi,1)
%     
%         CG(i,1)=x0+(Cgi(i,1)-1)*dimpix(1)*op(1)+(Cgi(i,2)-1)*dimpix(2)*op(4);
%         CG(i,2)=y0+(Cgi(i,1)-1)*dimpix(1)*op(2)+(Cgi(i,2)-1)*dimpix(2)*op(5);
%         
%     end
%     
%     r = zeros(size(CG,1),1);
%     for i=1:size(CG,1)
%         r(i) = sqrt(CG(i,1)^2+CG(i,2)^2);
%     end
%            
    load defint;      % Chargement de l'atlas de déformation axial 
    
    xgrille = defintm(7,1).Grille_reguliere_1;
    zgrille = defintm(7,1).Grille_reguliere_2;
    dx = defintm(7,1).Valeurs_deformation_1;
    dz = defintm(7,1).Valeurs_deformation_2;
%     
%     dxi = interp2(xgrille,ygrille,dx,CG(:,1),CG(:,2));
%     dyi = interp2(xgrille,ygrille,dy,CG(:,1),CG(:,2));
%    
%     dri = sqrt(dxi.^2+dyi.^2);
% 
%     % Repr�sentation de la d�formation suivant l'axe radial
%     
%     figure (2)
%     plot(r,dri);
%     xlabel('Distance from the center of the Bo homogeneous volume (mm)');
%     ylabel('Distorsions (mm)');
%     grid on
%     
%     
%% Calcul de la d�formation radiale à chaque pixel de l'image à partir de l'atlas et repr�sentation des
%% isocontours de d�formation radiale %%
    
    dr = sqrt(dx.^2+dz.^2);
    figure (3)
    imshow(Ima,[],'XData',xgrille(1,:),'YData',zgrille(:,1),'InitialMagnification','fit');hold on
    [C,h] = contour('v6',xgrille,zgrille,dr,0:0.2:2);
    map= jet(length(h));
    for n=1:length(map)
        set(h(n),'edgecolor',map(n,:),'LineWidth',1.5);
        axis on
    end 
    clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
    xlabel('Y (mm)');
    ylabel('Z (mm)');
    hold off
    clear C h;

% pause;
% close all;
% 
% %% Calcul d�formation radiale sur image corrig�e axiale et repr�sentation des erreurs r�siduelles par isocontours %%
%     
%         name1='Corrig�es_fit\TRS.';
%         name3='b.dcm';       
%         cp=29;
%         name=strcat(name1,int2str(cp),name3);
%         Imacinfo=dicominfo(name);
%         x0=Imacinfo.ImagePositionPatient(1);
%         y0=Imacinfo.ImagePositionPatient(2);
%         z0=Imacinfo.ImagePositionPatient(3);
%         op=Imacinfo.ImageOrientationPatient;
%         dimpix=Imacinfo.PixelSpacing;
%         taillel=Imacinfo.Rows;
%         taillec=Imacinfo.Columns;
%         choix = 'f'
%         
%         % Calcul erreurs r�siduelles sur images corrig�es fit : d�tection manuelle et fit 
%         
%         [Cgc,Ima] = detection_TRS(name,cp);
%         [Cgct,PIc] = tri_TRS(Ima,Cgc);  
%         
%         switch choix
%             
%             case 'm'
%                 
%             % d�tection auto + manuelle
%             
%         [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,Cgct);
%         
%             case 'f'
%        
%             % fit polynomial
%             
%         [Rc,qc,depc,Pfc,errorc,CGc,Cthc] = recalage_TRS(name,PIc);
% 
%         end
%         
%         % Calcul de la d�formation suivant x et y
% 
%         x=Pfc(:,1);
%         y=Pfc(:,2);
%         dx=CGc(:,1)-x;
%         dy=CGc(:,2)-y;      
%         dr=sqrt(dx.^2+dy.^2);
%         
%         % Visualisation surfacique de la d�formation et pr�-interpolation : obtention d'une grille r�guli�re de d�formation 
% 
%         xg=linspace(x0-dimpix(1)/2,x0+(taillec-1)*dimpix(1)+dimpix(1)/2,100);      %Nombre de points pour l'interpolation: limites inf et sup coord pixel 1 et end
%         yg=linspace(y0-dimpix(2)/2,y0+(taillel-1)*dimpix(2)+dimpix(2)/2,100);
% 
%         [gx,xgrid,ygrid]=gridfit(x,y,dx,xg,yg);
%         gy=gridfit(x,y,dy,xg,yg);
%         gr=gridfit(x,y,dr,xg,yg);
%         
%         % Interpolation de la d�formation et correction 2D
% 
%         for j=1:taillel
%             for i=1:taillec
%             xn(j,i)=x0+(i-1)*dimpix(1)*op(1)+(j-1)*dimpix(2)*op(4);        % R�cup�ration coord2D coupe coronale pour chaque pixel   
%             yn(j,i)=y0+(i-1)*dimpix(1)*op(2)+(j-1)*dimpix(2)*op(5);
%             end
%         end
% 
%         dxn=interp2(xgrid,ygrid,gx,xn,yn,'spline');
%         dyn=interp2(xgrid,ygrid,gy,xn,yn,'spline');
%         drn=sqrt(dxn.^2+dyn.^2);
%            
%         figure (5)
%         surf(xn,yn,drn);
%         
%         % Repr�sentation des isocontours de la d�formation radiale sur l'image
%         % corrig�e
%         
%         Imac = dicomread(Imacinfo);
%         figure (6)
%         imshow(xn(1,:),yn(:,1),Imac,[],'notruesize');hold on
%         [C,h] = contour('v6',xn,yn,drn,0:0.25:3);
%         map= jet(length(h));
%         for n=1:length(map)
%             set(h(n),'edgecolor',map(n,:),'LineWidth',1.5);
%             axis on
%         end 
%         clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
%         xlabel('X (mm)');
%         ylabel('Y (mm)');
%         hold off