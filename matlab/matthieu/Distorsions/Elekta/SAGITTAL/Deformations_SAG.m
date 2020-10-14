function [dY,dZ,dR,Yv,Zv,Ima1info,x0]= Deformations_SAG(name,Pf,Xf,Cgt,cp,maxDef)


%% Get informations from the DICOM image treated %%

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;


%% Compute radial, Y and Z distorsions in 3D coordinates %%

    %% Y, Z and radial distorsions computed in mm at each control point %% 
    y=Pf(:,2);
    z=Pf(:,3);
    dy=Xf(:,2)-y;
    dz=Xf(:,3)-z;      
    dr=sqrt(dy.^2+dz.^2);

    
%% Interpolate Y, Z and radial distorsions in 3D coordinates to view distorsion surfaces %%

    %% Interpolate distorsions in 3D coordinates %%
    yv = linspace(min(y),max(y),150);
    zv = linspace(min(z),max(z),150);
    [Yv,Zv] = meshgrid(yv,zv);
    dY = griddata(y,z,dy,Yv,Zv,'cubic');
    dZ = griddata(y,z,dz,Yv,Zv,'cubic');
    dR = griddata(y,z,dr,Yv,Zv,'cubic');

    %% Distorsions surface according Y and statistical values %%
    [maxy,indya] = max(dy);
    [miny,indyb] = min(dy);
    moyy=mean(abs(dy));
    sdy = std(abs(dy));

    figure(18)
    plot3(y,z,dx,'ro');
    hold on
    surface(Yv,Zv,dY,'edgecolor','none')
    title(['Characterization of distorsions in Y in sagittal slice ', num2str(cp)],'FontSize',14);
    texte1 = ['Maximum distorsion in Y : ', num2str(maxy),' mm'];
    texte2 = ['Minimum distorsion in Y : ', num2str(miny),' mm'];
    texte3 = ['Mean distorsion in Y : ', num2str(moyy),' mm'];
    texte4 = ['Standard deviation distorsion in X: ', num2str(sdy),' mm'];
    annotation('textbox', [.005 .15 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte1);
    annotation('textbox', [.005 .1 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte2);
    annotation('textbox', [.005 .05 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte3);
    annotation('textbox', [.005 0 .1 .1], 'FitHeightToText', 'ON', 'Fontsize', 10, ...
               'String', texte4);
    xlabel('Y axe');
    ylabel('Z axe');
    zlabel('Distorsion dY');
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
    plot3(y,z,dz,'ro');
    hold on
    surface(Yv,Zv,dZ,'edgecolor','none')
    title(['Characterization of distorsions in Z in sagittal slice ', num2str(cp)],'FontSize',14);
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
    xlabel('Y axe');
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
    plot3(y,z,dr,'ro');
    hold on
    surface(Yv,Zv,dR,'edgecolor','none')
    title(['Characterization of radial distorsions in sagittal slice ', num2str(cp)],'FontSize',14);
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
    xlabel('Y axe (mm)','FontSize',14);
    ylabel('Z axe (mm)','FontSize',14);
    zlabel('Distorsion dR (mm)','FontSize',14);
    ScrSize = get(0,'ScreenSize');
    set(gcf,'Units','pixels','Position',ScrSize);
    grid on;
    hold off;


%% Interpolate radial distorsions in pixel coordinates %%
yp=Cgt(:,1);
zp=Cgt(:,2);
ypi = linspace(min(yp),max(yp),150);
zpi = linspace(min(zp),max(zp),150);
[Yp,Zp] = meshgrid(ypi,zpi);
dRp = griddata(yp,zp,dr,Yp,Zp,'cubic');   


%% Visualize isocontours of radial distorsions in pixel space%%
    
figure (21)
% imshow(Ima1,[],'XData',Yv(1,:),'YData',Zv(:,1),'InitialMagnification','fit');
imshow(Ima1,[],'InitialMagnification','fit');hold on
[C,h] = contour('v6',Yp,Zp,dRp,0:0.1:maxDef);
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize);
map= winter(length(h));
for n=1:length(map)
    set(h(n),'edgecolor',map(n,:),'LineWidth',1);
    axis on
end 
clabel(C,h,'FontWeight','bold','color','w','Rotation',0);
xlabel('Y axe','FontSize',14);
ylabel('Z axe','FontSize',14);
title(['Isocontours of radial distorsion in sagittal slice ', num2str(cp)],'FontSize',14);
plot(Cgt(:,1),Cgt(:,2),'.r','MarkerSize',12);
hold off
clear C h;