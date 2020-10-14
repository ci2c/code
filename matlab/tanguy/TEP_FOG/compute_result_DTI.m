clear all; close all;

dataroot = '/home/fatmike/renaud/tep_fog/freesurfer';
group    = {'g1','g2'};
% subj{1}  = {'ALIB','BOND','DAMB','DEBA','DELA','DENI','DETH','MARQ','POCH','VASS'};
subj{1}  = {'BOND','DAMB','DEBA','DELA','DENI','DETH','MARQ','VASS'};
% subj{2}  = {'BAUD','BETT','BRAN','DUMO','GORE','LEFE','LOUG','RUCH','SAEL','VAND'};
subj{2}  = {'BAUD','BETT','DUMO','GORE','LOUG','RUCH','SAEL','VAND'};
roi={'tep_mask_fef_left_las_recal'  'tep_mask_fef_right_las_recal' 'tep_mask_pm_left_las_recal' 'tep_mask_pm_right_las_recal'}
roi_name={'fef_left'  'fef_right' 'pm_left' 'pm_right'}

for k = 1 : length(group)
    
    result{k} = zeros(2*length(roi),length(subj{k}));
    dens{k} = zeros(length(roi),length(subj{k}));
    
    moyfa{k} = zeros(length(roi),length(subj{k}));
    stdfa{k} = zeros(length(roi),length(subj{k}));
    long{k}  = zeros(length(roi),length(subj{k}));
    moyfa_on_roi{k} = zeros(length(roi),length(subj{k}));
    
    for i = 1:length(subj{k})
        
        for r = 1:length(roi)
            
            roi_mat = ['tracto_' roi{r} '.mat'];
            mean_roi_mat = ['mean_fa_' roi{r} '.mat'];
            mat_path = fullfile(dataroot,group{k},subj{k}{i},'dti/mrtrix/tracto',roi_mat);
            mat_mean_path = fullfile(dataroot,group{k},subj{k}{i},'dti/mrtrix/tracto',mean_roi_mat);
            
            
            if exist(mat_path) ~= 0
                load(mat_path)
                load(mat_mean_path)
                result{k}((2*r)-1,i)=fibers.nFiberNr;
                result{k}(2*r,i)=region_of_interest.size;
                dens{k}(r,i)=fibers.nFiberNr/region_of_interest.size;

                FA       = cat(1, fibers.fiber.fa_mean);
                moyfa{k}(r,i) = mean(FA);
                stdfa{k}(r,i) = std(FA);
                long{k}(r,i)  = length(FA);
                moyfa_on_roi{k}(r,i) = mean_fa_on_roi;
                
            else
                warning(['no mat file for : ' mat_path])
                result{k}((2*r)-1,i)=NaN;
                result{k}(2*r,i)=NaN;
                dens{k}(r,i)=NaN;
                FA       = NaN;
                moyfa{k}(r,i) = NaN;
                stdfa{k}(r,i) = NaN;
                long{k}(r,i)  = NaN;
                faval{k}(r,i) = NaN;
            end
            
            
            
            clear Connectome fibers region_of_interest mean_fa_on_roi FA
            
            %         fibers_path = fullfile(dataroot,group{k},subj{k}{i},'dti/mrtrix/whole_brain_8_500000.tck');
        end
        
    end
    
    
end


%% Graphes




name_roi={};
box_fibers=zeros(2*length(roi),max(length(subj{1}),length(subj{2})));
for i = 1 : 4
    box_fibers(2*i-1,1:length(subj{1}))=dens{1}(i,:);
    box_fibers(2*i,1:length(subj{2}))=dens{2}(i,:);
    
    box_fa(2*i-1,1:length(subj{1}))=moyfa{1}(i,:);
    box_fa(2*i,1:length(subj{2}))=moyfa{2}(i,:);
    
    box_fa_on_roi(2*i-1,1:length(subj{1}))=moyfa_on_roi{1}(i,:);
    box_fa_on_roi(2*i,1:length(subj{2}))=moyfa_on_roi{2}(i,:);
    
    name_roi=[name_roi strcat(roi_name(i),'_g1')];
    name_roi=[name_roi strcat(roi_name(i),'_g2')];

end
box_fibers(box_fibers==0)=NaN;
box_fa(box_fa==0)=NaN;
figure
subplot(3,1,1)
boxplot(box_fibers',name_roi)
title('fibers density')

subplot(3,1,2)
boxplot(box_fa',name_roi)
title('fa mean on fibers')


subplot(3,1,3)
boxplot(box_fa_on_roi',name_roi)
title('fa mean on roi')



%% Tests


for i = 1 : 4

% Wilcoxon test
[p_moyfa(i),h_moyfa(i)]      = ranksum(moyfa{1}(i,:),moyfa{2}(i,:));
[p_dens(i),h_dens(i)]      = ranksum(dens{1}(i,:),dens{2}(i,:));
[p_moyfa_on_roi(i),h_moyfa_on_roi(i)]      = ranksum(moyfa_on_roi{1}(i,:),moyfa_on_roi{2}(i,:));

end

disp(roi')

disp('percent FA_mean')
disp(p_moyfa)

disp('significant FA_mean')
disp(h_moyfa)

disp('percent fibers density')
disp(p_dens)

disp('significant fibers density')
disp(h_dens)

disp('percent moy_fa_on_roi')
disp(p_moyfa_on_roi)

disp('significant moy_fa_on_roi')
disp(h_moyfa_on_roi)




% Mann-Whitney test
% grps       = [ones(1,length(moyfa{1}(i,:))) 2*ones(1,length(moyfa{2}(i,:)))];
% 
% moyfa{3}(i,:)   = [moyfa{1}(i,:) moyfa{2}(i,:)];
% [prmoy,U,N,R] = mannwhit(moyfa{3},grps,0)
% 
% long{3}(i,:)    = [long{1}(i,:) long{2}(i,:)];
% [prlong,U,N,R] = mannwhit(long{3}(i,:),grps,0)
% 
% [H,P,CI,STATS] = ttest2(faval{1}(i,:),faval{2}(i,:),[],'both','equal')
% 
% save(fullfile(outdir,[prefix '.mat']),'moyfa','stdfa','grps','long','faval');
