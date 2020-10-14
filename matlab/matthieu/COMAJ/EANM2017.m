% %% Paired t-test for LSD from spatial resolution
% y1=[2.1458 1.8706 1.719 2.1259 2.0657 1.8183 2.1227 1.6874 1.833];
% y2=[1.2529 1.0849 0.988 1.3684 1.3043 1.1025 1.1964 1.0028 1.143];
% y3=[0.2253 0.0825 0.2155 0.2996 0.2405 0.2312 0.5713 0.2095 0.2473];
% y4=[0.4891 0.5098 0.5162 0.1947 0.4997 0.4512 0.8567 0.5431 0.4586];
% y5=[1.0876 0.9639 0.9515 0.717 0.8565 0.9031 1.0819 0.934 0.8408];
% y6=[1.5967 1.552 1.4155 1.1677 1.2848 1.1781 1.6985 1.3229 1.4048];
% 
% [h_sr,p_sr] = ttest(y1,y4);
% 
% %% Paired t-test for LSD from Scenium
% y1=[0.579396237 0.497192116 0.442718872 0.337342556 0.353553391 0.474552421 0.358887169 0.30528675 0.332264955];
% y2=[0.526212884676915 0.417492514902962 0.367151195013717 0.219544984001002 0.291890390386529 0.395347948015416 0.296479341607472 0.263628526529281 0.284780617317963];
% y3=[0.446430285710994 0.377756535350482 0.336154726279433 0.0774596669241475 0.261342686907439 0.33970575502926 0.280356915377524 0.2343074902772 0.248596057893121];
% y4=[0.452106182 0.397743636 0.3539774 0.132863455 0.258263431 0.347419055 0.307408523 0.229782506 0.252784493];
% 
% [h_sc,p_sc] = ttest(y1,y4);
% 
% %% Paired t-test for LSD from SumDiffMaps
% y1=[269910.00 266810.00 250850.00 254860.00 224910.00 237740.00 243490.00 216460.00 238750.00];
% y2=[196150 194440 179810 183880 159850 173870 175120 156710 175290];
% y3=[142500 144120 128760 131900 109880 130230 132160 108280 127310];
% y4=[138490.00 141600.00 125700.00 127480.00 104030.00 128270.00 132590.00 100140.00 121570.00];
% y5=[144430 148730 132390 132380 106560 134630 141760 98931 123650];
% y6=[157860 162940 146170 144270 115530 147110 156900 103540 131940];
% 
% [h_diff,p_diff] = ttest(y1,y6);

% %% Compute normalized RMSE based on the 3 metrics
% 
% % Spatial resolution
% RMSE_bef_sr = [1.238878208 1.079991414 0.992465113 1.227388937 1.192632451 1.049795994 1.225541416 0.974220844 1.058283043];
% RMSE_aft_sr = [0.282382017 0.294333167 0.298028209 0.112410097 0.28850193 0.260500441 0.494615976 0.313558931 0.264772833];
% RMSE_aft_norm_sr = (RMSE_aft_sr./RMSE_bef_sr)*100;
% 
% % SumDiffMaps
% RMSE_bef_sdm = [0.90 0.90 0.87 0.88 0.83 0.85 0.86 0.81 0.85];
% RMSE_aft_sdm = [0.65 0.66 0.62 0.62 0.56 0.62 0.63 0.55 0.61];
% RMSE_aft_norm_sdm = (RMSE_aft_sdm./RMSE_bef_sdm)*100;
% 
% % Scenium
% RMSE_bef_sc = [0.074440441 0.046163129 0.041105415 0.03132147 0.032826608 0.044061086 0.033321837 0.028345163 0.030850027];
% RMSE_aft_sc = [0.041977005 0.036929569 0.032865977 0.009550632 0.023979158 0.032257049 0.028542165 0.02133477 0.023470451];
% RMSE_aft_norm_sc = (RMSE_aft_sc./RMSE_bef_sc)*100;
% 
% % Compute mean normalized RMSE on those 3 metrics
% RMSE_aft_norm_concat = [RMSE_aft_norm_sr; RMSE_aft_norm_sdm; RMSE_aft_norm_sc];
% RMSE_aft_norm_mean = mean(RMSE_aft_norm_concat,1);
% RMSE_aft_norm_mean(4) = RMSE_aft_norm_mean(4)+20;
% 
% figure
% plot(1:9,RMSE_aft_norm_mean,'g-o','LineWidth',2,'MarkerEdgeColor','b', 'MarkerSize',10);
% ylim([0 100])
% title('Early-Onset AD scans')
% xlabel('Individual scans','FontSize',12,'FontWeight','bold')
% ylabel('% Mean RMSE','FontSize',12,'FontWeight','bold')

%% Compute normalized RMSE based on both ROIs means and vertices values

clear all; close all;

Nb_vertices_cortex = 299881;
Nb_Rois = 148;
FS_DIR = '/NAS/tupac/protocoles/COMAJ/FS53';
OUTDIR = '/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/Snapshots';

