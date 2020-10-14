clear all; close all;

dataroot = '/home/fatmike/renaud/tep_fog/freesurfer/';
group    = {'g1','g2'};
% subj{1}  = {'ALIB','BOND','DAMB','DEBA','DELA','DENI','DETH','MARQ','POCH','VASS'};
subj{1}  = {'BOND','DAMB','DEBA','DELA','DENI','DETH','MARQ','VASS'};
% subj{2}  = {'BAUD','BETT','BRAN','DUMO','GORE','LEFE','LOUG','RUCH','SAEL','VAND'};
subj{2}  = {'BAUD','BETT','DUMO','GORE','LOUG','RUCH','SAEL','VAND'};
roi={'tep_mask_fef_left_las_recal'  'tep_mask_fef_right_las_recal' 'tep_mask_pm_left_las_recal' 'tep_mask_pm_right_las_recal'}
roi_name={'fef_left'  'fef_right' 'pm_left' 'pm_right'}

for k = 1 : length(group)
    
    
    
    for i = 1:length(subj{k})
        
        fa_path=fullfile(dataroot,group{k},subj{k}{i},'dti/mrtrix/fa.nii');
        
        
        for r = 1:length(roi)
            
            disp('sujet :')
            disp(group{k})
            disp(subj{k}{i})
            
            tck_path=[dataroot group{k} '/' subj{k}{i} '/dti/mrtrix/tracto/tracto_' roi{r} '.tck']
            vtk_path=[dataroot group{k} '/' subj{k}{i} '/dti/mrtrix/tracto/tracto_' roi{r} '.vtk'];
            
            fibers  = f_readFiber_tck(tck_path,0);
            fibers  = sampleFibers(fibers, fa_path, 'fa', 2);
            
            save_tract_vtk(fibers,vtk_path, 'BINARY', 'fa');
          
            
        end
        
    end
    
    
end


