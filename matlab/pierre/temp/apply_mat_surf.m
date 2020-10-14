function surf = apply_mat_surf(insurf, MatFile, mri)
%function surf = apply_mat_surf(insurf, Mat, MRI)

% insurf in Freesurfer centered space
surf = insurf;

tagfile = 'temp.tag';
surf_to_tag(surf, tagfile);

