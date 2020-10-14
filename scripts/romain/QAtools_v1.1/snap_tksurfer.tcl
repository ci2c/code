#open_window
set outpth "$env(SUBJECTS_DIR)/QA/$env(SUBJECT_NAME)/rgb/snaps"
set lablpth "$env(SUBJECTS_DIR)/$env(SUBJECT_NAME)/label"
do_lighting_model 0.4 0.0 0.6 0.2 0.7
redraw

##Inflated
make_lateral_view
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_${hemi}_lat.rgb"
save_rgb
rotate_brain_x 90
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_${hemi}_inf.rgb"
save_rgb
make_lateral_view
rotate_brain_y 180
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_${hemi}_med.rgb"
save_rgb

##curv

read_binary_curv
make_lateral_view
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_curv_${hemi}_lat.rgb"
save_rgb
rotate_brain_x 90
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_curv_${hemi}_inf.rgb"
save_rgb
make_lateral_view
rotate_brain_y 180
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_curv_${hemi}_med.rgb"
save_rgb

##parcellations
surf pial
labl_import_annotation "$lablpth/$hemi.aparc.annot"
make_lateral_view
redraw

set rgb "$outpth/$env(SUBJECT_NAME)_parc_${hemi}_lat.rgb"
save_rgb
rotate_brain_x 90
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_parc_${hemi}_inf.rgb"
save_rgb
make_lateral_view
rotate_brain_y 180
redraw
set rgb "$outpth/$env(SUBJECT_NAME)_parc_${hemi}_med.rgb"
save_rgb
exit
