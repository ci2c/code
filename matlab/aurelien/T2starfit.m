function T2star=T2starfit()

Vmagn=spm_vol('/home/fatmike/aurelien/SLA/temoin01/3dt2ge.nii');
magn=spm_read_vols(Vmagn);
magn=squeeze(magn);
magn=reshape(magn, size(magn,1).*size(magn,2).*size(magn,3),size(magn,4));

mask=magn(:,1) > 0.1*max(magn(:));
masked=magn(mask~=0,:);
TE=[7.5:8:50];

% Initialize the coefficients of the function.
temp=repmat(masked(:,1),1,6);
dnorm=masked./temp;
s=fitoptions('Method','NonlinearLeastSquares', ...
    'StartPoint',[1 30], ...
    'MaxIter',1000, ...
    'MaxFunEvals',1000, ...
    'Lower',5,...
    'Upper',200,...
    'Algorithm','trust-region');

f=fittype('A.*exp(-x./T2)','problem','T2','options',s);
T2star=zeros(size(masked,1),1);
matlabpool open 6
tic
   parfor i=1:size(masked,1)
       dline=squeeze(dnorm(i,:));
       f1=fit(TE',dline',f);
       T2star(i)=f1.T2;
   end
 toc
 
 matlabpool close
