function savetemplate(init,F_left_norm, F_right_norm, feature, blur, flair)
%
% usage : function savetemplate(F_left_norm, F_right_norm, feature, blur, flair)
% 
%
% save template into init.temp_dir
% 
%
% is used by normalizationcontrol.m
%
% Inputs :
%       F_left_norm             : feature matrix normalized for Control data - left hemisphere
%       F_right_norm            : feature matrix normalized for Control data - right hemisphere
%       feature                 : feature studied 
%       blur                    : if blur exists -> its value
%       flair                   : 0 if feature concerned T1 or tep, 1 if it is for FLAIR
%  
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012
%%

lh_temp=mean(F_left_norm,1);
rh_temp=mean(F_right_norm,1);

if flair == 0
    
    if blur == 0
        
        % Writing file      

        SurfStatWriteData(strcat(init.temp_dir,'/normalization/lh.temp.fsaverage.',feature),lh_temp,'b');
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/rh.temp.fsaverage.',feature),rh_temp,'b');
        
    else
                
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/lh.fwhm',num2str(blur),'.temp.fsaverage.',feature),lh_temp,'b');
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/rh.fwhm',num2str(blur),'.temp.fsaverage.',feature),rh_temp,'b');
        
    end
    
elseif flair == 1
    
    if blur == 0
        
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/lh.flair_nuc.temp.fsaverage.',feature),lh_temp,'b');
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/rh.flair_nuc.temp.fsaverage.',feature),rh_temp,'b');
        
    else
        
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/lh.fwhm',num2str(blur),'.flair_nuc.temp.fsaverage.',feature),lh_temp,'b');
        SurfStatWriteData(strcat(init.temp_dir,'/normalization/rh.fwhm',num2str(blur),'.flair_nuc.temp.fsaverage.',feature),rh_temp,'b');
        
    end
    
end


