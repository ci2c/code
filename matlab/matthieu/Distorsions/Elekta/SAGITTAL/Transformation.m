function [R,q,dep,Pf,error]=Transformation(P,X)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P est une matrice 3xm de points à recaler
% X est une matrice 3xn de points cibles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P=P';
X=X';
P0=P;
q0=[1;0;0;0;0;0;0];     % vecteur de recalage initial


%Centrage initial des centres de gravités

moyx0=mean(X,2);
moyp0=mean(P0,2);
dep=moyx0-moyp0;
P0=[P0(1,:)+dep(1);P0(2,:)+dep(2);P0(3,:)+dep(3)];


% Calcul de la transformation


    
    [R,q,er]=recalage(P0,X);    %Calcul du recalage
    error=er;
    for i=1:size(P0,2)          %Calcul des points recalés                
        Q(:,i)=R*P0(:,i)+q(5:7);
    end
    Pf=Q';                     

%--------------------------------------------------------------------------
function [R,q,er]=recalage(P,X)

% Calcul des centres de gravités de l'ensemble des points mesurés et
% théorique en correspondance

    moyp=mean(P,2);
    moyx=mean(X,2);
    
% Calcul des matrices d'inter-covariance entre les points P et Y

cvpx=0;
for i=1:size(P,2)
    cvpx=cvpx+P(:,i)*X(:,i)';
end
cvpx=1/size(P,2)*cvpx-moyp*moyx';
cvas=cvpx-cvpx';
delta=[cvas(2,3) cvas(3,1) cvas(1,2)]';
    
% Calcul de la matrice 4x4 antisym Q

    Q=[trace(cvpx) delta'; delta cvpx+cvpx'-trace(cvpx)*eye(3)];
    
% Calcul de la rotation optimale : vecteur propre de Q dont la valeur propre est
% maximale

    [V,D] = eig(Q);
    [C,J]=max(max(D));
    qr=V(:,J);
    if qr(1)<0
        qr=-qr;
    end
    
% Calcul du vecteur de translation optimal
    R=rot(qr);
    qt=moyx-R*moyp;
    
% Nouveau vecteur de recalage : rotation+translation
    q=[qr;qt];
    
% Calcul de l'erreur des moindres carrés
    
    W=R*P;
    er=0;
    for i=1:size(P,2)
            
            er=er+sqrt((X(1,i)-W(1,i)-qt(1))^2+(X(2,i)-W(2,i)-qt(2))^2+(X(3,i)-W(3,i)-qt(3))^2);                      
    end
    er=1/size(P,2)*er;
%--------------------------------------------------------------------------
function R=rot(x)

R=[x(1)^2+x(2)^2-x(3)^2-x(4)^2 2*(x(2)*x(3)-x(1)*x(4)) 2*(x(2)*x(4)+x(1)*x(3))
   2*(x(2)*x(3)+x(1)*x(4)) x(1)^2-x(2)^2+x(3)^2-x(4)^2 2*(x(3)*x(4)-x(1)*x(2))
   2*(x(2)*x(4)-x(1)*x(3)) 2*(x(3)*x(4)+x(1)*x(2))  x(1)^2-x(2)^2-x(3)^2+x(4)^2];