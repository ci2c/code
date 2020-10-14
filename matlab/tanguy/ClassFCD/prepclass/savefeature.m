function savefeature(init, F_left_norm, F_right_norm, feature, blur, flair)

%
% usage : function savefeature(L, F_left_norm, F_right_norm, feature, blur, flair)
% 
% save normalized data into init.pat_SD/patient/epilepsy
% 
%
%
%is used by normalizationcontrol.m
%
% Inputs :
%       F_left_norm             : feature matrix normalized - left hemisphere
%       F_right_norm            : feature matrix normalized - right hemisphere
%       feature                 : feature studied 
%       blur                    : if blur exists -> its value
%       flair                   : 0 if feature concerned T1 or tep, 1 if it is for FLAIR
%  
% 
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012
%%

for i = 1 : size(init.cont, 2)
    
    name = init.cont{i}(:)';
    lh_pat=F_left_norm(i,:);
    rh_pat=F_right_norm(i,:);
    
    if flair == 0
        
        if blur == 0
            
            % Writing file
            
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/lh.norm.fsaverage.',feature),lh_pat,'b');
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/rh.norm.fsaverage.',feature),rh_pat,'b');
            
        else

            
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/lh.fwhm',num2str(blur),'.norm.fsaverage.',feature),lh_pat,'b');
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/rh.fwhm',num2str(blur),'.norm.fsaverage.',feature),rh_pat,'b');
            
        end
        
    elseif flair == 1
        
        if blur == 0
            
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/lh.flair_nuc.norm.fsaverage.',feature),lh_pat,'b');
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/rh.flair_nuc.norm.fsaverage.',feature),rh_pat,'b');
            
        else
            
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/lh.fwhm',num2str(blur),'.flair_nuc.norm.fsaverage.',feature),lh_pat,'b');
            SurfStatWriteData(strcat(init.cont_SD,'/',name,'/epilepsy/rh.fwhm',num2str(blur),'.flair_nuc.norm.fsaverage.',feature),rh_pat,'b');
            
        end
        
    end
    
    
end