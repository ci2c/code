function t2 = T2starfit()


Vmagn=spm_vol('/home/fatmike/aurelien/SLA/temoin01/3dt2ge.nii');
magn=spm_read_vols(Vmagn);
magn=squeeze(magn);
magn=reshape(magn, size(magn,1).*size(magn,2).*size(magn,3),size(magn,4));

mask=magn(:,1) > 0.1*max(magn(:));
masked=magn(mask~=0,:);
X=[5:8:50];

size(masked)

X=repmat(X,size(masked,1),1);
% Initialize the coefficients of the function.
%X0=[1.6e+6 30];
%X0 = repmat(X0, size(masked,1), 1);
temp=repmat(masked(:,1),1,6);
dnorm=masked./temp;
s.StartPoint=[1 30]
data=[];
erreur=[];
step=1000;
tic
    if size(masked,1) > step
        vector=1:step:size(masked,1);
        for i=1:length(vector)-1
            [x, resnorm]=lsqnonlin(@(x) fonction_t2(x, X(vector(i):vector(i+1)-1,:), masked(vector(i):vector(i+1)-1,:)), X0(vector(i):vector(i+1)-1,:),[],[],options);
            data=[data;x];
            erreur=[erreur resnorm];
        end
            [x, resnorm]=lsqnonlin(@(x) fonction_t2(x, X(vector(end):end,:), masked(vector(end):end,:)), X0(vector(end):end,:),[],[],options);
            data=[data;x];
            erreur=[erreur resnorm];
    else
        [x, resnorm]=lsqnonlin(@(x) fonction_t2(x, X, masked), X0,[],[],options);
        data = x;
    end
 toc
 t2=zeros(size(magn,1),size(magn,2));
 t2(mask~=0)=data(:,2);
 
 %t1=zeros(size(magn,1), size(magn,2));
 %m0=zeros(size(magn,1), size(magn,2)); 