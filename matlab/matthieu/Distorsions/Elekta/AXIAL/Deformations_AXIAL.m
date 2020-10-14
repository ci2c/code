function [dX,dY,dR,Xv,Yv,Ima1info,z0]= Deformations_AXIAL(name,Pf,Xf,Cgt,cp,maxDef)


%% Get informations from the DICOM image treated %%

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;


%% Compute radial, X and Y distorsions in 3D coordinates %%

    %% X, Y and radial distorsions computed in mm at each control point %% 
    x=Pf(:,1);
    y=Pf(:,2);
    dx=Xf(:,1)-x;
    dy=Xf(:,2)-y;      
    dr=sqrt(dx.^2+dy.^2);

    
%% Interpolate X, Y and radial distorsions in 3D coordinates to view distorsion surfaces %%

    %% Interpolate distorsions in 3D coordinates %%
    xv = linspace(min(x),max(x),150);
    yv = linspace(min(y),max(y),150);
    [Xv,Yv] = meshgrid(xv,yv);
    dX = griddata(x,y,dx,Xv,Yv,'cubic');
    dY = griddata(x,y,dy,Xv,Yv,'cubic');
    dR = griddata(x,y,dr,Xv,Yv,'cubic');

    %% Distorsions surface according X and statistical values %%
    [maxx,indxa] = max(dx);
    [minx,indxb] = min(dx);
    moyx=mean(abs(dx));
    sdx = std(abs(dx));

    figure(18)
    plot3(x,y,dx,'ro');
    hold on
    surface(Xv,Yv,dX,'edgecolor','none')
    title(['Characterization of distorsions in X in axial slice ', num2str(cp)],'FontSize',14);
    texte1 = ['Maximum distorsion in X : ', num2str(maxx),' mm'];
    texte2 = ['Minimum distorsion in X : ', num2str(minx),' mm'];
    texte3 = ['Mean distorsion in X : ', num2str(moyx),' mm'];
    texte4 = ['Standard deviation distorsion in X: ', num2str(sdx),' mm'];
    annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte1);
    annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte2);
    annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte3);
    annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte4);
    xlabel('X axe');
    ylabel('Y axe');
    zlabel('Distorsion dX');
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    axis vis3d
    grid on
    hold off;

    %% Distorsions surface according Y and statistical values %%
    [maxy,indya] = max(dy);
    [miny,indyb] = min(dy);
    moyy=mean(abs(dy));
    sdy = std(abs(dy));

    figure(19)
    plot3(x,y,dy,'ro');
    hold on
    surface(Xv,Yv,dY,'edgecolor','none')
    title(['Characterization of distorsions in Y in axial slice ', num2str(cp)],'FontSize',14);
    texte1 = ['Maximum distorsion in Y : ', num2str(maxy),' mm'];
    texte2 = ['Minimum distorsion in Y : ', num2str(miny),' mm'];
    texte3 = ['Mean distorsion in Y : ', num2str(moyy),' mm'];
    texte4 = ['Standard deviation distorsion in Y: ', num2str(sdy),' mm'];
    annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte1);
    annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte2);
    annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte3);
    annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte4);
    xlabel('X axe');
    ylabel('Y axe');
    zlabel('Distorsion dY');
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    axis vis3d
    grid on;
    hold off;

    %% Radial distorsions surface and statistical values %%
    [maxr,indra] = max(dr);
    [minr,indrb] = min(dr);
    moyr=mean(dr);
    sdr = std(dr);

    figure(20)
    plot3(x,y,dr,'ro');
    hold on
    surface(Xv,Yv,dR,'edgecolor','none')
    title(['Characterization of radial distorsions in axial slice ', num2str(cp)],'FontSize',14);
    texte1 = ['Radial distorsion maximum : ', num2str(maxr),' mm'];
    texte2 = ['Radial distorsion minimum : ', num2str(minr),' mm'];
    texte3 = ['Radial distorsion mean : ', num2str(moyr),' mm'];
    texte4 = ['Radial distorsion standard deviation : ', num2str(sdr),' mm'];
    annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte1);
    annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte2);
    annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte3);
    annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte4);
    xlabel('X axe (mm)','FontSize',14);
    ylabel('Y axe (mm)','FontSize',14);
    zlabel('Distorsion dR (mm)','FontSize',14);
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    grid on;
    hold off;


%% Interpolate radial distorsions in pixel coordinates %%
xp=Cgt(:,1);
yp=Cgt(:,2);
xpi = linspace(min(xp),max(xp),150);
ypi = linspace(min(yp),max(yp),150);
[Xp,Yp] = meshgrid(xpi,ypi);
dRp = griddata(xp,yp,dr,Xp,Yp,'cubic');   


%% Visualize isocontours of radial distorsions in pixel space%%
    
figure (21)
% imshow(Ima1,[],'XData',Xv(1,:),'YData',Yv(:,1),'InitialMagnification','fit');
imshow(Ima1,[],'InitialMagnification','fit');hold on
[C,h] = contour('v6',Xp,Yp,dRp,0:0.1:maxDef);
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize);
map= winter(length(h));
for n=1:length(map)
    set(h(n),'edgecolor',map(n,:),'LineWidth',1);
    axis on
end 
clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
xlabel('X axe','FontSize',14);
ylabel('Y axe','FontSize',14);
title(['Isocontours of radial distorsion in axial slice ', num2str(cp)],'FontSize',14);
plot(Cgt(:,1),Cgt(:,2),'.r','MarkerSize',12);
hold off
clear C h;