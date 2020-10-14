function car = TTPmap(vol,name)

%Create time to peak map from contrast enhanced perfusion series
% vol : nii file
% name : export name for the carto : eg 'test.nii'
% carto

%%
V=spm_vol(vol);
Y=spm_read_vols(V);
%%
dimx=size(Y,1);
dimy=size(Y,2);
dimz=size(Y,3);
ref=Y(:,:,:,1);

mask=ref > max(ref(:))*0.001;
se = strel('disk',5);
I2 = imdilate(mask,se);
I2 = imerode(I2,se);
dim2=size(Y,4);
dim3=size(Y,1)*size(Y,2)*size(Y,3);
I2=reshape(I2,dim3,1);
Y2=reshape(Y,dim3,dim2);
imamask=Y(I2~=0,:);
% dynres=reshape(I2,dim3,1);
% B=vol(dynres == 1,:);
% ttp_carto=zeros(size(B,1),1);
rspline=spline(1:size(Y2,2),Y2,0.3:0.01:1.7);
[testmin indx]=max(rspline,[],2);
carto=zeros(dimx,dimy,dimz);
carto(I2~=0)=indx;
V(1).fname=name;
car=spm_write_vol(V(1),carto);
%%
% progressbar
% 
% for j = 1:size(B,1)
%         row=B(j,:);
%         rowsmooth=smooth(row,0.3,'rloess');
%         rowspline=spline(1:length(rowsmooth),rowsmooth(:,1));
%         myfunc=@(x)ppval(rowspline,x);
%         [xx fval]=fminsearch(myfunc,15,optimset('TolX',1e-8));
%         ttp_carto(j)=xx;
%         progressbar( j/size(B,1) );  
% end

