clear all; close all;

%% Import data from all recon and lh/rh
WD='/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD/Destrieux';
% recon = {'OT_i2s21_g2','OT_i6s21_g2','OT_i6s21_g2.4_EQ.PET','OT_i6s21_g2.9_Res','OT_i6s21_g3.1_EQ.PET_EARL',...
%     'OT_i6s21_g3.3','OT_i6s21_g3.5','OT_i6s21_g4','OT_i6s21_g5','UHD_i8s21_g2','UHD_i8s21_g2.5','UHD_i8s21_g3',...
%     'UHD_i8s21_g3.3_EQ.PET_EARL','UHD_i8s21_g3.5','UHD_i8s21_g4','UHD_i8s21_g4.5','UHD_i8s21_g5','UHD_i8s21_g6'};
recon = {'OT_i2s21_g2','UHD_i8s21_g4.5'};
PVC = {'noPVC', 'PVC'};

%% fsaverage
for j = 1:2
    lh_meanROI_ref = importdata(fullfile(WD,['lh.aparc.Destrieux.' PVC{j} '.gn.fsaverage.meanPet.' recon{1} '.table']));
    lh_meanROI_ref = lh_meanROI_ref.data(:,2:end);
    rh_meanROI_ref = importdata(fullfile(WD,['rh.aparc.Destrieux.' PVC{j} '.gn.fsaverage.meanPet.' recon{1} '.table']));
    rh_meanROI_ref = rh_meanROI_ref.data(:,2:end);
%     for k = 2:18
        k=2;
        lh_meanROI = importdata(fullfile(WD,['lh.aparc.Destrieux.' PVC{j} '.gn.fsaverage.meanPet.' recon{k} '.table']));
        lh_meanROI = lh_meanROI.data(:,2:end);
        rh_meanROI = importdata(fullfile(WD,['rh.aparc.Destrieux.' PVC{j} '.gn.fsaverage.meanPet.' recon{k} '.table']));
        rh_meanROI = rh_meanROI.data(:,2:end);
        
        lh_meanROI_SD = (lh_meanROI-lh_meanROI_ref).^2;
        rh_meanROI_SD = (rh_meanROI-rh_meanROI_ref).^2;
        
        lh_meanROI_SSD = sum(lh_meanROI_SD,2);
        rh_meanROI_SSD = sum(rh_meanROI_SD,2);
        
        save(fullfile(WD,['lh_meanROI_SSD_' PVC{j} '_' recon{k} '.mat']),'lh_meanROI_SSD','-v7.3');
        save(fullfile(WD,['rh_meanROI_SSD_' PVC{j} '_' recon{k} '.mat']),'rh_meanROI_SSD','-v7.3');
%     end
end

%% native
for j = 1:2
    lh_meanROI_ref = importdata(fullfile(WD,['lh.aparc.Destrieux.' PVC{j} '.gn.meanPet.' recon{1} '.table']));
    lh_meanROI_ref = lh_meanROI_ref.data(:,2:end);
    rh_meanROI_ref = importdata(fullfile(WD,['rh.aparc.Destrieux.' PVC{j} '.gn.meanPet.' recon{1} '.table']));
    rh_meanROI_ref = rh_meanROI_ref.data(:,2:end);
%     for k = 2:18
        k=2;
        lh_meanROI = importdata(fullfile(WD,['lh.aparc.Destrieux.' PVC{j} '.gn.meanPet.' recon{k} '.table']));
        lh_meanROI = lh_meanROI.data(:,2:end);
        rh_meanROI = importdata(fullfile(WD,['rh.aparc.Destrieux.' PVC{j} '.gn.meanPet.' recon{k} '.table']));
        rh_meanROI = rh_meanROI.data(:,2:end);
        
        lh_meanROI_SD = (lh_meanROI-lh_meanROI_ref).^2;
        rh_meanROI_SD = (rh_meanROI-rh_meanROI_ref).^2;
        
        lh_meanROI_SSD = sum(lh_meanROI_SD,2);
        rh_meanROI_SSD = sum(rh_meanROI_SD,2);
        
        save(fullfile(WD,['lh_meanROI_native_SSD_' PVC{j} '_' recon{k} '.mat']),'lh_meanROI_SSD','-v7.3');
        save(fullfile(WD,['rh_meanROI_native_SSD_' PVC{j} '_' recon{k} '.mat']),'rh_meanROI_SSD','-v7.3');
%     end
end
        