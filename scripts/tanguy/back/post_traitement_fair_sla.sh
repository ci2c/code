#! /bin/bash

if [ $# -lt 6 ]
then
		echo ""
		echo "Usage: post_traitement_fair_sla.sh -sd <SUBJECTS_DIR> -subj <SUBJ> -rd <ROIDIR>"
		echo ""
		echo " -sd				: Subjects Dir : directory containing the patient folder"
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo " -rd				: directory containing Freesurfer and manual roi"
		echo ""
		echo "Usage: post_traitement_fair_sla.sh -sd <SUBJECTS_DIR> -subj <SUBJ> -rd <ROIDIR>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
fi


index=1


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo ""
		echo "Usage: post_traitement_fair_sla.sh -sd <SUBJECTS_DIR> -subj <SUBJ> -rd <ROIDIR>"
		echo ""
		echo " -sd				: Subjects Dir : directory containing the patient folder"
		echo ""
		echo " -subj				: Subj ID"
		echo ""
		echo " -rd				: directory containing Freesurfer and manual roi"
		echo ""
		echo "Usage: post_traitement_fair_sla.sh -sd <SUBJECTS_DIR> -subj <SUBJ> -rd <ROIDIR>"
		echo ""
		echo "Author: Tanguy Hamel - CHRU Lille - 2013"
		echo ""
		exit 1
		;;
	-sd)
		
		SD=`expr $index + 1`
		eval SD=\${$SD}
		echo "SUBJ_DIR : $SD"
		;;

	-subj)
		
		SUBJ=`expr $index + 1`
		eval SUBJ=\${$SUBJ}
		echo "SUBJ : $SUBJ"
		;;

	-rd)
		
		roidir=`expr $index + 1`
		eval roidir=\${$roidir}
		echo "ROI DIR : $roidir"
		;;

	
	esac
	index=$[$index+1]
done

echo ""
echo ""
echo ""
echo ""
echo "run post_traitement_fair_sla"
echo ""
echo "Author: Tanguy Hamel - CHRU Lille - 2013"
echo ""
echo ""
echo ""


# test présence roidir/Freesurfer

if [ ! -d $roidir/Freesurfer ]
then
	echo ""
	echo ""
	echo "pas de dossier $roidir/Freesurfer"
	echo ""
	echo ""
	exit
fi

# test présence SD/SUBJ

if [ ! -d $SD/$SUBJ ]
then
	echo ""
	echo ""
	echo "pas de dossier patient : "
	echo ""
	echo "$SD/$SUBJ"
	echo ""
	echo ""
	exit
fi


## extraction des volumes ROI à partir de la segmentation Freesurfer

echo ""
echo ""
echo "extraction des ROI à partir de la segmentation Freesurfer"
echo ""
echo ""

for roi_name in `ls $roidir/Freesurfer`
do
	echo ""
	echo "extraction de :"
	echo "$roi_name"
	echo ""

	echo "mri_extract_label $SD/$SUBJ/mri/aparc.a2009s+aseg.mgz `cat $roidir/Freesurfer/$roi_name` $SD/$SUBJ/mri/${roi_name}.nii"
	mri_extract_label $SD/$SUBJ/mri/aparc.a2009s+aseg.mgz `cat $roidir/Freesurfer/$roi_name` $SD/$SUBJ/mri/${roi_name}.nii
done


## extraction des volumes ROI à partir des segmentations manuelles

echo ""
echo ""
echo "extration des volumes ROI à partir des segmentations manuelles"
echo ""
echo ""

