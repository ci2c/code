Direc=uigetdir('','Sélectionner le répertoire contenant les données despot');

f = dir(Direc);
cd(Direc);
for i=1:length(f);
    if ~f(i).isdir 
         eval(['mri' num2str(i) '=MRIread(f(i).name)']);
    end
end

FA=[5,11,15,18];
volt=cat(3,mri3.vol,mri4.vol,mri5.vol,mri6.vol);
FArad=FA.*pi./180;
taillevol=size(mri3.vol);
TR=0.0112;
t1map=zeros(taillevol(1),taillevol(2),taillevol(3));
M0map=zeros(taillevol(1),taillevol(2),taillevol(3));

for i = 1:taillevol(1),
     for j = 1:taillevol(2),
         for   k = 1:taillevol(3),
        row=(squeeze(volt(i,j,k:60:end)));
        row=row./1e+6;
        X=row'./tan(FArad);
        Y=row'./sin(FArad);  
        % Initialize the coefficients of the function.
        X0=[4 1]';

        % Set an options file for LSQNONLIN to use the
        % medium-scale algorithm 
        options = optimset('MaxFunEvals', 5000);


        % Calculate the new coefficients using LSQNONLIN.
%         x=lsqnonlin(@EvalError,X0,[],[],options,X,Y);
        [p,ErrorEst] = polyfit(X,Y,1);
        t1map(i,j,k)=-(TR)./log(p(1));
        M0map(i,j,k)=p(2).*1e+6;
        
          end
    end
end

mri1.vol=t1map;
MRIwrite(mri1,'carto.nii','float');