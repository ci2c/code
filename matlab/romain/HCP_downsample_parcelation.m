%FSAverage5 Left
wb_command -cifti-separate Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii

wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii \
../standard_mesh_atlases/fs_L/fsaverage.L.sphere.164k_fs_L.surf.gii \
../standard_mesh_atlases/fs_L/fs_L-to-fs_LR_fsaverage.L_LR.spherical_std.164k_fs_L.surf.gii \
Left.sphere.fsaverage5.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii \
Left.sphere.fsaverage5.hcp.surf.gii \
BARYCENTRIC \
left.fsaverage5.hcp.label.gii

mris_convert --annot left.fsaverage5.hcp.label.gii Left.sphere.fsaverage5.hcp.surf.gii ./lh.fsaverage.HCP.annot

freeview -f /home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere:annot=lh.fsaverage.HCP.annot

%FSAverage5 Right
wb_command -cifti-separate Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii

wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.R.10k_fsavg_R.surf.gii \
../standard_mesh_atlases/fs_R/fsaverage.R.sphere.164k_fs_R.surf.gii \
../standard_mesh_atlases/fs_R/fs_R-to-fs_LR_fsaverage.R_LR.spherical_std.164k_fs_R.surf.gii \
Right.sphere.fsaverage5.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.R.sphere.32k_fs_LR.surf.gii \
Right.sphere.fsaverage5.hcp.surf.gii \
BARYCENTRIC \
./right.fsaverage5.hcp.label.gii

mris_convert --annot right.fsaverage5.hcp.label.gii Right.sphere.fsaverage5.hcp.surf.gii ./rh.fsaverage.HCP.annot
freeview -f /home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.pial:annot=lh.fsaverage.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage5/surf/rh.pial:annot=rh.fsaverage.HCP.annot

%FSAverage6 Left
wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage6_std_sphere.L.41k_fsavg_L.surf.gii \
../standard_mesh_atlases/fs_L/fsaverage.L.sphere.164k_fs_L.surf.gii \
../standard_mesh_atlases/fs_L/fs_L-to-fs_LR_fsaverage.L_LR.spherical_std.164k_fs_L.surf.gii \
./Left.sphere.fsaverage6.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii \
Left.sphere.fsaverage6.hcp.surf.gii \
BARYCENTRIC \
./left.fsaverage6.hcp.label.gii

mris_convert --annot left.fsaverage6.hcp.label.gii Left.sphere.fsaverage6.hcp.surf.gii ./lh.fsaverage6.HCP.annot
freeview -f /home/global/freesurfer5.3/subjects/fsaverage6/surf/lh.pial:annot=lh.fsaverage6.HCP.annot

%FSAverage6 Right
wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage6_std_sphere.R.41k_fsavg_R.surf.gii \
../standard_mesh_atlases/fs_R/fsaverage.R.sphere.164k_fs_R.surf.gii \
../standard_mesh_atlases/fs_R/fs_R-to-fs_LR_fsaverage.R_LR.spherical_std.164k_fs_R.surf.gii \
./Right.sphere.fsaverage6.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.R.sphere.32k_fs_LR.surf.gii \
Right.sphere.fsaverage6.hcp.surf.gii \
BARYCENTRIC \
./right.fsaverage6.hcp.label.gii

mris_convert --annot right.fsaverage6.hcp.label.gii Right.sphere.fsaverage6.hcp.surf.gii ./rh.fsaverage6.HCP.annot
freeview -f /home/global/freesurfer5.3/subjects/fsaverage6/surf/lh.pial:annot=lh.fsaverage6.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage6/surf/rh.pial:annot=rh.fsaverage6.HCP.annot

%FSAverage4 Left
wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage4_std_sphere.L.3k_fsavg_L.surf.gii \
../standard_mesh_atlases/fs_L/fsaverage.L.sphere.164k_fs_L.surf.gii \
../standard_mesh_atlases/fs_L/fs_L-to-fs_LR_fsaverage.L_LR.spherical_std.164k_fs_L.surf.gii \
./Left.sphere.fsaverage4.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii \
Left.sphere.fsaverage4.hcp.surf.gii \
BARYCENTRIC \
./left.fsaverage4.hcp.label.gii

mris_convert --annot left.fsaverage4.hcp.label.gii Left.sphere.fsaverage4.hcp.surf.gii ./lh.fsaverage4.HCP.annot
freeview -f /home/global/freesurfer5.3/subjects/fsaverage4/surf/lh.pial:annot=lh.fsaverage4.HCP.annot

