function z=asl_svd(vol,mask,outname)

% PCA sur données ASL
% Usage : asl_svd(vol,mask)
% Suppression des composantes dues au bruit
% vol : volume asl nii
% mask : mask nii

if nargin==1
    mask=[];
end

if ~isempty(mask)
    Vmask = spm_vol(mask);
    data_mask = spm_read_vols(Vmask);
end

maskr = reshape(data_mask,size(data_mask,1).*size(data_mask,2).*size(data_mask,3),1);

VV = spm_vol(vol);
data = spm_read_vols(VV);
hdr=niak_read_hdr_nifti(vol);
rdata = reshape(data,size(data,1)*size(data,2)*size(data,3),size(data,4));

[U S V] = svd(rdata(maskr~=0,:),'econ');
%[U S V] = svd(rdata,'econ');

Sdenoise = S;
Sdenoise(:,20:end) = 0;
Vdenoise = V;
Vdenoise(:,20:end) = 0;

datacor = U*Sdenoise*Vdenoise';
z=zeros(size(data,1)*size(data,2)*size(data,3),size(data,4));
z(maskr~=0,:)=datacor;
%z=datacor;
z=reshape(z,size(data,1),size(data,2),size(data,3),size(data,4));

hdr.file_name=outname;
niak_write_nifti(hdr,z);