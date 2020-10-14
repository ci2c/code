function zscorepatient(SD, ref, init)

%
%
% compute zscore for patients ref
%
%
% usage : zscorepatient(SD, ref, init)
%
% Inputs :
%       SD : Subjects_Dir : folder containing data
%       ref : name of patient or controle to normalize
%       init : structure generated by initvar.m and generate_variables.m
%              patient list and other variables must be changed into these
%              scripts.
%       
%
%
%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012


%%
% For Automatic Detection of Focal Cortical Dysplasia
% Tanguy Hamel @ CHRU Lille, 2012

%%


zscoretemplate = strcat(init.temp_dir,'/zscore');


%Normalisation of T1 & PET

for k=1:size(init.features,2)
    
    %Normalization of not blured data
   
    
    disp(strcat(zscoretemplate,'/lh.mean.fsaverage.',init.features{k}))
    Mean_left = SurfStatReadData(strcat(zscoretemplate,'/lh.mean.fsaverage.',init.features{k}));
    Mean_right = SurfStatReadData(strcat(zscoretemplate,'/rh.mean.fsaverage.',init.features{k}));
    
    Std_left = SurfStatReadData(strcat(zscoretemplate,'/lh.std.fsaverage.',init.features{k}));
    Std_right = SurfStatReadData(strcat(zscoretemplate,'/rh.std.fsaverage.',init.features{k}));
    
    
    F_left = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/lh.norm.fsaverage.',init.features{k}));
    F_right = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/rh.norm.fsaverage.',init.features{k}));
    
    F_left_zscore = ( F_left - Mean_left) ./ Std_left ;
    F_right_zscore = (F_right - Mean_right) ./ Std_right ;
    
    F_left_zscore(~isfinite(F_left_zscore))=0;
    F_right_zscore(~isfinite(F_right_zscore))=0;
    
    SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/lh.zscore.fsaverage.',init.features{k}),F_left_zscore,'b');
    SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/rh.zscore.fsaverage.',init.features{k}),F_right_zscore,'b');
    
    %Normalization for blur (blur values can be managed with initvar.m)
    
    
    for i = init.blur
        
        Mean_left = SurfStatReadData(strcat(zscoretemplate,'/lh.fwhm',num2str(i),'.mean.fsaverage.',init.features{k}));
        Mean_right = SurfStatReadData(strcat(zscoretemplate,'/rh.fwhm',num2str(i),'.mean.fsaverage.',init.features{k}));
        
        Std_left = SurfStatReadData(strcat(zscoretemplate,'/lh.fwhm',num2str(i),'.std.fsaverage.',init.features{k}));
        Std_right = SurfStatReadData(strcat(zscoretemplate,'/rh.fwhm',num2str(i),'.std.fsaverage.',init.features{k}));
        
        F_left = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/lh.fwhm',num2str(i),'.norm.fsaverage.',init.features{k}));
        F_right = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/rh.fwhm',num2str(i),'.norm.fsaverage.',init.features{k}));
        
        F_left_zscore = ( F_left - Mean_left) ./ Std_left ;
        F_right_zscore = (F_right - Mean_right) ./ Std_right ;
        
        F_left_zscore(~isfinite(F_left_zscore))=0;
        F_right_zscore(~isfinite(F_right_zscore))=0;
        
        SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/lh.fwhm',num2str(i),'.zscore.fsaverage.',init.features{k}),F_left_zscore,'b');
        SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/rh.fwhm',num2str(i),'.zscore.fsaverage.',init.features{k}),F_right_zscore,'b');
        
        
    end
    
end


%Normalisation of FLAIR

for k=1:size(init.features_flair,2)
    
    %Normalization of not blured data
    disp(strcat(zscoretemplate,'/lh.mean.fsaverage.',init.features_flair{k}))
    Mean_left = SurfStatReadData(strcat(zscoretemplate,'/lh.flair_nuc.mean.fsaverage.',init.features_flair{k}));
    Mean_right = SurfStatReadData(strcat(zscoretemplate,'/rh.flair_nuc.mean.fsaverage.',init.features_flair{k}));
    
    Std_left = SurfStatReadData(strcat(zscoretemplate,'/lh.flair_nuc.std.fsaverage.',init.features_flair{k}));
    Std_right = SurfStatReadData(strcat(zscoretemplate,'/rh.flair_nuc.std.fsaverage.',init.features_flair{k}));
    
    F_left = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/lh.flair_nuc.norm.fsaverage.',init.features_flair{k}));
    F_right = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/rh.flair_nuc.norm.fsaverage.',init.features_flair{k}));
    
    F_left_zscore = ( F_left - Mean_left) ./ Std_left ;
    F_right_zscore = (F_right - Mean_right) ./ Std_right ;
    
    F_left_zscore(~isfinite(F_left_zscore))=0;
    F_right_zscore(~isfinite(F_right_zscore))=0;
    
    SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/lh.flair_nuc.zscore.fsaverage.',init.features_flair{k}),F_left_zscore,'b');
    SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/rh.flair_nuc.zscore.fsaverage.',init.features_flair{k}),F_right_zscore,'b');
    
    %Normalization for blur (blur values can be managed with initvar.m)
    
    
    for i = init.blur
        
        Mean_left = SurfStatReadData(strcat(zscoretemplate,'/lh.fwhm',num2str(i),'.flair_nuc.mean.fsaverage.',init.features_flair{k}));
        Mean_right = SurfStatReadData(strcat(zscoretemplate,'/rh.fwhm',num2str(i),'.flair_nuc.mean.fsaverage.',init.features_flair{k}));
        
        Std_left = SurfStatReadData(strcat(zscoretemplate,'/lh.fwhm',num2str(i),'.flair_nuc.std.fsaverage.',init.features_flair{k}));
        Std_right = SurfStatReadData(strcat(zscoretemplate,'/rh.fwhm',num2str(i),'.flair_nuc.std.fsaverage.',init.features_flair{k}));
        
        F_left = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/lh.fwhm',num2str(i),'.flair_nuc.norm.fsaverage.',init.features_flair{k}));
        F_right = SurfStatReadData(strcat(SD,'/',ref,'/epilepsy/rh.fwhm',num2str(i),'.flair_nuc.norm.fsaverage.',init.features_flair{k}));
        
        F_left_zscore = ( F_left - Mean_left) ./ Std_left ;
        F_right_zscore = (F_right - Mean_right) ./ Std_right ;
        
        F_left_zscore(~isfinite(F_left_zscore))=0;
        F_right_zscore(~isfinite(F_right_zscore))=0;
        
        SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/lh.fwhm',num2str(i),'.flair_nuc.zscore.fsaverage.',init.features_flair{k}),F_left_zscore,'b');
        SurfStatWriteData(strcat(SD,'/',ref,'/epilepsy/rh.fwhm',num2str(i),'.flair_nuc.zscore.fsaverage.',init.features_flair{k}),F_right_zscore,'b');
        
        
    end
    
end