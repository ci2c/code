#! /bin/bash

Subjects_dir='/NAS/tupac/protocoles/Strokdem/FS5.1'
SUBJECTS_DIR='/NAS/tupac/protocoles/Strokdem/FS5.1_T2mask'
T2_DIR='/NAS/tupac/protocoles/Strokdem/T2'
Files='/home/clement/SVN/scripts/clement/FreesurferT2mask.txt'


#Dans le fichier Files faire une liste des dossier à recalculer

while read subjid
do
	#echo $subjid
	if [ -e $Subjects_dir/$subjid ] & [ -e $T2_DIR/$subjid/T1_brain_mask_final.mgz ]
	then
		echo $subjid
		cp -rf $Subjects_dir/$subjid $SUBJECTS_DIR/$subjid
		cp $T2_DIR/$subjid/T1_brain_mask_final.mgz $SUBJECTS_DIR/$subjid/mri/brainmask.mgz
		qbatch -q fs_q -oe /home/clement/log/ -N fs2_$subjid recon-all -subjid $subjid -sd $SUBJECTS_DIR -autorecon2 -autorecon3 -no-isrunning
	fi
done < $Files
