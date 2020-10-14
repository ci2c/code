clear all;

V1=spm_vol('/home/fatmike/aurelien/perf_T1/prefa5.nii');
V2=spm_vol('/home/fatmike/aurelien/perf_T1/dynfa15.nii');

fa5=spm_read_vols(V1);
fa15=spm_read_vols(V2);
fa15=fa15(:,:,:,1);
fa5r=reshape(fa5, 192*192*47,1);
fa15r=reshape(fa15, 192*192*47,1);

mask=fa5(:,1) > 0.05*max(fa5(:));
masked=fa5(mask~=0,:);

FA=[5 15];
FArad=FA.*pi./180; %normaliser en radian
t1map=zeros(128,128);
M0map=zeros(128,128);
X0=[4 1]';
X0 = repmat(X0, size(masked,1), 1);
X=row./tan(FArad);
Y=row./sin(FArad);
options = optimset('MaxFunEvals', 20000);
options.MaxIter = 50000;
options.TolFun=1e-10;
options.TolX=1e-10;


    
        Ltan=fa5./tan((5/180)*pi);
        Htan=fa15./tan((15/180)*pi);
        Lsin=fa5./sin((5/180)*pi);
        Hsin=fa15./sin((15/180)*pi);
        Vm=(Lsin-Hsin)./(Ltan-Htan);
        T1map=-0.0062./reallog(abs(Vm));
        % Calculate the new coefficients using LSQNONLIN.
%         x=lsqnonlin(@EvalError,X0,[],[],options,X,Y);
        [p,ErrorEst] = polyfit(X,Y,1);
%         Sfitted = polyval(p,X,ErrorEst);
         t1map(i,j)=-(TR./1000)./log(p(1));
         M0map(i,j)=p(2).*1e+6;
        


subplot(1,2,1);imagesc(t1map,[0 1]);
subplot(1,2,2);imagesc(M0map);