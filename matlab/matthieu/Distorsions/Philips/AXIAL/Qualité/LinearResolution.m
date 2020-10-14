clear all;
close all;

%% Initialisation des paramètres

cp=100;
name3='.dcm';
    
if (cp < 10)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-000'; 
elseif (cp >= 10) & (cp < 100)
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-00';
else
    name1='/home/matthieu/NAS/matthieu/Distorsions/Fantôme_Philips/20130712_Cq_X/T1W_3D_1mm_GAMMA_701/IM-0007-0';
end
name=strcat(name1,int2str(cp),name3);

    %% Récupération des informations DICOM
   
    Ima1info=dicominfo(name);
    Ima1= dicomread(Ima1info);  
    x0=Ima1info.ImagePositionPatient(1);
    y0=Ima1info.ImagePositionPatient(2);
    z0=Ima1info.ImagePositionPatient(3);
    op=Ima1info.ImageOrientationPatient;
    dimpix=Ima1info.PixelSpacing;
    
    %% Binarisation de l'image
    level = graythresh(Ima1);
    Ima2 = im2bw(Ima1,level);
    
    figure (1)
    subplot(1,2,1)
    imshow(Ima1,[],'InitialMagnification','fit');
    subplot(1,2,2)
    imshow(Ima2,[],'InitialMagnification','fit');
    
    %% Labellisation de l'insert et extraction des extrêmités
    [L,num]=bwlabel(Ima2);
    reg=regionprops(L,'Extrema');  
    
    Xg = [reg.Extrema(6,1) reg.Extrema(8,1)];
    Yg = [reg.Extrema(6,2) reg.Extrema(8,2)];
    Z = [Xg(2) Yg(1)];
    
    Xd = [reg.Extrema(2,1) reg.Extrema(4,1)];
    Yd = [reg.Extrema(2,2) reg.Extrema(4,2)];
    
    figure (2)
    imshow(Ima1,[],'InitialMagnification','fit'); hold on;
    plot([Xg Z(1)],[Yg Z(2)],'g');
    hold off;
    
    %% Calcul de l'angle d'inclinaison de l'insert
    Dist_Hyp = sqrt((Xg(1)-Xg(2))^2+(Yg(1)-Yg(2))^2);
    Dist_x = sqrt((Xg(1)-Xg(2))^2);
    angle = asind(Dist_x/Dist_Hyp); 
   
    %% Détermination des centres de gravité des profils horizontaux et verticaux
    Xvm = mean(Xg);
    Yvm = mean(Yg);
    Xhm = mean([Xg(2) Xd(1)]);
    Yhm = mean([Yg(2) Yd(1)]);
    
    figure(3)
    imshow(Ima1,[],'InitialMagnification','fit'); hold on;
    plot(Xg,Yg,'.g');
    plot(Xd,Yd,'.r');
    plot(Xvm,Yvm,'.b');
    plot(Xhm,Yhm,'.b');
    hold off;
    
    %% Détermination des limites des profils horizontaux et verticaux
    Xhg = ceil(Xg(2))+ceil((Xhm-Xg(2))/2);
    Xhd = ceil(Xd(1))-ceil((Xd(1)-Xhm)/2);
    Yhu = ceil(Yg(2))+ceil((Yvm-Yg(2))/2);
    Yhd = ceil(Yg(1))-ceil((Yg(1)-Yvm)/2);
    
    %% Récupération des niveaux de gris sur chacun des profils horizontaux et verticaux
    PixelValueh = zeros(1,length(ceil(Xhg):ceil(Xhd)));
    for j = ceil(Xhg):ceil(Xhd)
        PixelValueh(j-ceil(Xhg)+1) = Ima1(ceil(Yhm),j);
    end
    
    PixelValuev = zeros(1,length(ceil(Yhu):ceil(Yhd)));
    for i = ceil(Yhu):ceil(Yhd)
        PixelValuev(i-ceil(Yhu)+1) = Ima1(i,ceil(Xvm));
    end   
    
    figure(4)
    imshow(Ima1,[],'InitialMagnification','fit'); hold on;
    plot(ceil(Xhg):ceil(Xhd),ones(1,length(ceil(Xhg):ceil(Xhd)))*ceil(Yhm),'b','LineWidth',2);
    plot(ones(1,length(ceil(Yhu):ceil(Yhd)))*ceil(Xvm),ceil(Yhu):ceil(Yhd),'r','LineWidth',2);
    plot(Xvm,Yvm,'.g');
    plot(Xhm,Yhm,'.g');
    hold off
    
    %% Fitting polynomial des profils horizontaux et verticaux
    ph = polyfit(ceil(Xhg):ceil(Xhd),PixelValueh,7);
    pv = polyfit(ceil(Yhu):ceil(Yhd),PixelValuev,7);
    
    range_x = ceil(Xhg):0.01:ceil(Xhd);
    range_y = ceil(Yhu):0.01:ceil(Yhd);
    Valueh = polyval(ph,range_x);
    Valuev = polyval(pv,range_y);
    
    figure(5)
    subplot(1,2,1)
    plot(ceil(Xhg):ceil(Xhd),PixelValueh,'b');hold on;
    plot(range_x,Valueh,'r');
    hold off
    subplot(1,2,2)
    plot(ceil(Yhu):ceil(Yhd),PixelValuev,'b');hold on;
    plot(range_y,Valuev,'r');
    hold off
    
    %% Calcul des dérivées des profils horizontaux et verticaux
    kh = polyder(ph);
    kv = polyder(pv);
    Derh = polyval(kh,range_x);
    Derv = polyval(kv,range_y);
    
    %% Calcul de la largeur à mi-hauteur des dérivées des profils LSF horizontaux et verticaux : LSFx et LSFy
    Ih = InterX([range_x;Derh],[range_x;ones(1,length(range_x))*(max(Derh)/2)]);
    Iv = InterX([range_y;Derv],[range_y;ones(1,length(range_y))*(min(Derv)/2)]);
    
    figure(6)
    subplot(1,2,1)
    plot(range_x,Derh,'b');hold on;
    plot(Ih(1,:),Ih(2,:),'.r');
    plot(Ih(1,:),Ih(2,:),'r');
    text(Ih(1,1),Ih(2,1)-10,'W = LMH','color','red');
    hold off
    subplot(1,2,2)
    plot(range_y,Derv,'r');hold on;
    plot(Iv(1,:),Iv(2,:),'.b');
    plot(Iv(1,:),Iv(2,:),'b');
    hold off
    
    Ph = zeros(size(Ih,2),3);
    Pv = zeros(size(Iv,2),3);

    for i=1:size(Ih,2)
        Ph(i,1) = x0+(Ih(1,i)-1)*dimpix(1)*op(1)+(Ih(2,i)-1)*dimpix(2)*op(4);
        Ph(i,2) = y0+(Ih(1,i)-1)*dimpix(1)*op(2)+(Ih(2,i)-1)*dimpix(2)*op(5);  
        Ph(i,3) = z0+(Ih(1,i)-1)*dimpix(1)*op(3)+(Ih(2,i)-1)*dimpix(2)*op(6);
    end
        for i=1:size(Iv,2)
        Pv(i,1) = x0+(Iv(1,i)-1)*dimpix(1)*op(1)+(Iv(2,i)-1)*dimpix(2)*op(4);
        Pv(i,2) = y0+(Iv(1,i)-1)*dimpix(1)*op(2)+(Iv(2,i)-1)*dimpix(2)*op(5);  
        Pv(i,3) = z0+(Iv(1,i)-1)*dimpix(1)*op(3)+(Iv(2,i)-1)*dimpix(2)*op(6);
    end
              
    Disth = sqrt((Ph(2,1)-Ph(1,1))^2+(Ph(2,2)-Ph(1,2))^2+(Ph(2,3)-Ph(1,3))^2);
    Distv = sqrt((Pv(2,1)-Pv(1,1))^2+(Pv(2,2)-Pv(1,2))^2+(Pv(2,3)-Pv(1,3))^2);
    
    LSFx = Disth*sind(angle);
    LSFy = Distv*sind(angle);
    
    %% Calcul des Transformées de Fourier des dérivées des LSF
    
    idx_inf=[];
    idx_sup=[];
    NbBornes=0;
    Derh_i1=-1;
    for i=1:length(range_x)
        if (NbBornes==0) && (Derh(i)>=0) && (Derh_i1<0)
            idx_inf = i;
            NbBornes = NbBornes+1;
        elseif (NbBornes==1) && (Derh(i)<0) && (Derh_i1>=0)
            idx_sup = i;
            NbBornes = NbBornes+1;
        end
        Derh_i1 = Derh(i);
    end

    range_xn = range_x(idx_inf:idx_sup);
    Derh_new = Derh(idx_inf:idx_sup);
    
