function im2min_ip(im,nbcoupes,direction)

% im='/home/tanguy/NAS/tanguy/SWAN/TESTS/poret/mr/images/swan.nii'
% nbcoupes=5;
% direction='axial'

% MIN IP COMPUTE
%%
% paramètres

if ~exist(im)
    warning(['canot found image : ' im]);
else
    seq=im;
end

dir=lower(direction);



%%
% charge volume

V=spm_vol(seq);
init_raw=spm_read_vols(V);
[a,b,c]=size(init_raw);



V_min_ip=V;
V_min_ip_dim=V;
name_init_raw=V.fname;
f=find(name_init_raw=='.');
if isempty(f)
    warning('canot read image extension')
else
    name_point=f(end);
end

%% On applique le masque au volume afin de ne garder que l'information

% sl=find(V.fname=='/');
% mask_path=[V.fname(1:sl(end-1)) 'brain_mask_patient/mask_swan.nii'];
% V_mask=spm_vol(mask_path);
% brain_mask=spm_read_vols(V_mask);
%
% init=init_raw.*brain_mask;
% init(init==0)=1.01*max(init(:));


init=init_raw;

%%
% Calcul volume min_ip
switch dir
    case 'axial'
        disp('compute Axial min_ip')
        im_out=zeros(a,b,floor(c/nbcoupes)+1);
        im_out_dim=zeros(a,b,c);
        for i = 1 : nbcoupes : c-nbcoupes+1
            disp(i)
            slice=init(:,:,i:i+nbcoupes-1);
            min_slice=min(slice,[],3);
            clear new_slice
            new_slice=min_slice;
            im_out(:,:,(i+nbcoupes-1)/nbcoupes)=new_slice;
            im_out_dim(:,:,i:i+nbcoupes-1)=repmat(new_slice,[1 1 nbcoupes]);
            m=i;
        end
        
        if (m+nbcoupes-1)~=c
            nb_last_slice=c-(m+nbcoupes-1);
            last_slice=init(:,:,m+nbcoupes:end);
            min_slice=min(last_slice,[],3);
            clear new_slice
            new_slice=min_slice;
            im_out(:,:,end)=new_slice;
            im_out_dim(:,:,m+nbcoupes:end)=repmat(new_slice,[1 1 nb_last_slice]);            
        end
        
        % header
        
        c=find(name_init_raw=='.');
        V_min_ip.fname=[name_init_raw(1:name_point-1),'_Ax_min_ip_',num2str(nbcoupes),'.nii'];
        V_min_ip.dim=size(im_out);
        V_min_ip.mat(3,3)=V_min_ip.mat(3,3)*nbcoupes;
        
        V_min_ip_dim.fname=[name_init_raw(1:name_point-1),'_Ax_min_ip_dim_',num2str(nbcoupes),'.nii'];
        
        %
        %
        %     case 'sagittal'
        %         disp('compute Sagittal min_ip')
        %
        %         for i = 1 : nbcoupes : a-nbcoupes
        %             disp(i)
        %             slice=init(i:i+nbcoupes-1,:,:);
        %             min_slice=zeros(b,c);
        %             min_slice=min(slice,[],1);
        %             clear new_slice
        %             new_slice=min_slice;
        %             for k = 1 : nbcoupes-1
        %                 new_slice=cat(1,new_slice,min_slice);
        %             end
        %             im_out(i:i+nbcoupes-1,:,:)=new_slice;
        %             m=i;
        %         end
        %
        %         if (m+nbcoupes-1)~=a
        %             nb_last_slice=a-(m+nbcoupes-1);
        %             last_slice=init(m+nbcoupes:end,:,:);
        %             min_slice=min(last_slice,[],1);
        %             clear new_slice
        %             new_slice=min_slice;
        %             for k = 1 : nb_last_slice-1
        %                 new_slice=cat(1,new_slice,min_slice);
        %             end
        %             im_out(m+nbcoupes:b,:,:)=new_slice;
        %         end
        %
        %         % header
        %
        %
        %         V_min_ip.fname=[name_init(1:name_point-1),'_Sag_min_ip_',num2str(nbcoupes),'.nii'];
        %
        %
        %     case 'coronal'
        %
        %         disp('compute coronal min_ip')
        %
        %         for i = 1 : nbcoupes : b-nbcoupes
        %             disp(i)
        %             slice=init(:,i:i+nbcoupes-1,:);
        %             min_slice=zeros(a,c);
        %             min_slice=min(slice,[],2);
        %             clear new_slice
        %             new_slice=min_slice;
        %             for k = 1 : nbcoupes-1
        %                 new_slice=cat(2,new_slice,min_slice);
        %             end
        %             im_out(:,i:i+nbcoupes-1,:)=new_slice;
        %             m=i;
        %         end
        %
        %         if (m+nbcoupes-1)~=b
        %             nb_last_slice=b-(m+nbcoupes-1);
        %             last_slice=init(:,m+nbcoupes:end,:);
        %             min_slice=min(last_slice,[],2);
        %             clear new_slice
        %             new_slice=min_slice;
        %             for k = 1 : nb_last_slice-1
        %                 new_slice=cat(2,new_slice,min_slice);
        %             end
        %             im_out(:,m+nbcoupes:b,:)=new_slice;
        %         end
        %
        %         % header
        %
        %         V_min_ip.fname=[name_init(1:name_point-1),'_Cor_min_ip_',num2str(nbcoupes),'.nii'];
        
    otherwise
        
        warning('canot read direction')
        warning('direction has to be axial, coronal or sagittal')
end

%%
% Enregistrement volume

spm_write_vol(V_min_ip,im_out);
spm_write_vol(V_min_ip_dim,im_out_dim);


