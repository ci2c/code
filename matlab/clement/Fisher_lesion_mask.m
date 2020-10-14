% liste=dir('/NAS/tupac/protocoles/Strokdem/Lesions/72H/');
% s1='/NAS/tupac/protocoles/Strokdem/Lesions/72H/';
% s2='_lesions_mni152.nii';
% 
% mask=[];
% 
% %% Voxel matrices loading
% 
% 
% for i=1:length(liste)
% 
%     pos=strfind(char(liste(i).name),'_');
%     subjid=char(liste(i).name);
%     
%     file=fullfile(s1,liste(i).name,[subjid(1:pos-1) s2]);   
%     
%     if exist(file,'file')
%         nii=load_untouch_nii(file);
%         siz=size(nii.img(:));
%     
%         mask=[mask;reshape(nii.img,1,siz(1))];
%             
%     end
% end
%         

%% Fisher test
vox_sum=sum(mask,1);
ID=find(vox_sum ~= 0);
for i=1:length(ID) 
    x=mask(:,ID(i));
    le=length(find(x ==1));
    [p,~]=chi2test([le,length(x)-le;length(x)-le,length(x)-(length(x)-le)]);
    if le > length(x)-le
       result(i,1)=p;
    end
end