% Fs = 1000;                    % Sampling frequency
% T = 1/Fs;                     % Sample time
% L = 1000;                     % Length of signal
% t = (0:L-1)*T;                % Time vector
% % Sum of a 50 Hz sinusoid and a 120 Hz sinusoid
% x = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t); 
% y = x + 2*randn(size(t));     % Sinusoids plus noise
% plot(Fs*t(1:50),y(1:50))
% title('Signal Corrupted with Zero-Mean Random Noise')
% xlabel('time (milliseconds)')
% 
% NFFT = 2^nextpow2(L); % Next power of 2 from length of y
% Y = fft(y,NFFT)/L;
% f = Fs/2*linspace(0,1,NFFT/2+1);
% 
% % Plot single-sided amplitude spectrum.
% plot(f,2*abs(Y(1:NFFT/2+1))) 
% title('Single-Sided Amplitude Spectrum of y(t)')
% xlabel('Frequency (Hz)')
% ylabel('|Y(f)|')

    figure(7)
    plot(range_xn,Derh_new,'b');
    MTFh = fft(Derh_new);
%     MTFv = fft(Derv);
%     
    figure(8)
    plot(1:length(range_xn),MTFh,'b');hold on;
%     plot(1:length(range_y),MTFv,'.g');
    hold off;