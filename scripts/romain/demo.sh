#!/bin/bash

#ANATOMIQUE
bash view_fs_surface.sh /NAS/tupac/protocoles/healthy_volunteers/FS53/T02S02/
bash view_fs.sh /NAS/tupac/protocoles/healthy_volunteers/FS53/T02S02/

#Mon T2
#/home/RECPAR/T02S02_020479RV^X_SUJETS_SAINS_2016-04-18/1001_T2W_VISTA_HR_SENSE/1001_T2W_VISTA_HR_SENSE_WIP_T2W_VISTA_HR_SENSE_20160418145116_1001.nii

#T1 T2 FLAIR de personnes agées
#freeview 301_T1_3D_HR_SENSE_CD_SENSE/301_T1_3D_HR_SENSE_CD_SENSE_T1_3D_HR_SENSE_CD_SENSE_20131015152701_301.nii 401_FLAIR_3D/401_FLAIR_3D_FLAIR_3D_SENSE_20131015152701_401.nii 601_T2ffe4ECHOSMAP_CLEAR/601_T2ffe4ECHOSMAP_CLEAR_WIP_T2ffe4ECHOSMAP_CLEAR_20131015152701_601_e2.nii

#FONCTIONNEL
#ACQUIS
freeview  /NAS/tupac/protocoles/prodigy2/BIDS_process/freesurfer53/sub-LALOUXPATRICKPRODIGY20180717/mri/T1.mgz \
/NAS/tupac/protocoles/prodigy2/BIDS_process/freesurfer53/sub-LALOUXPATRICKPRODIGY20180717/fmri_verbal_Filt001_01/verbal.nii.gz

#pré_ttt et ttt
freeview $MNI \
/NAS/tupac/protocoles/prodigy2/BIDS_process/freesurfer53/sub-580514SB021117XPRODIGY20171102/fmri_verbal_Filt001_01/run01/wfcarepi_sm6_al.nii.gz:opacity=0 \
/NAS/tupac/protocoles/prodigy2/BIDS_process/freesurfer53/sub-580514SB021117XPRODIGY20171102/fmri_verbal_post/spmT_0001.nii:colormap=jet:colorscale=3.7,9:opacity=0


#PERFUSION ASL
freeview -f \
/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.white\
:overlay=/NAS/tupac/protocoles/healthy_volunteers//FS53/550524JPC280116^X_SUJET_SAIN_2016-01-28/ASL/bbr/Surface_Analyses/rh.fwhm12.fsaverage.cbf_s.mgh:overlay_threshold=100,150 \
/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.white\
:overlay=/NAS/tupac/protocoles/healthy_volunteers//FS53/550524JPC280116^X_SUJET_SAIN_2016-01-28/ASL/bbr/Surface_Analyses/rh.fwhm12.fsaverage.cbf_s.mgh:overlay_threshold=100,150 

freeview -f \
/home/global/freesurfer5.3/subjects/fsaverage/surf/lh.mid\
:overlay=/NAS/tupac/protocoles/healthy_volunteers//FS53/550524JPC280116^X_SUJET_SAIN_2016-01-28/ASL/bbr/Surface_Analyses/rh.fwhm12.fsaverage.cbf_s.mgh:overlay_threshold=100,150 \
/home/global/freesurfer5.3/subjects/fsaverage/surf/rh.mid\
:overlay=/NAS/tupac/protocoles/healthy_volunteers//FS53/550524JPC280116^X_SUJET_SAIN_2016-01-28/ASL/bbr/Surface_Analyses/rh.fwhm12.fsaverage.cbf_s.mgh:overlay_threshold=100,150

#TRACTO
mrview /NAS/tupac/protocoles/healthy_volunteers/FS53/T02S02/mri/T1.mgz -tractography.load  /NAS/tupac/protocoles/healthy_volunteers/FS53/T02S02/dti/whole_brain_6_1500000_part000132.tck

exit 