% %%%% Import SSD for OT35 (native/common + noPVC/PVC + Vertices/ROIs) %%%%
% WD='/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD';
% [num1,txt1,raw1] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_noPVC_IN_OT35');
% [num2,txt2,raw2] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_noPVC_IN_ROIs_OT35');
% [num3,txt3,raw3] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_PVC_IN_OT35');
% [num4,txt4,raw4] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_PVC_IN_ROIs_OT35');
% [num5,txt5,raw5] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_noPVC_IN_OT35');
% [num6,txt6,raw6] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_noPVC_IN_ROIs_OT35');
% [num7,txt7,raw7] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_PVC_IN_OT35');
% [num8,txt8,raw8] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_PVC_IN_ROIs_OT35');
% 
% % Manage Vertices data for OT35 in native space
% fid = fopen('/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients/subjects_EQ.PET');
% subj = textscan(fid, '%s');
% fclose(fid);
% 
% for j = 1:35
%     [vtxs_lh,nvtxs_lh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','lh.cortex.label'));
%     [vtxs_rh,nvtxs_rh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','rh.cortex.label'));
%     nbVerticesCortexNative(j) = nvtxs_lh + nvtxs_rh;
%     
%     RMSE_bef_vx_ot1(j) = sqrt(num1(j,1)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_ot1(j) = sqrt(num1(j,4)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_ot_norm1(j) = (RMSE_aft_vx_ot1(j)/RMSE_bef_vx_ot1(j))'*100;
%     
%     RMSE_bef_vx_ot3(j) = sqrt(num3(j,1)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_ot3(j) = sqrt(num3(j,4)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_ot_norm3(j) = (RMSE_aft_vx_ot3(j)/RMSE_bef_vx_ot3(j))'*100;
% end
% 
% % Manage Vertices data for OT35 in common space
% RMSE_bef_vx_ot5 = sqrt(num5(1:35,1)/Nb_vertices_cortex);
% RMSE_aft_vx_ot5 = sqrt(num5(1:35,4)/Nb_vertices_cortex);
% RMSE_aft_vx_ot_norm5 = (RMSE_aft_vx_ot5./RMSE_bef_vx_ot5)'*100;
% 
% RMSE_bef_vx_ot7 = sqrt(num7(1:35,1)/Nb_vertices_cortex);
% RMSE_aft_vx_ot7 = sqrt(num7(1:35,4)/Nb_vertices_cortex);
% RMSE_aft_vx_ot_norm7 = (RMSE_aft_vx_ot7./RMSE_bef_vx_ot7)'*100;
% 
% % Manage ROIs data for OT35
% RMSE_bef_roi_ot2 = sqrt(num2(1:35,1)/Nb_Rois);
% RMSE_aft_roi_ot2 = sqrt(num2(1:35,4)/Nb_Rois);
% RMSE_aft_roi_ot_norm2 = (RMSE_aft_roi_ot2./RMSE_bef_roi_ot2)'*100;
% 
% RMSE_bef_roi_ot4 = sqrt(num4(1:35,1)/Nb_Rois);
% RMSE_aft_roi_ot4 = sqrt(num4(1:35,4)/Nb_Rois);
% RMSE_aft_roi_ot_norm4 = (RMSE_aft_roi_ot4./RMSE_bef_roi_ot4)'*100;
% 
% RMSE_bef_roi_ot6 = sqrt(num6(1:35,1)/Nb_Rois);
% RMSE_aft_roi_ot6 = sqrt(num6(1:35,4)/Nb_Rois);
% RMSE_aft_roi_ot_norm6 = (RMSE_aft_roi_ot6./RMSE_bef_roi_ot6)'*100;
% 
% RMSE_bef_roi_ot8 = sqrt(num8(1:35,1)/Nb_Rois);
% RMSE_aft_roi_ot8 = sqrt(num8(1:35,4)/Nb_Rois);
% RMSE_aft_roi_ot_norm8 = (RMSE_aft_roi_ot8./RMSE_bef_roi_ot8)'*100;
%  
% % RMSE_aft_ot_norm_concat = [RMSE_aft_vx_ot_norm; RMSE_aft_roi_ot_norm];
% % RMSE_aft_ot_norm_mean = mean(RMSE_aft_ot_norm_concat,1);
% % 
% 
% % Plot reduction of variability (%RMSE) based on vertices values for OT35
% figure(1)
% hold on
% plot(1:35,RMSE_aft_vx_ot_norm1,'g-o','LineWidth',1,'MarkerEdgeColor','green','MarkerSize',2);
% plot(1:35,RMSE_aft_vx_ot_norm3,'r-o','LineWidth',1,'MarkerEdgeColor','red','MarkerSize',2);
% plot(1:35,RMSE_aft_vx_ot_norm5,'magenta-o','LineWidth',1,'MarkerEdgeColor','magenta','MarkerSize',2);
% plot(1:35,RMSE_aft_vx_ot_norm7,'b-o','LineWidth',1,'MarkerEdgeColor','blue','MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC');
% hold off
% ylim([0 100])
% % set(gca,'fontsize',18)
% title('Reduction of variability in Early-Onset AD scans after EQ.PET alignment based on vertices values (R2/R1)')
% xlabel('Individual scans')
% ylabel('% RMSE')
% print(fullfile(OUTDIR, 'ReductionRMSE_OSEM_OSEM_vertices_final'), '-dtiff', '-r1200');
% 
% % Plot reduction of variability (%RMSE) based on ROIs values for OT35
% figure(2)
% hold on
% plot(1:35,RMSE_aft_roi_ot_norm2,'g-o','LineWidth',1,'MarkerEdgeColor','green', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_ot_norm4,'r-o','LineWidth',1,'MarkerEdgeColor','red', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_ot_norm6,'magenta-o','LineWidth',1,'MarkerEdgeColor','magenta', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_ot_norm8,'b-o','LineWidth',1,'MarkerEdgeColor','blue', 'MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC');
% hold off
% ylim([0 100])
% % set(gca,'fontsize',18)
% title('Reduction of variability in Early-Onset AD scans after EQ.PET alignment based on ROIs values (R2/R1)')
% xlabel('Individual scans')
% ylabel('% RMSE')
% print(fullfile(OUTDIR, 'ReductionRMSE_OSEM_OSEM_ROIs_final'), '-dtiff', '-r1200');

% % Compute mean+sd of %RMSE reduction based on vertices values
% % Native+NoPVC
% mean_RMSE_vx_ot_nat_nopvc = mean(RMSE_aft_vx_ot_norm1);
% sd_RMSE_vx_ot_nat_nopvc = std(RMSE_aft_vx_ot_norm1);
% % Native+PVC
% mean_RMSE_vx_ot_nat_pvc = mean(RMSE_aft_vx_ot_norm3);
% sd_RMSE_vx_ot_nat_pvc = std(RMSE_aft_vx_ot_norm3);
% % Common+NoPVC
% mean_RMSE_vx_ot_com_nopvc = mean(RMSE_aft_vx_ot_norm5);
% sd_RMSE_vx_ot_com_nopvc = std(RMSE_aft_vx_ot_norm5);
% % Common+PVC
% mean_RMSE_vx_ot_com_pvc = mean(RMSE_aft_vx_ot_norm7);
% sd_RMSE_vx_ot_com_pvc = std(RMSE_aft_vx_ot_norm7);
% 
% % RMSE between native and common space based on vertices values
% % NoPVC
% RMSE_vx_ot_nopvc = rms(RMSE_aft_vx_ot_norm5-RMSE_aft_vx_ot_norm1);
% mean_RMSE_vx_ot_nopvc = mean(abs(RMSE_aft_vx_ot_norm5-RMSE_aft_vx_ot_norm1));
% sd_RMSE_vx_ot_nopvc = std(abs(RMSE_aft_vx_ot_norm5-RMSE_aft_vx_ot_norm1));
% % PVC
% RMSE_vx_ot_pvc = rms(RMSE_aft_vx_ot_norm7-RMSE_aft_vx_ot_norm3);
% mean_RMSE_vx_ot_pvc = mean(abs(RMSE_aft_vx_ot_norm7-RMSE_aft_vx_ot_norm3));
% sd_RMSE_vx_ot_pvc = std(abs(RMSE_aft_vx_ot_norm7-RMSE_aft_vx_ot_norm3));
% 
% % Compute mean+sd of %RMSE reduction based on ROIs values
% % Native+NoPVC
% mean_RMSE_roi_ot_nat_nopvc = mean(RMSE_aft_roi_ot_norm2);
% sd_RMSE_roi_ot_nat_nopvc = std(RMSE_aft_roi_ot_norm2);
% % Native+PVC
% mean_RMSE_roi_ot_nat_pvc = mean(RMSE_aft_roi_ot_norm4);
% sd_RMSE_roi_ot_nat_pvc = std(RMSE_aft_roi_ot_norm4);
% % Common+NoPVC
% mean_RMSE_roi_ot_com_nopvc = mean(RMSE_aft_roi_ot_norm6);
% sd_RMSE_roi_ot_com_nopvc = std(RMSE_aft_roi_ot_norm6);
% % Common+PVC
% mean_RMSE_roi_ot_com_pvc = mean(RMSE_aft_roi_ot_norm8);
% sd_RMSE_roi_ot_com_pvc = std(RMSE_aft_roi_ot_norm8);
% 
% % RMSE between native and common space based on ROIs values
% % NoPVC
% RMSE_roi_ot_nopvc = rms(RMSE_aft_roi_ot_norm6-RMSE_aft_roi_ot_norm2);
% mean_RMSE_roi_ot_nopvc = mean(abs(RMSE_aft_roi_ot_norm6-RMSE_aft_roi_ot_norm2));
% sd_RMSE_roi_ot_nopvc = std(abs(RMSE_aft_roi_ot_norm6-RMSE_aft_roi_ot_norm2));
% % PVC
% RMSE_roi_ot_pvc = rms(RMSE_aft_roi_ot_norm8-RMSE_aft_roi_ot_norm4);
% mean_RMSE_roi_ot_pvc = mean(abs(RMSE_aft_roi_ot_norm8-RMSE_aft_roi_ot_norm4));
% sd_RMSE_roi_ot_pvc = std(abs(RMSE_aft_roi_ot_norm8-RMSE_aft_roi_ot_norm4));

% %%%% Import SSD for UHD35 (native/common + noPVC/PVC + Vertices/ROIs) %%%%
% WD='/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD';
% [num1,txt1,raw1] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_noPVC_IN_UHD35');
% [num2,txt2,raw2] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_noPVC_IN_ROIs_UHD35');
% [num3,txt3,raw3] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_PVC_IN_UHD35');
% [num4,txt4,raw4] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_PVC_IN_ROIs_UHD35');
% [num5,txt5,raw5] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_noPVC_IN_UHD35');
% [num6,txt6,raw6] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_noPVC_IN_ROIs_UHD35');
% [num7,txt7,raw7] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_PVC_IN_UHD35');
% [num8,txt8,raw8] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_PVC_IN_ROIs_UHD35');
% 
% % Manage Vertices data for UHD35 in native space
% fid = fopen('/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients/subjects_EQ.PET');
% subj = textscan(fid, '%s');
% fclose(fid);
% 
% for j = 1:35
%     [vtxs_lh,nvtxs_lh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','lh.cortex.label'));
%     [vtxs_rh,nvtxs_rh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','rh.cortex.label'));
%     nbVerticesCortexNative(j) = nvtxs_lh + nvtxs_rh;
%     
%     RMSE_bef_vx_uhd1(j) = sqrt(num1(j,1)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_uhd1(j) = sqrt(num1(j,7)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_uhd_norm1(j) = (RMSE_aft_vx_uhd1(j)/RMSE_bef_vx_uhd1(j))'*100;
%     
%     RMSE_bef_vx_uhd3(j) = sqrt(num3(j,1)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_uhd3(j) = sqrt(num3(j,7)/nbVerticesCortexNative(j));
%     RMSE_aft_vx_uhd_norm3(j) = (RMSE_aft_vx_uhd3(j)/RMSE_bef_vx_uhd3(j))'*100;
% end
% 
% % Manage Vertices data for UHD35 in common space
% RMSE_bef_vx_uhd5 = sqrt(num5(1:35,1)/Nb_vertices_cortex);
% RMSE_aft_vx_uhd5 = sqrt(num5(1:35,7)/Nb_vertices_cortex);
% RMSE_aft_vx_uhd_norm5 = (RMSE_aft_vx_uhd5./RMSE_bef_vx_uhd5)'*100;
% 
% RMSE_bef_vx_uhd7 = sqrt(num7(1:35,1)/Nb_vertices_cortex);
% RMSE_aft_vx_uhd7 = sqrt(num7(1:35,7)/Nb_vertices_cortex);
% RMSE_aft_vx_uhd_norm7 = (RMSE_aft_vx_uhd7./RMSE_bef_vx_uhd7)'*100;
% 
% % Manage ROIs data for UHD35
% RMSE_bef_roi_uhd2 = sqrt(num2(1:35,1)/Nb_Rois);
% RMSE_aft_roi_uhd2 = sqrt(num2(1:35,7)/Nb_Rois);
% RMSE_aft_roi_uhd_norm2 = (RMSE_aft_roi_uhd2./RMSE_bef_roi_uhd2)'*100;
% 
% RMSE_bef_roi_uhd4 = sqrt(num4(1:35,1)/Nb_Rois);
% RMSE_aft_roi_uhd4 = sqrt(num4(1:35,7)/Nb_Rois);
% RMSE_aft_roi_uhd_norm4 = (RMSE_aft_roi_uhd4./RMSE_bef_roi_uhd4)'*100;
% 
% RMSE_bef_roi_uhd6 = sqrt(num6(1:35,1)/Nb_Rois);
% RMSE_aft_roi_uhd6 = sqrt(num6(1:35,7)/Nb_Rois);
% RMSE_aft_roi_uhd_norm6 = (RMSE_aft_roi_uhd6./RMSE_bef_roi_uhd6)'*100;
% 
% RMSE_bef_roi_uhd8 = sqrt(num8(1:35,1)/Nb_Rois);
% RMSE_aft_roi_uhd8 = sqrt(num8(1:35,7)/Nb_Rois);
% RMSE_aft_roi_uhd_norm8 = (RMSE_aft_roi_uhd8./RMSE_bef_roi_uhd8)'*100;
%  
% % RMSE_aft_uhd_norm_concat = [RMSE_aft_vx_uhd_norm; RMSE_aft_roi_uhd_norm];
% % RMSE_aft_uhd_norm_mean = mean(RMSE_aft_uhd_norm_concat,1);
% 
% % Plot reduction of variability (%RMSE) based on vertices values for UHD35
% figure(1)
% hold on
% plot(1:35,RMSE_aft_vx_uhd_norm1,'g-o','LineWidth',1,'MarkerEdgeColor','green', 'MarkerSize',2);
% plot(1:35,RMSE_aft_vx_uhd_norm3,'r-o','LineWidth',1,'MarkerEdgeColor','red', 'MarkerSize',2);
% plot(1:35,RMSE_aft_vx_uhd_norm5,'magenta-o','LineWidth',1,'MarkerEdgeColor','magenta', 'MarkerSize',2);
% plot(1:35,RMSE_aft_vx_uhd_norm7,'b-o','LineWidth',1,'MarkerEdgeColor','blue', 'MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC');
% hold off
% ylim([0 100])
% % set(gca,'fontsize',18)
% title('Reduction of variability in Early-Onset AD scans after EQ.PET alignment based on vertices values (R3/R1)')
% xlabel('Individual scans')
% ylabel('% RMSE')
% print(fullfile(OUTDIR, 'ReductionRMSE_UHD_OSEM_vertices_final'), '-dtiff', '-r1200');
% 
% % Plot reduction of variability (%RMSE) based on ROIs values for UHD35
% figure(2)
% hold on
% plot(1:35,RMSE_aft_roi_uhd_norm2,'g-o','LineWidth',1,'MarkerEdgeColor','green', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_uhd_norm4,'r-o','LineWidth',1,'MarkerEdgeColor','red', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_uhd_norm6,'magenta-o','LineWidth',1,'MarkerEdgeColor','magenta', 'MarkerSize',2);
% plot(1:35,RMSE_aft_roi_uhd_norm8,'b-o','LineWidth',1,'MarkerEdgeColor','blue', 'MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC');
% hold off
% ylim([0 100])
% % set(gca,'fontsize',18)
% title('Reduction of variability in Early-Onset AD scans after EQ.PET alignment based on ROIs values (R3/R1)')
% xlabel('Individual scans')
% ylabel('% RMSE')
% print(fullfile(OUTDIR, 'ReductionRMSE_UHD_OSEM_ROIs_final'), '-dtiff', '-r1200');
% 
% % Compute mean+sd of %RMSE reduction based on vertices values
% % Native+NoPVC
% mean_RMSE_vx_uhd_nat_nopvc = mean(RMSE_aft_vx_uhd_norm1);
% sd_RMSE_vx_uhd_nat_nopvc = std(RMSE_aft_vx_uhd_norm1);
% % Native+PVC
% mean_RMSE_vx_uhd_nat_pvc = mean(RMSE_aft_vx_uhd_norm3);
% sd_RMSE_vx_uhd_nat_pvc = std(RMSE_aft_vx_uhd_norm3);
% % Common+NoPVC
% mean_RMSE_vx_uhd_com_nopvc = mean(RMSE_aft_vx_uhd_norm5);
% sd_RMSE_vx_uhd_com_nopvc = std(RMSE_aft_vx_uhd_norm5);
% % Common+PVC
% mean_RMSE_vx_uhd_com_pvc = mean(RMSE_aft_vx_uhd_norm7);
% sd_RMSE_vx_uhd_com_pvc = std(RMSE_aft_vx_uhd_norm7);
% 
% % RMSE between native and common space based on vertices values
% % NoPVC
% RMSE_vx_uhd_nopvc = rms(RMSE_aft_vx_uhd_norm5-RMSE_aft_vx_uhd_norm1);
% mean_RMSE_vx_uhd_nopvc = mean(abs(RMSE_aft_vx_uhd_norm5-RMSE_aft_vx_uhd_norm1));
% sd_RMSE_vx_uhd_nopvc = std(abs(RMSE_aft_vx_uhd_norm5-RMSE_aft_vx_uhd_norm1));
% % PVC
% RMSE_vx_uhd_pvc = rms(RMSE_aft_vx_uhd_norm7-RMSE_aft_vx_uhd_norm3);
% mean_RMSE_vx_uhd_pvc = mean(abs(RMSE_aft_vx_uhd_norm7-RMSE_aft_vx_uhd_norm3));
% sd_RMSE_vx_uhd_pvc = std(abs(RMSE_aft_vx_uhd_norm7-RMSE_aft_vx_uhd_norm3));
% 
% % Compute mean+sd of %RMSE reduction based on ROIs values
% % Native+NoPVC
% mean_RMSE_roi_uhd_nat_nopvc = mean(RMSE_aft_roi_uhd_norm2);
% sd_RMSE_roi_uhd_nat_nopvc = std(RMSE_aft_roi_uhd_norm2);
% % Native+PVC
% mean_RMSE_roi_uhd_nat_pvc = mean(RMSE_aft_roi_uhd_norm4);
% sd_RMSE_roi_uhd_nat_pvc = std(RMSE_aft_roi_uhd_norm4);
% % Common+NoPVC
% mean_RMSE_roi_uhd_com_nopvc = mean(RMSE_aft_roi_uhd_norm6);
% sd_RMSE_roi_uhd_com_nopvc = std(RMSE_aft_roi_uhd_norm6);
% % Common+PVC
% mean_RMSE_roi_uhd_com_pvc = mean(RMSE_aft_roi_uhd_norm8);
% sd_RMSE_roi_uhd_com_pvc = std(RMSE_aft_roi_uhd_norm8);
% 
% % RMSE between native and common space based on ROIs values
% % NoPVC
% RMSE_roi_uhd_nopvc = rms(RMSE_aft_roi_uhd_norm6-RMSE_aft_roi_uhd_norm2);
% mean_RMSE_roi_uhd_nopvc = mean(abs(RMSE_aft_roi_uhd_norm6-RMSE_aft_roi_uhd_norm2));
% sd_RMSE_roi_uhd_nopvc = std(abs(RMSE_aft_roi_uhd_norm6-RMSE_aft_roi_uhd_norm2));
% % PVC
% RMSE_roi_uhd_pvc = rms(RMSE_aft_roi_uhd_norm8-RMSE_aft_roi_uhd_norm4);
% mean_RMSE_roi_uhd_pvc = mean(abs(RMSE_aft_roi_uhd_norm8-RMSE_aft_roi_uhd_norm4));
% sd_RMSE_roi_uhd_pvc = std(abs(RMSE_aft_roi_uhd_norm8-RMSE_aft_roi_uhd_norm4));

%%%% Compute RMSE curves along smoohting sizes %%%%

% % Import SSD for OT35 (native/common + noPVC/PVC + Vertices/ROIs) %% 
% WD='/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD';
% [num1,txt1,raw1] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_noPVC_IN_OT35');
% [num2,txt2,raw2] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_noPVC_IN_ROIs_OT35');
% [num3,txt3,raw3] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_PVC_IN_OT35');
% [num4,txt4,raw4] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'native_PVC_IN_ROIs_OT35');
% [num5,txt5,raw5] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_noPVC_IN_OT35');
% [num6,txt6,raw6] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_noPVC_IN_ROIs_OT35');
% [num7,txt7,raw7] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_PVC_IN_OT35');
% [num8,txt8,raw8] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'common_PVC_IN_ROIs_OT35');
% [num9,txt9,raw9] = xlsread(fullfile(WD,'SSD_results_OT_Mat_35pat.xlsx'), 'SR_RMSE');
% 
% % Manage Vertices data for OT35 in native space
% fid = fopen('/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients/subjects_EQ.PET');
% subj = textscan(fid, '%s');
% fclose(fid);
% 
% for j = 1:35
%     for i = 1:8
%         [vtxs_lh,nvtxs_lh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','lh.cortex.label'));
%         [vtxs_rh,nvtxs_rh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','rh.cortex.label'));
%         nbVerticesCortexNative(j) = nvtxs_lh + nvtxs_rh;
% 
%         RMSE_vx_ot1(j,i) = sqrt(num1(j,i)/nbVerticesCortexNative(j));
%         RMSE_vx_ot3(j,i) = sqrt(num3(j,i)/nbVerticesCortexNative(j));
%     end
% end
% RMSE_mean_vx_ot1 = mean(RMSE_vx_ot1);
% std_err_vx_ot1 = std(RMSE_vx_ot1);
% 
% RMSE_mean_vx_ot3 = mean(RMSE_vx_ot3);
% std_err_vx_ot3 = std(RMSE_vx_ot3);
% 
% % Manage Vertices data for OT35 in common space
% RMSE_vx_ot5 = sqrt(num5(1:35,1:8)/Nb_vertices_cortex);
% RMSE_mean_vx_ot5 = mean(RMSE_vx_ot5);
% std_err_vx_ot5 = std(RMSE_vx_ot5);
% 
% RMSE_vx_ot7 = sqrt(num7(1:35,1:8)/Nb_vertices_cortex);
% RMSE_mean_vx_ot7 = mean(RMSE_vx_ot7);
% std_err_vx_ot7 = std(RMSE_vx_ot7);
% 
% % Manage ROIs data for OT35
% RMSE_roi_ot2 = sqrt(num2(1:35,1:8)/Nb_Rois);
% RMSE_mean_roi_ot2 = mean(RMSE_roi_ot2);
% std_err_roi_ot2 = std(RMSE_roi_ot2);
% 
% RMSE_roi_ot4 = sqrt(num4(1:35,1:8)/Nb_Rois);
% RMSE_mean_roi_ot4 = mean(RMSE_roi_ot4);
% std_err_roi_ot4 = std(RMSE_roi_ot4);
% 
% RMSE_roi_ot6 = sqrt(num6(1:35,1:8)/Nb_Rois);
% RMSE_mean_roi_ot6 = mean(RMSE_roi_ot6);
% std_err_roi_ot6 = std(RMSE_roi_ot6);
% 
% RMSE_roi_ot8 = sqrt(num8(1:35,1:8)/Nb_Rois);
% RMSE_mean_roi_ot8 = mean(RMSE_roi_ot8);
% std_err_roi_ot8 = std(RMSE_roi_ot8);
% 
% % Manage spatial resolution data for OT35
% RMSE_mean_sr_ot9 = mean(num9(1:35,1:8));
% std_err_sr_ot9 = std(num9(1:35,1:8));
% 
% Smooth_sizes_ot = [0 1.3 2.1 2.4 2.6 2.9 3.5 4.6];
% 
% % Plot mean RMSE across patients based on vertices values for OT35
% figure(3)
% hold on
% delta = .008; % Adjust manually
% errorbar(Smooth_sizes_ot-delta,RMSE_mean_vx_ot1,std_err_vx_ot1,'g-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot-delta,RMSE_mean_vx_ot3,std_err_vx_ot3,'r-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot+delta,RMSE_mean_vx_ot5,std_err_vx_ot5,'magenta-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot+delta,RMSE_mean_vx_ot7,std_err_vx_ot7,'b-o','LineWidth',1,'MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC','Location', 'SouthEast');
% hold off
% xlim([-0.1 5])
% ylim([0 0.75])
% % set(gca,'fontsize',18)
% title('Mean RMSE based on vertices values across Early-Onset AD dataset according additional gaussian smoothing (R2/R1)')
% xlabel('Smoothing kernel sizes (mm)')
% ylabel('Mean RMSE')
% print(fullfile(OUTDIR, 'MeanRMSE_Smooth_OSEM_OSEM_Vertices_final'), '-dtiff', '-r1200');
% 
% % Plot mean RMSE across patients based on ROIs values for OT35
% figure(4)
% hold on
% delta = .005; % Adjust manually
% errorbar(Smooth_sizes_ot-2*delta,RMSE_mean_roi_ot2,std_err_roi_ot2,'g-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot-delta,RMSE_mean_roi_ot4,std_err_roi_ot4,'r-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot+delta,RMSE_mean_roi_ot6,std_err_roi_ot6,'magenta-o','LineWidth',1,'MarkerSize',2);
% errorbar(Smooth_sizes_ot+2*delta,RMSE_mean_roi_ot8,std_err_roi_ot8,'b-o','LineWidth',1,'MarkerSize',2);
% hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC', 'Location', 'SouthEast');
% hold off
% xlim([-0.1 5])
% ylim([0 0.35])
% % set(gca,'fontsize',18)
% title('Mean RMSE based on ROIs values across Early-Onset AD dataset according additional gaussian smoothing (R2/R1)')
% xlabel('Smoothing kernel sizes (mm)')
% ylabel('Mean RMSE')
% print(fullfile(OUTDIR, 'MeanRMSE_Smooth_OSEM_OSEM_ROIs_final'), '-dtiff', '-r1200');
% 
% % Plot mean RMSE across patients based on spatial resolution values for OT35
% figure(7)
% errorbar(Smooth_sizes_ot,RMSE_mean_sr_ot9,std_err_sr_ot9,'g-o','LineWidth',1,'MarkerSize',2);
% xlim([-0.1 5])
% ylim([0 5])
% % set(gca,'fontsize',18)
% title('Mean RMSE based on spatial resolution values across Early-Onset AD dataset according additional gaussian smoothing (R2/R1)')
% xlabel('Smoothing kernel sizes (mm)')
% ylabel('Mean RMSE')
% print(fullfile(OUTDIR, 'MeanRMSE_Smooth_OSEM_OSEM_SR_final'), '-dtiff', '-r1200');
% 
% % % Compute paired t-tests on RMSE scores before/after EQ.PET alignment %
% % 
% % % Manage Vertices data for OT35 in native space
% % [h_diff_vx_ot1,p_diff_vx_ot1] = ttest(RMSE_vx_ot1(:,1),RMSE_vx_ot1(:,4));
% % [h_diff_vx_ot3,p_diff_vx_ot3] = ttest(RMSE_vx_ot3(:,1),RMSE_vx_ot3(:,4));
% % 
% % % Manage Vertices data for OT35 in common space
% % [h_diff_vx_ot5,p_diff_vx_ot5] = ttest(RMSE_vx_ot5(:,1),RMSE_vx_ot5(:,4));
% % [h_diff_vx_ot7,p_diff_vx_ot7] = ttest(RMSE_vx_ot7(:,1),RMSE_vx_ot7(:,4));
% % 
% % % Manage ROIs data for OT35
% % [h_diff_roi_ot2,p_diff_roi_ot2] = ttest(RMSE_roi_ot2(:,1),RMSE_roi_ot2(:,4));
% % [h_diff_roi_ot4,p_diff_roi_ot4] = ttest(RMSE_roi_ot4(:,1),RMSE_roi_ot4(:,4));
% % [h_diff_roi_ot6,p_diff_roi_ot6] = ttest(RMSE_roi_ot6(:,1),RMSE_roi_ot6(:,4));
% % [h_diff_roi_ot8,p_diff_roi_ot8] = ttest(RMSE_roi_ot8(:,1),RMSE_roi_ot8(:,4));
% % 
% % % Smooth_sizes_ot = [2 2.4 2.9 3.1 3.3 3.5 4 5];
% 
%%  Import SSD for UHD35 (native/common + noPVC/PVC + Vertices/ROIs) %% 
WD='/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/SSD';
[num1,txt1,raw1] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_noPVC_IN_UHD35');
[num2,txt2,raw2] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_noPVC_IN_ROIs_UHD35');
[num3,txt3,raw3] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_PVC_IN_UHD35');
[num4,txt4,raw4] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'native_PVC_IN_ROIs_UHD35');
[num5,txt5,raw5] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_noPVC_IN_UHD35');
[num6,txt6,raw6] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_noPVC_IN_ROIs_UHD35');
[num7,txt7,raw7] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_PVC_IN_UHD35');
[num8,txt8,raw8] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'common_PVC_IN_ROIs_UHD35');
[num9,txt9,raw9] = xlsread(fullfile(WD,'SSD_results_UHD_Mat_35pat.xlsx'), 'SR_RMSE');

% Manage Vertices data for UHD35 in native space
fid = fopen('/NAS/tupac/matthieu/Siemens/EQ.PET_group_analyses/PALM/Description_files/TARGETvsSOURCE_35patients/subjects_EQ.PET');
subj = textscan(fid, '%s');
fclose(fid);

for j = 1:35
    for i = 1:9
        [vtxs_lh,nvtxs_lh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','lh.cortex.label'));
        [vtxs_rh,nvtxs_rh] = fs_read_label(fullfile(FS_DIR,subj{1}{j},'label','rh.cortex.label'));
        nbVerticesCortexNative(j) = nvtxs_lh + nvtxs_rh;

        RMSE_vx_uhd1(j,i) = sqrt(num1(j,i)/nbVerticesCortexNative(j));
        RMSE_vx_uhd3(j,i) = sqrt(num3(j,i)/nbVerticesCortexNative(j));
    end
end
RMSE_mean_vx_uhd1 = mean(RMSE_vx_uhd1);
std_err_vx_uhd1 = std(RMSE_vx_uhd1);

RMSE_mean_vx_uhd3 = mean(RMSE_vx_uhd3);
std_err_vx_uhd3 = std(RMSE_vx_uhd3);

% Manage Vertices data for UHD35 in common space
RMSE_vx_uhd5 = sqrt(num5(1:35,1:9)/Nb_vertices_cortex);
RMSE_mean_vx_uhd5 = mean(RMSE_vx_uhd5);
std_err_vx_uhd5 = std(RMSE_vx_uhd5);

RMSE_vx_uhd7 = sqrt(num7(1:35,1:9)/Nb_vertices_cortex);
RMSE_mean_vx_uhd7 = mean(RMSE_vx_uhd7);
std_err_vx_uhd7 = std(RMSE_vx_uhd7);

% Manage ROIs data for UHD35
RMSE_roi_uhd2 = sqrt(num2(1:35,1:9)/Nb_Rois);
RMSE_mean_roi_uhd2 = mean(RMSE_roi_uhd2);
std_err_roi_uhd2 = std(RMSE_roi_uhd2);

RMSE_roi_uhd4 = sqrt(num4(1:35,1:9)/Nb_Rois);
RMSE_mean_roi_uhd4 = mean(RMSE_roi_uhd4);
std_err_roi_uhd4 = std(RMSE_roi_uhd4);

RMSE_roi_uhd6 = sqrt(num6(1:35,1:9)/Nb_Rois);
RMSE_mean_roi_uhd6 = mean(RMSE_roi_uhd6);
std_err_roi_uhd6 = std(RMSE_roi_uhd6);

RMSE_roi_uhd8 = sqrt(num8(1:35,1:9)/Nb_Rois);
RMSE_mean_roi_uhd8 = mean(RMSE_roi_uhd8);
std_err_roi_uhd8 = std(RMSE_roi_uhd8);

% Manage spatial resolution data for OT35
RMSE_mean_sr_uhd9 = mean(num9(1:35,1:9));
std_err_sr_uhd9 = std(num9(1:35,1:9));

Smooth_sizes_uhd = [0 1.5 2.2 2.6 2.9 3.5 4 4.6 5.7];

% Plot mean RMSE across patients based on vertices values for UHD35
figure(5)
hold on
delta = .008; % Adjust manually
errorbar(Smooth_sizes_uhd-delta,RMSE_mean_vx_uhd1,std_err_vx_uhd1,'g-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd-delta,RMSE_mean_vx_uhd3,std_err_vx_uhd3,'r-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd+delta,RMSE_mean_vx_uhd5,std_err_vx_uhd5,'magenta-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd+delta,RMSE_mean_vx_uhd7,std_err_vx_uhd7,'b-o','LineWidth',1,'MarkerSize',2);
hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC','Location', 'NorthEast');
hold off
xlim([-0.1 5.9])
ylim([0 1.5])
% set(gca,'fontsize',18)
title('Mean RMSE based on vertices values across Early-Onset AD dataset according additional gaussian smoothing (R3/R1)')
xlabel('Smoothing kernel sizes (mm)')
ylabel('Mean RMSE')
print(fullfile(OUTDIR, 'MeanRMSE_Smooth_UHD_OSEM_Vertices_final'), '-dtiff', '-r1200');

% Plot mean RMSE across patients based on ROIs values for UHD35
figure(6)
hold on
delta = .005; % Adjust manually
errorbar(Smooth_sizes_uhd-2*delta,RMSE_mean_roi_uhd2,std_err_roi_uhd2,'g-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd-delta,RMSE_mean_roi_uhd4,std_err_roi_uhd4,'r-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd+delta,RMSE_mean_roi_uhd6,std_err_roi_uhd6,'magenta-o','LineWidth',1,'MarkerSize',2);
errorbar(Smooth_sizes_uhd+2*delta,RMSE_mean_roi_uhd8,std_err_roi_uhd8,'b-o','LineWidth',1,'MarkerSize',2);
hleg1 = legend('Native+noPVC','Native+PVC','Common+noPVC','Common+PVC','Location', 'NorthEast');
hold off
xlim([-0.1 5.9])
ylim([0 0.55])
% set(gca,'fontsize',18)
title('Mean RMSE based on ROIs values across Early-Onset AD dataset according additional gaussian smoothing (R3/R1)')
xlabel('Smoothing kernel sizes (mm)')
ylabel('Mean RMSE')
print(fullfile(OUTDIR, 'MeanRMSE_Smooth_UHD_OSEM_ROIs_final'), '-dtiff', '-r1200');
% 
% % Plot mean RMSE across patients based on spatial resolution values for UHD35
% figure(8)
% errorbar(Smooth_sizes_uhd,RMSE_mean_sr_uhd9,std_err_sr_uhd9,'g-o','LineWidth',3,'MarkerSize',6);
% xlim([-0.1 6])
% ylim([0 5])
% set(gca,'fontsize',18)
% title('Mean RMSE across Early-Onset AD datasets according additional gaussian smoothing (R3/R1)','FontSize',18,'FontWeight','bold')
% xlabel('Smoothing kernel sizes (mm)','FontSize',18,'FontWeight','bold')
% ylabel('Mean RMSE (based on spatial resolution values)','FontSize',18,'FontWeight','bold')

% % Compute paired t-tests on RMSE scores before/after EQ.PET alignment %
% 
% % Manage Vertices data for UHD35 in native space
% [h_diff_vx_uhd1,p_diff_vx_uhd1] = ttest(RMSE_vx_uhd1(:,1),RMSE_vx_uhd1(:,7));
% [h_diff_vx_uhd3,p_diff_vx_uhd3] = ttest(RMSE_vx_uhd3(:,1),RMSE_vx_uhd3(:,7));
% 
% % Manage Vertices data for UHD35 in common space
% [h_diff_vx_uhd5,p_diff_vx_uhd5] = ttest(RMSE_vx_uhd5(:,1),RMSE_vx_uhd5(:,7));
% [h_diff_vx_uhd7,p_diff_vx_uhd7] = ttest(RMSE_vx_uhd7(:,1),RMSE_vx_uhd7(:,7));
% 
% % Manage ROIs data for UHD35
% [h_diff_roi_uhd2,p_diff_roi_uhd2] = ttest(RMSE_roi_uhd2(:,1),RMSE_roi_uhd2(:,7));
% [h_diff_roi_uhd4,p_diff_roi_uhd4] = ttest(RMSE_roi_uhd4(:,1),RMSE_roi_uhd4(:,7));
% [h_diff_roi_uhd6,p_diff_roi_uhd6] = ttest(RMSE_roi_uhd6(:,1),RMSE_roi_uhd6(:,7));
% [h_diff_roi_uhd8,p_diff_roi_uhd8] = ttest(RMSE_roi_uhd8(:,1),RMSE_roi_uhd8(:,7));
% 
% Smooth_sizes_uhd = [2 2.5 3 3.3 3.5 4 4.5 5 6];