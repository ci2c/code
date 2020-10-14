function rpxy=partcorr(corrmat)

%Francisco Rodrigues Pinto, Lisboa, 2006
%function to compute all 3 pairwise partial correlation coefficients given
%the 3x3 matrix of correlation coefficients between the three variables x, y and z 

rpxy=zeros(3,3);
rpxy(1,2)=(corrmat(1,2)-corrmat(1,3)*corrmat(2,3))/(((1-corrmat(1,3)^2)*(1-corrmat(2,3)^2))^0.5);
rpxy(1,3)=(corrmat(1,3)-corrmat(1,2)*corrmat(2,3))/(((1-corrmat(1,2)^2)*(1-corrmat(2,3)^2))^0.5);
rpxy(2,3)=(corrmat(2,3)-corrmat(1,2)*corrmat(1,3))/(((1-corrmat(1,2)^2)*(1-corrmat(1,3)^2))^0.5);