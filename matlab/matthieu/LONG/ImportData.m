% Import data
xlsfile='COMAJ_LONG.xls';
txtfile='/home/matthieu/NAS/matthieu/COMAJ_FS/Hypocampus_volume.txt';

% read and clean up xls file
[NUMERIC,TXT,RAW]=xlsread(xlsfile);
HypVol=load(txtfile);

subj_list_raw    = RAW(:,2);
subj_gender_raw  = RAW(:,4);
subj_dob_raw     = RAW(:,5);
subj_s1_date_raw = RAW(:,6);
subj_s2_date_raw = RAW(:,7);
subj_s3_date_raw = RAW(:,8);
subj_group_raw   = RAW(:,9);
subj_lhyp_vol = HypVol(:,1);
subj_rhyp_vol = HypVol(:,2);

To_discard = [];
for i = 1 : length(subj_list_raw)
    if isnan(subj_list_raw{i})
        To_discard = [To_discard; i];
    end
end

subj_list_raw(To_discard)    = [];
subj_gender_raw(To_discard)  = [];
subj_dob_raw(To_discard)     = [];
subj_s1_date_raw(To_discard) = [];
subj_s2_date_raw(To_discard) = [];
subj_s3_date_raw(To_discard) = [];
subj_group_raw(To_discard)   = [];

subj_list             = subj_list_raw;
subj_group            = subj_group_raw;
subj_age              = [];
subj_gender           = subj_gender_raw;
subj_acquisition_date = [];

for i = 1 : length(subj_list_raw)
%     Temp = subj_list_raw{i};
%     subj_list = [subj_list; Temp(end-1:end)];
    
    if strcmp(subj_s1_date_raw{i}, 'NA') == 1
        T1 = 0;
    else
        T1 = ( datenum(subj_s1_date_raw{i}) - datenum(subj_dob_raw{i}) - 1) / 365;
        subj_acquisition_date = [subj_acquisition_date; datenum(subj_s1_date_raw{i})];
    end
    
    if strcmp(subj_s2_date_raw{i}, 'NA') == 1
        T2 = 0;
    else
        T2 = ( datenum(subj_s2_date_raw{i}) - datenum(subj_dob_raw{i}) - 1) / 365;
        subj_acquisition_date = [subj_acquisition_date; datenum(subj_s2_date_raw{i})];
    end
    
    if strcmp(subj_s3_date_raw{i}, 'NA') == 1
        T3 = 0;
    else
        T3 = ( datenum(subj_s3_date_raw{i}) - datenum(subj_dob_raw{i}) - 1) / 365;
        subj_acquisition_date = [subj_acquisition_date; datenum(subj_s3_date_raw{i})];
    end
    
    subj_age = [subj_age; T1 T2 T3];
end

clear subj_list_raw subj_group_raw subj_gender_raw subj_age_raw;

% load cortical thickness file
thickness_lh_table   = [];
thickness_rh_table   = [];
subj_list_table      = {};
subj_group_table     = [];
subj_age_table       = [];
subj_gender_table    = [];
session_table        = [];

for i = 1 : size(subj_list, 1)
    
    if subj_age(i,1) ~= 0
        path_lh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session1.subj', subj_list{i,1}, '.lh.thickness.fwhm20.fsaverage.mgh');
        path_rh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session1.subj', subj_list{i,1}, '.rh.thickness.fwhm20.fsaverage.mgh');
        try
            thickness_lh_table = [thickness_lh_table; SurfStatReadData(path_lh)];
            thickness_rh_table = [thickness_rh_table; SurfStatReadData(path_rh)];
        catch
            error(['cannot open session 1 of subj', subj_list{i,1}]);
        end
        session_table = [session_table; 1];
        subj_list_table = cat(1, subj_list_table, subj_list(i, :));
        subj_group_table = [subj_group_table; subj_group(i)];
        subj_age_table = [subj_age_table; subj_age(i,1)];
        subj_gender_table = [subj_gender_table; subj_gender(i)];
    end
        
    if subj_age(i, 2) ~= 0
        path_lh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session2.subj', subj_list{i,1}, '.lh.thickness.fwhm20.fsaverage.mgh');
        path_rh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session2.subj', subj_list{i,1}, '.rh.thickness.fwhm20.fsaverage.mgh');
        try
            thickness_lh_table = [thickness_lh_table; SurfStatReadData(path_lh)];
            thickness_rh_table = [thickness_rh_table; SurfStatReadData(path_rh)];
        catch
            error(['cannot open session 2 of subj', subj_list{i,1}]);
        end
        session_table = [session_table; 2];
        subj_list_table = cat(1, subj_list_table, subj_list(i, :));
        subj_group_table = [subj_group_table; subj_group(i)];
        subj_age_table = [subj_age_table; subj_age(i,2)];
        subj_gender_table = [subj_gender_table; subj_gender(i)];
    end
                
    if subj_age(i, 3) ~= 0
        path_lh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session3.subj', subj_list{i,1}, '.lh.thickness.fwhm20.fsaverage.mgh');
        path_rh = strcat('/home/matthieu/NAS/matthieu/COMAJ_FS/cortical_thickness/session3.subj', subj_list{i,1}, '.rh.thickness.fwhm20.fsaverage.mgh');
        try
            thickness_lh_table = [thickness_lh_table; SurfStatReadData(path_lh)];
            thickness_rh_table = [thickness_rh_table; SurfStatReadData(path_rh)];
        catch
            error(['cannot open session 3 of subj', subj_list{i,1}]);
        end
        session_table = [session_table; 3];
        subj_list_table = cat(1, subj_list_table, subj_list(i, :));
        subj_group_table = [subj_group_table; subj_group(i)];
        subj_age_table = [subj_age_table; subj_age(i,3)];
        subj_gender_table = [subj_gender_table; subj_gender(i)];
    end
end

% Inter-scan Interval
LL = length(subj_age_table);
interscan_interval = zeros(LL, 1);
interscan_interval(1) = 0;
Ref = 1;
for i = 2 : LL
    if strcmp(subj_list_table(Ref), subj_list_table(i)) == 1
        interscan_interval(i) = subj_age_table(i) - subj_age_table(Ref);
    else
        Ref = i;
        interscan_interval(i) = 0;
    end
end


% Load Surfaces and mask
Surf = SurfStatReadSurf([{'/home/global/freesurfer/subjects/fsaverage/surf/lh.white'}, {'/home/global/freesurfer/subjects/fsaverage/surf/rh.white'}]);
load /home/matthieu/SVN/matlab/matthieu/LONG/mask.mat
Mask = ~Mask; % Mask == 1 at vertices to include, Mask == 0 at vertices to exclude

mask_lh = Mask(1:size(thickness_lh_table, 2));
mask_rh = Mask(size(thickness_lh_table, 2)+1:end);

thickness_lh_table(:,mask_lh==0) = 0;
thickness_rh_table(:,mask_rh==0) = 0;

% % Clear singleton
% is_alone = (strcmp(subj_list_table, circshift(subj_list_table, 1)) + strcmp(subj_list_table, circshift(subj_list_table, -1))) == 0;
% subj_list_table(is_alone) = [];
% subj_group_table(is_alone) = [];
% subj_age_table(is_alone) = [];
% subj_gender_table(is_alone) = [];
% interscan_interval(is_alone) = [];
% thickness_lh_table(is_alone, :) = [];
% thickness_rh_table(is_alone, :) = [];