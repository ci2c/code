function [dX,dZ,dR,Xv,Zv,Ima1info,y0]= Deformations_COR(name,Pf,Xf,Cgt,cp,maxDef)


%% Get informations from the DICOM image treated %%

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;


%% Compute radial, X and Z distorsions in 3D coordinates %%

    %% X, Z and radial distorsions computed in mm at each control point %% 
    x=Pf(:,1);
    z=Pf(:,3);
    dx=Xf(:,1)-x;
    dz=Xf(:,3)-z;      
    dr=sqrt(dx.^2+dz.^2);

    
%% Interpolate X, Z and radial distorsions in 3D coordinates to view distorsion surfaces %%

    %% Interpolate distorsions in 3D coordinates %%
    xv = linspace(min(x),max(x),150);
    zv = linspace(min(z),max(z),150);
    [Xv,Zv] = meshgrid(xv,zv);
    dX = griddata(x,z,dx,Xv,Zv,'cubic');
    dz = griddata(x,z,dz,Xv,Zv,'cubic');
    dR = griddata(x,z,dr,Xv,Zv,'cubic');

    %% Distorsions surface according X and statistical values %%
    [maxx,indxa] = max(dx);
    [minx,indxb] = min(dx);
    moyx=mean(abs(dx));
    sdx = std(abs(dx));

    figure(18)
    plot3(x,z,dx,'ro');
    hold on
    surface(Xv,Zv,dX,'edgecolor','none')
    title(['Characterization of distorsions in X in COR slice ', num2str(cp)],'FontSize',14);
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
    ylabel('Z axe');
    zlabel('Distorsion dX');
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    axis vis3d
    grid on
    hold off;

    %% Distorsions surface according Z and statistical values %%
    [maxz,indza] = max(dz);
    [minz,indzb] = min(dz);
    moyz=mean(abs(dz));
    sdz = std(abs(dz));

    figure(19)
    plot3(x,z,dz,'ro');
    hold on
    surface(Xv,Zv,dZ,'edgecolor','none')
    title(['Characterization of distorsions in Z in COR slice ', num2str(cp)],'FontSize',14);
    texte1 = ['Maximum distorsion in Z : ', num2str(maxz),' mm'];
    texte2 = ['Minimum distorsion in Z : ', num2str(minz),' mm'];
    texte3 = ['Mean distorsion in Z : ', num2str(moyz),' mm'];
    texte4 = ['Standard deviation distorsion in Z: ', num2str(sdz),' mm'];
    annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte1);
    annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte2);
    annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte3);
    annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte4);
    xlabel('X axe');
    ylabel('Z axe');
    zlabel('Distorsion dZ');
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
    plot3(x,z,dr,'ro');
    hold on
    surface(Xv,Zv,dR,'edgecolor','none')
    title(['Characterization of radial distorsions in COR slice ', num2str(cp)],'FontSize',14);
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
    ylabel('Z axe (mm)','FontSize',14);
    zlabel('Distorsion dR (mm)','FontSize',14);
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    grid on;
    hold off;


%% Interpolate radial distorsions in pixel coordinates %%
xp=Cgt(:,1);
zp=Cgt(:,2);
xpi = linspace(min(xp),max(xp),150);
zpi = linspace(min(zp),max(zp),150);
[Xp,Zp] = meshgrid(xpi,zpi);
dRp = griddata(xp,zp,dr,Xp,Zp,'cubic');   


%% Visualize isocontours of radial distorsions in pixel space%%
    
figure (21)
% imshow(Ima1,[],'XData',Xv(1,:),'YData',Zv(:,1),'InitialMagnification','fit');
imshow(Ima1,[],'InitialMagnification','fit');hold on
[C,h] = contour('v6',Xp,Zp,dRp,0:0.1:maxDef);
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize);
map= winter(length(h));
for n=1:length(map)
    set(h(n),'edgecolor',map(n,:),'LineWidth',1);
    axis on
end 
clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
xlabel('X axe','FontSize',14);
ylabel('Z axe','FontSize',14);
title(['Isocontours of radial distorsion in COR slice ', num2str(cp)],'FontSize',14);
plot(Cgt(:,1),Cgt(:,2),'.r','MarkerSize',12);
hold off
clear C h;