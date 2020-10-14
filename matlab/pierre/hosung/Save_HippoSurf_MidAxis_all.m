function Save_HippoSurf_MidAxis_all(file_list, SPHARM_Dir, patient_type, HEMI, outputDir)
% function Save_HippoSurf_MidAxis_all(file_list, SPHARM_Dir, patient_type, outputDir)
%
% file_list       : A txt file including data list 
%                    i.e., TLE_201, TLE_202, TLE_0001_1
% SPHARM_Dir      : Directory where SPHARM-PDM surfaces were processed.
% '/data/noel/noel3/hosung/MRI/shape_positioning_test_new_cases/SPHARM/Hippo' or
% '/data/noel/noel3/hosung/MRI/shape_positioning_test_new_cases/SPHARM/EC'
% patient_type    : Controls / LTLE_HA / LTLE_NV / RTLE_HA / RTLE_NV
% outputDir       : Directory to which output VTK will be saved.
%
% Hosung Kim. BIC. July 2008.
%
%   See also SAVE_VOLUME_VTK, SAVE_TRACT_VTK

mkdir outputDir
List=fopen(file_list);
MetaDir=strcat(SPHARM_Dir, patient_type, '/surf/SPHARM/');
DeformDir=strcat(SPHARM_Dir, 'stats/R_results/Individual/');
JacoDir=strcat(SPHARM_Dir, 'stats/Jacobian_results/', patient_type, '/');
MidAxisDir=strcat(SPHARM_Dir, 'stats/Curvature_results/', patient_type, '/');
Subj=fgetl(List)
i=0;
while Subj ~ []
    
    file_meta=strcat(MetaDir, Subj, '_', HEMI, '_HP_res_pp_surfSPHARM_procalign.meta')
    file_deform=strcat(DeformDir, Subj, '_', HEMI, '_DeformZ.txt')
    file_jaco=strcat(JacoDir, Subj, '_', HEMI, '_HP_res_pp_surfSPHARM_procalign_Jacobian.txt')
    file_coeff=strcat(MetaDir, Subj, '_', HEMI, '_HP_res_pp_surf_paraPhi.txt')
    fileVTK=strcat(outputDir, '/', Subj, '_', HEMI, '_HP_surf.vtk')
    
    file_midAxis=strcat(MidAxisDir, Subj, '_', HEMI, '_HP_res_pp_surfSPHARM_procalign_medAxis.txt')
    file_midCurv=strcat(MidAxisDir, Subj, '_', HEMI, '_HP_res_pp_surfSPHARM_procalign_LocalCurvature.txt')
    file_midVTK=strcat(outputDir, '/', Subj, '_', HEMI, '_HP_midAxis.vtk')
    
    
    Save_metaNpara2vtk(file_meta, file_deform, file_jaco, file_coeff, fileVTK);
    midAxis = GenMidAxisSurf(file_midAxis, file_midCurv);
    save_tract_vtk(midAxis,file_midVTK, 'BINARY',1);
    Subj=fgetl(List)
    if (Subj == -1)
        break;
    end
    
    i=i+1
end