%FSAverage6 Right
wb_command -surface-sphere-project-unproject \
../standard_mesh_atlases/resample_fsaverage/fsaverage4_std_sphere.R.3k_fsavg_R.surf.gii \
../standard_mesh_atlases/fs_R/fsaverage.R.sphere.164k_fs_R.surf.gii \
../standard_mesh_atlases/fs_R/fs_R-to-fs_LR_fsaverage.R_LR.spherical_std.164k_fs_R.surf.gii \
./Right.sphere.fsaverage4.hcp.surf.gii

wb_command -label-resample \
Q1-Q6_RelatedParcellation210.R.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
Q1-Q6_RelatedParcellation210.R.sphere.32k_fs_LR.surf.gii \
Right.sphere.fsaverage4.hcp.surf.gii \
BARYCENTRIC \
./right.fsaverage4.hcp.label.gii

mris_convert --annot right.fsaverage4.hcp.label.gii Right.sphere.fsaverage4.hcp.surf.gii ./rh.fsaverage4.HCP.annot
freeview -f /home/global/freesurfer5.3/subjects/fsaverage4/surf/lh.pial:annot=lh.fsaverage4.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage4/surf/rh.pial:annot=rh.fsaverage4.HCP.annot




freeview -f /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/lh.fsaverage.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage/surf/rh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/rh.fsaverage.HCP.annot \
/home/global/freesurfer5.3/subjects/fsaverage6/surf/lh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/lh.fsaverage6.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage6/surf/rh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/rh.fsaverage6.HCP.annot \
/home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/lh.fsaverage5.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage5/surf/rh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/rh.fsaverage5.HCP.annot \
/home/global/freesurfer5.3/subjects/fsaverage4/surf/lh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/lh.fsaverage4.HCP.annot /home/global/freesurfer5.3/subjects/fsaverage4/surf/rh.pial:annot=/NAS/dumbo/renaud/templates/parcellation_FS/rh.fsaverage4.HCP.annot





