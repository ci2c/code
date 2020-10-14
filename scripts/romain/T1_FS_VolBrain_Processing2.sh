#! /bin/bash

#https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all
#http://www.alivelearn.net/?p=175
#https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/TroubleshootingData 
#https://surfer.nmr.mgh.harvard.edu/fswiki/TkMeditGuide/TkMeditWorkingWithData/FreeviewSegmentations

aide="\n*********************************\n"
aide+="***T1_FS_VolBrain_Processing.sh**\n"
aide+="*********************************\n"
aide+="Usage : T1_FS_VolBrain_Processing -sd [PATH]-subj [NAME] -VolBrain_Zip [FILE]\n"
aide+="    -sd : path to the subject dir\n"
aide+="    -subj : subject name\n"
aide+="    -VolBrain_Zip : path to the zip file provided by VolBrain\n"
aide+="\nExample :\n"
aide+="bash T1_FS_VolBrain_Processing.sh -sd /NAS/tupac/romain/FS_VolBrain/FS60  -subj bibi -VolBrain_Zip /NAS/tupac/romain/FS_VolBrain/T01S01/native_20160404_154949WIP3DT1CLEARs201a1002.nii.gz_job87232010618092611.zip >& log.txt\n"
aide+="\nGood luck, ask for help to Romain VIARD"

if [ $# -lt 6 ]
then
	echo -e ${aide}
	exit 1
fi

T2wInputImage="NONE"
FlairInputImage="NONE"
index=1
while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo -e ${aide}
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval StudyFolder=\${$index}
		echo "SUBJECTS_DIR folder : ${StudyFolder}"
		;;
	-subj)
		index=$[$index+1]
		eval Subject=\${$index}
		echo "Subject id : ${Subject}"
		;;
	-t1)
		index=$[$index+1]
		eval T1wInputImage=\${$index}
		echo "T1w image : ${T1wInputImage}"
		;;
	-VolBrain_Zip)
		index=$[$index+1]
		eval VolBrain_Zip=\${$index}
		echo "VolBrain zip file : ${VolBrain_Zip}"
		;;
	-t2)
		index=$[$index+1]
		eval T2wInputImage=\${$index}
		echo "T2w image : ${T2wInputImage}"
		;;
	-flair)
		index=$[$index+1]
		eval FlairInputImage=\${$index}
		echo "Flair image : ${FlairInputImage}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo "...."
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${VolBrain_Zip} ]
then
	 echo "-VolBrain_Zip argument mandatory"
	 exit 1
fi

