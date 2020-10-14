function [R,q,dep,Pf,error,CG,Cth] = Recalage_SAG(name,PC)

%% Get informations from the DICOM image treated %%

Ima1info=dicominfo(name);
Ima1= dicomread(Ima1info);
x0=Ima1info.ImagePositionPatient(1);
y0=Ima1info.ImagePositionPatient(2);
z0=Ima1info.ImagePositionPatient(3);
op=Ima1info.ImageOrientationPatient;
dimpix=Ima1info.PixelSpacing;


%% Compute the 3D coordinates of the control points %%
    
CG=zeros(size(PC,1),3);    
    for i=1:size(PC,1)
    
        CG(i,1)=x0+(PC(i,1)-1)*dimpix(1)*op(1)+(PC(i,2)-1)*dimpix(2)*op(4);
        CG(i,2)=y0+(PC(i,1)-1)*dimpix(1)*op(2)+(PC(i,2)-1)*dimpix(2)*op(5);
        CG(i,3)=z0+(PC(i,1)-1)*dimpix(1)*op(3)+(PC(i,2)-1)*dimpix(2)*op(6);
        
    end

    
%% Compute the 2D theoretical sight of control points %% 

Cth=[];
M1=zeros(1,3);

    %% Building order similar to sorted detected control points : rising up the lines then the columns
    %% Match theoretical upon detected control points already done %%
  
    for i=1:11           
        for k=1:11
            if (i==2) || (i==10)
                if (k>2) && (k<10)
                    M1 = [x0 16*(k-1) 16*(i-1)];
                    Cth = [Cth ; M1];
                end
            elseif (i==3) || (i==4) || (i==8) || (i==9)
                if (k>1) && (k<11)
                    M1 = [x0 16*(k-1) 16*(i-1)];
                    Cth = [Cth ; M1];
                end
            elseif (i==1) || (i==11)
                if (k>4) && (k<8)
                    M1 = [x0 16*(k-1) 16*(i-1)];
                    Cth = [Cth ; M1];
                end
            elseif (i==6)
                if (k~=6)
                    M1 = [x0 16*(k-1) 16*(i-1)];
                    Cth = [Cth ; M1];
                end
            else
                    M1 = [x0 16*(k-1) 16*(i-1)];
                    Cth = [Cth ; M1];
            end
        end
    end

% figure(16)
% hold on 
% plot3(Cth(:,1),Cth(:,2),Cth(:,3),'.');
% plot3(CG(:,1),CG(:,2),CG(:,3),'.g');
% xlabel('x');
% ylabel('y');
% zlabel('z');
% hold off


%% Register theoretical onto detected control points : Iterative Closest Point %%

[R,q,dep,Pf,error]=Transformation(Cth,CG);
figure(17)
title('Theoretical control points (blue) registered on detected control points (green) in 3D space','FontSize',12,'FontWeight','bold');
hold on
plot3(Pf(:,1),Pf(:,2),Pf(:,3),'.');
plot3(CG(:,1),CG(:,2),CG(:,3),'.g');
xlabel('X');
ylabel('Y');
zlabel('Z');
ScrSize = get(0,'ScreenSize');
set(gcf,'Units','pixels','Position',ScrSize);
hold off