% %Test
% mris_convert Left_romain_mri.surf.gii  lh.romain.sphere
% mris_convert Q1-Q6_RelatedValidation210.L.sphere.32k_fs_LR.surf.gii Q1-Q6_RelatedValidation210.L.sphere.32k_fs_LR.surf
% 
% 
% %1/première tentative
% clear all; close all;
% 
% cd /home/global/freesurfer5.3/matlab/
% g = gifti('/NAS/tupac/renaud/HCP/scripts/Pipelines-3.14.1//global/templates/standard_mesh_atlases/L.sphere.32k_fs_LR.surf.gii')
% [left_vtx,left_faces]=read_surf('/home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere')
% g2=g;
% g2.faces=int32(left_faces)
% g2.vertices=single(left_vtx)
% cd ~/Downloads/
% save(g2,'Left_mri.surf.gii');
% 
% cd /home/global/freesurfer5.3/matlab/
% g = gifti('/NAS/tupac/renaud/HCP/scripts/Pipelines-3.14.1//global/templates/standard_mesh_atlases/R.sphere.32k_fs_LR.surf.gii')
% [left_vtx,left_faces]=read_surf('/home/global/freesurfer5.3/subjects/fsaverage5/surf/rh.sphere');
% g2=g;
% g2.faces=int32(left_faces)
% g2.vertices=single(left_vtx)
% cd ~/Downloads/
% save(g2,'Right_mri.surf.gii');
% 
% %romain@woody:~/Downloads/Glasser_et_al_2016_HCP_MMP1.0_RVVG_dlabel/HCP_PhaseTwo/Q1-Q6_RelatedValidation210/MNINonLinear/fsaverage_LR32k$ wb_command -cifti-separate Q1-Q6_RelatedValidation210.R.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_RIGHT r.romain.label.gii
% %romain@woody:~/Downloads/Glasser_et_al_2016_HCP_MMP1.0_RVVG_dlabel/HCP_PhaseTwo/Q1-Q6_RelatedValidation210/MNINonLinear/fsaverage_LR32k$ wb_command -cifti-separate Q1-Q6_RelatedValidation210.L.CorticalAreas_dil_Final_Final_Areas_Group.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT l.romain.label.gii
% 
% 
% wb_command -label-resample Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii L.sphere.32k_fs_LR.surf.gii Left_romain_mri.surf.gii BARYCENTRIC left.romain.fsaverage164.label.gii
% 
% mris_convert /home/global/freesurfer5.3/subjects/fsaverage5/surf/rh.sphere ./Right_romain_mri.surf.g 
% %wb_command -label-resample l.romain.label.gii L.sphere.32k_fs_LR.surf.gii Left_romain_mri.surf.gii BARYCENTRIC left.romain.fsaverage164.label.gii
% wb_command -label-resample r.romain.label.gii R.sphere.32k_fs_LR.surf.gii Right_romain_mri.surf.gii BARYCENTRIC right.romain.fsaverage164.label.gii
% 
% 
% mris_convert --annot left.romain.fsaverage164.label.gii Left_romain_mri.surf.gii ./lh.HCP-MMP1.annot
% mris_convert --annot right.romain.fsaverage164.label.gii Right_romain_mri.surf.gii ./rh.HCP-MMP1.annot
% 
% [~, lhlab,lhctable]=read_annotation('/home/romain/Downloads/Glasser_et_al_2016_HCP_MMP1.0_RVVG_dlabel/HCP_PhaseTwo/Q1-Q6_RelatedValidation210/MNINonLinear/fsaverage_LR32k/lh.HCP-MMP1.annot');
% [~, lhlab2,lhctable2]=read_annotation('/home/romain/Downloads/lh.HCP-MMP1.annot');
% 
% 
% %2eme tentative
% 
% cd ~/Downloads/HCP_par_fsaverge5
% mris_convert /home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere ./Left.sphere.fsaverage5.surf.gii 
% mris_convert /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.sphere ./Left.sphere.fsaverage.surf.gii 
% 
% cd ~/Downloads/HCP_par_fsaverge5_2/
% g1 = gifti('Left.sphere.fsaverage.surf.gii')
% g2 = gifti('L.sphere.32k_fs_LR.surf.gii')
% g3 = gifti('/NAS/tupac/renaud/HCP/scripts/Pipelines-3.14.1//global/templates/standard_mesh_atlases/L.sphere.32k_fs_LR.surf.gii')
% g4 = gifti('/home/romain/Downloads/HCP_par_fsaverge5_2/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii')
% 
% cd /home/global/freesurfer5.3/matlab/
% [left_vtx,left_faces]=read_surf('/home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere');
% [vertices1, label1, colortable1]=read_annotation('/home/romain/Downloads/HCP_par_fsaverge5_2/lh.fsaverage.HCP-MMP1.annot');
% [vertices2, label2, colortable2]=read_annotation('/home/romain/Downloads/3498446/lh.HCP-MMP1.annot');
% 
% %3. Using workbench, convert parcellation dabel.nii file label.gii file:
% wb_command -cifti-separate Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.dlabel.nii COLUMN -label CORTEX_LEFT Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii
% 
% %4. Using workbench, convert label.gii file to fsaverage space:
% wb_command -label-resample Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii BARYCENTRIC left.fsaverage5.label.gii
% 
% wb_command -label-resample Q1-Q6_RelatedParcellation210.L.CorticalAreas_dil_Colors.32k_fs_LR.label.gii \
% Q1-Q6_RelatedParcellation210.L.sphere.32k_fs_LR.surf.gii \
% ../standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii \
% ADAP_BARY_AREA \
% test.label.gii \
% -area-metric \
% ../standard_mesh_atlases/resample_fsaverage/fs_LR.L.midthickness_va_avg.32k_fs_LR.shape.gii \
% ../standard_mesh_atlases/resample_fsaverage/fsaverage5.L.midthickness_va_avg.10k_fsavg_L.shape.gii
% 
% mris_convert --annot left.fsaverage.label.gii Left.sphere.fsaverage.surf.gii ./lh.fsaverage.HCP-MMP1.annot
% 
% 
% %5. Using freesurfer, convert files from gii to annot:
% mris_convert --annot test.label.gii ../standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii ./test.annot
% 
% freeview -f /home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere:annot=test.annot ../standard_mesh_atlases/resample_fsaverage/fsaverage5_std_sphere.L.10k_fsavg_L.surf.gii:annot=test.annot
% 
% freeview -f /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.sphere:annot=lh.fsaverage.HCP-MMP1.annot /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.sphere:annot=../3498446/lh.HCP-MMP1.annot
% freeview -f /home/global/freesurfer5.3/subjects/fsaverage5/surf/lh.sphere:annot=lh.HCP-MMP1.annot /home/global/freesurfer5.3/subjects/fsaverage/surf/lh.sphere:annot=../3498446/lh.HCP-MMP1.annot
% 
% 
% %D. fs_LR individual data to fsaverage
% %1
% %../standard_mesh_atlases/resample_fsaverage/fsaverage_std_sphere.L.164k_fsavg_L.surf.gii \ 
% %../standard_mesh_atlases/fs_L/fsaverage.L.sphere.164k_fs_L.surf.gii \
% %../standard_mesh_atlases/resample_fsaverage/fs_LR-deformed_to-fsaverage.L.sphere.164k_fs_LR.surf.gii \