if [ -f $roidir/Manual/list.txt ]
then
	echo "extraction des ROI à partir de la segmentation manuelle"

	for roi_name in `cat $roidir/Manual/list.txt`	
	do
		echo ""
		echo "extraction de :"
		echo "$roi_name"
		echo ""
	
		echo "mri_label2vol --label $SD/$SUBJ/label/$roi_name --regheader $SD/$SUBJ/mri/T1orient.nii --temp $SD/$SUBJ/mri/T1orient.nii --o $SD/$SUBJ//mri/${roi_name}_vol.nii"
		mri_label2vol --label $SD/$SUBJ/label/$roi_name --regheader $SD/$SUBJ/mri/T1orient.nii --temp $SD/$SUBJ/mri/T1orient.nii --o $SD/$SUBJ//mri/${roi_name}_vol.nii

	done	
else
	echo ""
	echo "pas de segmentation manuelle"
	echo "pas de fichier $SD/ROI/Manual/list.txt"

fi


## recalage des T2 et T2 map

echo ""
echo ""
echo "recalage des T2 et T2 map"
echo ""
echo ""

if [ -f $SD/$SUBJ/mri/T2toT1.xfm ]
then

	echo "mincresample –like $SD/$SUBJ/mri/T1orient.mnc –transformation $SD/$SUBJ/mri/T2toT1.xfm $SD/$SUBJ/mri/T2first_ras.mnc $SD/$SUBJ/mri/T2toT1.mnc  -clob"

	mincresample -like $SD/$SUBJ/mri/T1orient.mnc -transformation $SD/$SUBJ/mri/T2toT1.xfm $SD/$SUBJ/mri/T2first_ras.mnc $SD/$SUBJ/mri/T2toT1.mnc -clobber

	echo "mincresample –like $SD/$SUBJ/mri/T1orient.mnc –transformation $SD/$SUBJ/mri/T2toT1.xfm $SD/$SUBJ/mri/3DT2map.mnc $SD/$SUBJ/mri/T2maptoT1.mnc  -clob"

	mincresample -like $SD/$SUBJ/mri/T1orient.mnc -transformation $SD/$SUBJ/mri/T2toT1.xfm $SD/$SUBJ/mri/3DT2map.mnc $SD/$SUBJ/mri/T2maptoT1.mnc  -clobber

	echo "mri_convert $SD/$SUBJ/mri/T2maptoT1.mnc  $SD/$SUBJ/mri/T2maptoT1.nii"

	mri_convert $SD/$SUBJ/mri/T2maptoT1.mnc  $SD/$SUBJ/mri/T2maptoT1.nii
else

	echo "besoin du fichier $SD/$SUBJ/mri/T2toT1.xfm pour la transformation"
	
fi


## recalage automatique et stats sous matlab

echo ""
echo ""
echo "recalage automatique et stats sous matlab : "
echo ""
echo ""

echo "mri_convert $SD/$SUBJ/mri/orig.mgz $SD/$SUBJ/mri/T1_fs.nii"
mri_convert $SD/$SUBJ/mri/orig.mgz $SD/$SUBJ/mri/T1_fs.nii

echo "rm -f $SD/$SUBJ/mri/results.txt"
echo "touch $SD/$SUBJ/mri/results.txt"
rm -f $SD/$SUBJ/mri/results.txt
touch $SD/$SUBJ/mri/results.txt

matlab -nodisplay <<EOF

	addpath('~/SVN/matlab/tanguy/fairsla');

	spm_jobman('initcfg');

	matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'$SD/$SUBJ/mri/T1orient.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.source = {'$SD/$SUBJ/mri/T2first_ras.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.other = {'$SD/$SUBJ/mri/T2maptoT1.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];
	
	inputs = cell(0, 1);
	spm('defaults', 'PET');
	spm_jobman('serial', matlabbatch, '', inputs{:});


	list=compute_list_roi('$roidir')	
	CoregT1FsToT1Map('$SD/$SUBJ/mri/',list)
	ResliceROI('$SD/$SUBJ/mri/',list)
	stats=ComputeStatsOnT2map('$SD/$SUBJ/mri/',list);
	write_results_fair_sla('$SD','$SUBJ',stats)
	save(fullfile('$SD/$SUBJ/mri','results_fs.mat'),'stats');
EOF



