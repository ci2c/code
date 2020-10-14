function [t1, m0,erreur] = T1_map_fast()


Vmagn=spm_vol('/home/fatmike/aurelien/ASL/multi-TI/test_multiphase/fantome/t1map/magn.nii');
magn=spm_read_vols(Vmagn);
magn=squeeze(magn);
magn=reshape(magn, size(magn,1).*size(magn,2),size(magn,3));

mask=magn(:,1) > 0.05*max(magn(:));
masked=magn(mask~=0,:);
X=[0.05 0.1 0.2 0.3 0.5 1 1.5];
masked(:,1:4)=-masked(:,1:4);

size(masked)

X=repmat(X,size(masked,1),1);
% Initialize the coefficients of the function.
X0=[1.6e+6 0.5];
X0 = repmat(X0, size(masked,1), 1);

options = optimset('MaxFunEvals', 20000);
options.MaxIter = 50000;
options.TolFun=1e-10;
options.TolX=1e-10;

data=[];
erreur=[];
step=500;
tic
    if size(masked,1) > step
        vector=1:step:size(masked,1);
        for i=1:length(vector)-1
            [x, resnorm]=lsqnonlin(@(x) fonction_exp(x, X(vector(i):vector(i+1)-1,:), masked(vector(i):vector(i+1)-1,:)), X0(vector(i):vector(i+1)-1,:),[],[],options);
            data=[data;x];
            erreur=[erreur resnorm];
        end
            [x, resnorm]=lsqnonlin(@(x) fonction_exp(x, X(vector(end):end,:), masked(vector(end):end,:)), X0(vector(end):end,:),[],[],options);
            data=[data;x];
            erreur=[erreur resnorm];
    else
        [x, resnorm]=lsqnonlin(@(x) fonction_exp(x, X, masked), X0,[],[],options);
        data = x;
        erreur = resnorm;
    end
 toc
 t1=zeros(size(magn,1),size(magn,2));
 m0=zeros(size(magn,1),size(magn,2));
 m0(mask~=0)=data(:,1);
 t1(mask~=0)=data(:,2);
 
 %t1=zeros(size(magn,1), size(magn,2));
 %m0=zeros(size(magn,1), size(magn,2)); 