if [ -z ${StudyFolder} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${Subject} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

VolBrain_Path="/tmp/`date +%N`/"
cmd="unzip $VolBrain_Zip -d $VolBrain_Path"
echo $cmd ; eval $cmd

cmd="ls ${VolBrain_Path}native_n_*.nii"
T1wInputImage=`eval $cmd`

cmd="ls ${VolBrain_Path}native_mask_*.nii"
T1wImageBrain=`eval $cmd`

cmd="ls ${VolBrain_Path}native_hemi_*.nii"
T1wImageHemi=`eval $cmd`

cmd="ls ${VolBrain_Path}native_crisp_*.nii"
T1wImageWM=`eval $cmd`

cmd="ls ${VolBrain_Path}native_lab_*.nii"
T1wImageAseg=`eval $cmd`

# ------------------------------------------------------------------------------
#  CONFIG
# ------------------------------------------------------------------------------

# Compress if not
filename=$(basename "$T1wInputImage")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wInputImage; T1wInputImage=${T1wInputImage}.gz; fi

filename=$(basename "$T1wImageBrain")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wImageBrain; T1wImageBrain=${T1wImageBrain}.gz; fi

filename=$(basename "$T1wImageAseg")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wImageAseg; T1wImageAseg=${T1wImageAseg}.gz; fi

filename=$(basename "$T1wImageWM")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wImageWM; T1wImageWM=${T1wImageWM}.gz; fi

filename=$(basename "$T1wImageHemi")
extension="${filename##*.}"
if [ "${extension}" == "nii" ]; then gzip -f $T1wImageHemi; T1wImageHemi=${T1wImageHemi}.gz; fi

if [ $T2wInputImage != "NONE" ] ; then
	filename=$(basename "$T2wInputImage")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $T2wInputImage; T2wInputImage=${T2wInputImage}.gz; fi
fi

if [ $FlairInputImage != "NONE" ] ; then
	filename=$(basename "$FlairInputImage")
	extension="${filename##*.}"
	if [ "${extension}" == "nii" ]; then gzip -f $FlairInputImage; FlairInputImage=${FlairInputImage}.gz; fi
fi

# ------------------------------------------------------------------------------
#  Show Environment Variables
# ------------------------------------------------------------------------------
echo -e "\n START: T1_FSProcessing.sh \n"
echo -e "FSLDIR: ${FSLDIR}"
echo -e "FreeSurfer: $FREESURFER_HOME"
echo "T1w image : ${T1wInputImage}"
echo "Intracranial cavity mask : ${T1wImageBrain}"
echo "Macro-structure label : ${T1wImageHemi}"
echo "Hard tissue segmentation : ${T1wImageWM}"
echo "Subcortical segmentation : ${T1wImageAseg}"

T1wImageFile=`remove_ext $T1wInputImage`;
T1wImageBrainFile=`remove_ext $T1wImageBrain`;
T1wImageAsegFile=`remove_ext $T1wImageAseg`;
T1wImageWMFile=`remove_ext $T1wImageWM`;
T1wImageHemiFile=`remove_ext $T1wImageHemi`;

#T1wImageFile=`basename -s .nii.gz $T1wInputImage`;
#T1wImageBrainFile=`basename -s .nii.gz $T1wImageBrain`;
#T1wImageAsegFile=`basename -s .nii.gz $T1wImageAseg`;
#T1wImageWMFile=`basename -s .nii.gz $T1wImageWM`;
#T1wImageHemiFile=`basename -s .nii.gz $T1wImageHemi`;

echo -e "\n T1wImageFile="${T1wImageFile}""
echo -e "T1wImageBrainFile="${T1wImageBrainFile}""
echo -e "T1wImageAsegFile="${T1wImageAsegFile}""
echo -e "T1wImageWMFile="${T1wImageWMFile}""
echo -e "T1wImageHemiFile="${T1wImageHemiFile}""

#Make Spline Interpolated Downsample to 1mm
echo -e "\n Make Spline Interpolated Downsample to 1mm"

#Mean=`fslstats $T1wImageBrain -M`

cmd="flirt -interp spline -in ${T1wInputImage} -ref ${T1wInputImage} -applyisoxfm 1 -out ${T1wImageFile}_1mm.nii.gz"
echo $cmd ; eval $cmd

cmd="applywarp --rel --interp=spline -i ${T1wInputImage} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageFile}_1mm.nii.gz"
echo $cmd ; eval $cmd

cmd="mri_convert ${T1wImageFile}_1mm.nii.gz ${T1wImageFile}_conf_1mm.nii.gz --out_orientation LIA -rt interpolate --conform --no_scale 1;"
echo $cmd ; eval $cmd
#flirt -in myimage -ref myimage -applyisoxfm 1 -out myimage_1mm

cmd="applywarp --rel --interp=nn -i ${T1wImageBrain} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageBrainFile}_1mm.nii.gz"
echo $cmd ; eval $cmd
cmd="mri_convert ${T1wImageBrainFile}_1mm.nii.gz ${T1wImageBrainFile}_conf_1mm.nii.gz --out_orientation LIA -rt nearest --conform --no_scale 1;"
echo $cmd ; eval $cmd

cmd="applywarp --rel --interp=nn -i ${T1wImageAseg} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageAsegFile}_1mm.nii.gz"
echo $cmd ; eval $cmd
cmd="mri_convert ${T1wImageAsegFile}_1mm.nii.gz ${T1wImageAsegFile}_conf_1mm.nii.gz --out_orientation LIA -rt nearest --conform --no_scale 1;"
echo $cmd ; eval $cmd

cmd="applywarp --rel --interp=nn -i ${T1wImageWM} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageWMFile}_1mm.nii.gz"
echo $cmd ; eval $cmd
cmd="mri_convert ${T1wImageWMFile}_1mm.nii.gz ${T1wImageWMFile}_conf_1mm.nii.gz --out_orientation LIA -rt nearest --conform --no_scale 1;"
echo $cmd ; eval $cmd

cmd="applywarp --rel --interp=nn -i ${T1wImageHemi} -r ${T1wImageFile}_1mm.nii.gz --premat=$FSLDIR/etc/flirtsch/ident.mat -o ${T1wImageHemiFile}_1mm.nii.gz"
echo $cmd ; eval $cmd
cmd="mri_convert ${T1wImageHemiFile}_1mm.nii.gz ${T1wImageHemiFile}_conf_1mm.nii.gz --out_orientation LIA -rt nearest --conform --no_scale 1;"
echo $cmd ; eval $cmd

#RV pas compris le pourquoi, il faudrait creuser à savoir si necessaire et si oui faut il le faire aux autres images...( a mon avis faisable que pour des images NDG et non des label car la moyenne ne voudrait rien dire...)
#cmd="fslmaths ${T1wImageFile}_conf_1mm.nii.gz -div $Mean -mul 150 -abs ${T1wImageFile}_norm_conf_1mm.nii.gz"
#echo $cmd ; eval $cmd

# Create SUBJECTS_DIR folder
echo -e "\n Create SUBJECTS_DIR folder"
if [ ! -d ${StudyFolder} ]; then mkdir ${StudyFolder}; fi

# transformation of the binary brain mask in a T1W mask
fslmaths ${T1wImageBrainFile}_conf_1mm.nii.gz -bin -mul ${T1wImageFile}_conf_1mm.nii.gz ${VolBrain_Path}NDG_mask.nii.gz
T1wImageBrain="${VolBrain_Path}NDG_mask.nii.gz"

# ------------------------------------------------------------------------------
#  PROCESSING
# ------------------------------------------------------------------------------
echo -e "\n FreeSurfer Processing \n"
echo -e "\n"
echo -e "\n Initial Recon-all : Step 1 & 2 "

echo -e "\n First recon-all \n"

cmd="recon-all -all -i ${T1wImageFile}_1mm.nii.gz -autorecon1 -autorecon2 -subjid $Subject -sd $StudyFolder -nuintensitycor-3T"
echo $cmd ; eval $cmd

echo -e "\n Mix VolBrain and Freesurfer using Python \n"

# Generate brain mask
cmd="mri_convert ${T1wImageBrainFile}_1mm.nii.gz ${StudyFolder}/${Subject}/mri/brainmask.mgz --conform"
echo $cmd ; eval $cmd

crisp=`ls ${VolBrain_Path}/native_crisp_mmni_fjob*_conf_1mm.nii.gz`
hemi=`ls ${VolBrain_Path}/native_hemi_n_mmni_fjob*_conf_1mm.nii.gz`
lab=`ls ${VolBrain_Path}/native_lab_n_mmni_fjob*_conf_1mm.nii.gz`

cmd="/home/global/anaconda2/bin/python /home/romain/SVN/python/romain/replace_FSbyVolBrain.py ${VolBrain_Path} ${StudyFolder}/${Subject}/mri/ ${crisp} ${hemi} ${lab}"
echo $cmd ; eval $cmd

#https://surfer.nmr.mgh.harvard.edu/fswiki/TkMeditGuide/TkMeditWorkingWithData/FreeviewSegmentations

cmd="mri_convert ${VolBrain_Path}new_aseg.nii.gz ${StudyFolder}/${Subject}/mri/aseg.presurf.mgz --conform -rt nearest --no_scale 1 -odt uchar"
echo $cmd ; eval $cmd

cmd="mri_convert ${VolBrain_Path}new_ribbon.nii.gz  ${StudyFolder}/${Subject}/mri/ribbon.mgz --conform -rt nearest --no_scale 1 -odt uchar"
echo $cmd ; eval $cmd

cmd="mri_convert ${VolBrain_Path}new_wm.nii.gz ${StudyFolder}/${Subject}/mri/wm.mgz --conform -rt nearest --no_scale 1 -odt uchar"
echo $cmd ; eval $cmd

echo -e "\n Second recon-all : Step 2 and 3 \n"

#https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/TroubleshootingData 
#cmd="recon-all  -make all -subjid $Subject -sd $StudyFolder -nuintensitycor-3T"
cmd="recon-all  -autorecon2-wm -autorecon3 -subjid $Subject -sd $StudyFolder -nuintensitycor-3T"
echo $cmd ; eval $cmd

cmd="cp ${StudyFolder}/${Subject}/surf/lh.smoothwm ${StudyFolder}/${Subject}/surf/lh.old.smoothwm"
#echo $cmd ; eval $cmd

cmd="mris_smooth ${StudyFolder}/${Subject}/surf/lh.white ${StudyFolder}/${Subject}/surf/lh.smoothwm"
#echo $cmd ; eval $cmd

cmd="cp ${StudyFolder}/${Subject}/surf/rh.smoothwm ${StudyFolder}/${Subject}/surf/rh.old.smoothwm"
#echo $cmd ; eval $cmd

cmd="mris_smooth ${StudyFolder}/${Subject}/surf/lh.white ${StudyFolder}/${Subject}/surf/rh.smoothwm"
#echo $cmd ; eval $cmd

cmd="SUBJECT_DIR=${StudyFolder}"
#echo $cmd ; eval $cmd

cmd="mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ${StudyFolder}/${Subject}/mri/aseg.presurf -mgz -T1 brain.finalsurfs ${Subject} lh"
#echo $cmd ; eval $cmd

cmd="mris_make_surfaces -orig_white white.preaparc -orig_pial white.preaparc -aseg ${StudyFolder}/${Subject}/mri/aseg.presurf -mgz -T1 brain.finalsurfs ${Subject} rh"
#echo $cmd ; eval $cmd

#Programme permettant de mettre les valeurs des overlay "curv" et "area" du medial wall à 0
cmd="/home/global/anaconda2/bin/python /home/romain/SVN/python/romain/FS_curv_modification.py ${StudyFolder}/${Subject}"
echo $cmd ; eval $cmd

cmd="rm -rf ${VolBrain_Path}"
echo $cmd ; eval $cmd

#ONLY USE FOLLOWING CMD FOR TEST PURPOSE

#freeview \
#/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/mri/aseg.mgz:colormap=lut \
#/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/mri/wm.mgz:colormap=heatscale \
#/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/mri/ribbon.mgz:colormap=lut \
#/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/mri/aseg.mgz:colormap=lut \
#/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/mri/wm.mgz:colormap=heatscale \
#/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/mri/ribbon.mgz:colormap=lut \
#-f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.white:color=blue \
#-f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.white:color=yellow \
#-f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/rh.white:color=blue \
#-f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/rh.white:color=yellow



#freeview -f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.white:overlay=/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.curv

#freeview -f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.white:label=/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/label/lh.cortex.label

#freeview \
#-f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.smoothwm:overlay=/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.curv \
#-f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.smoothwm:overlay=/NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/lh.curv


#freeview -f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.white:overlay=/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.sulc
#freeview -f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.white:label=/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/label/lh.cortex.label

#freeview -f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.pial:overlay=/NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/lh.sulc

#freeview \
#-f /NAS/tupac/romain/FS_VolBrain/FS60/bibiNew/surf/rh.white:color=blue \
#-f /NAS/tupac/protocoles/healthy_volunteers/FS53/T01S01/surf/rh.white:color=yellow



