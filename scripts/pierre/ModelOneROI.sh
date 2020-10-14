#!/bin/bash

# Pierre Besson @ CHRU Lille, 2010 - 2011
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
	echo ""
	echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
	echo "  -subj <subj_id>                      : Subject ID"
	echo "  -sname <structure_name>              : Name of the subcortical structure"
	echo "  -sid <structure_id>                  : ID of the subcotical structure"
	echo ""
	echo "Options :"
	echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
	echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
	echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
	echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
	echo " "
	echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
	echo ""
	exit 1
fi

index=1
imres=1
tmpdir=/tmp/
segvol="aparc.a2009s+aseg.mgz"
volres=1
nb_close=2

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo "  -sname <structure_name>              : Name of the subcortical structure"
		echo "  -sid <structure_id>                  : ID of the subcotical structure"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
		echo " "
		echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
		echo ""
		exit 1
		;;
	-fs)
		fs=`expr $index + 1`
		eval fs=\${$fs}
		echo "|> FS dir           : $fs"
		;;
	-subj)
		subj=`expr $index + 1`
		eval subj=\${$subj}
		echo "|> Subject          : $subj"
		;;
	-sname)
		sname=`expr $index + 1`
		eval sname=\${$sname}
		echo "|> Structure name   : $sname"
		;;
	-sid)
		sid=`expr $index + 1`
		eval sid=\${$sid}
		echo "|> Structure ID     : $sid"
		;;
	-tmp)
		tmpdir=`expr $index + 1`
		eval tmpdir=\${$tmpdir}
		echo "|> Temp dir         : $tmpdir"
		;;
	-res)
		volres=`expr $index + 1`
		eval volres=\${$volres}
		echo "|> Image resolution  : $volres"
		;;
	-close)
		nb_close=`expr $index + 1`
		eval nb_close=\${$nb_close}
		echo "|> Close operations  : $nb_close"
		;;
	-segvol)
		segvol=`expr $index + 1`
		eval segvol=\${$segvol}
		echo "|> Segmentation vol. : $segvol"
		;;
	-*)
		Arg=`expr $index`
		eval Arg=\${$Arg}
		echo "Unknown argument ${Arg}"
		echo ""
		echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
		echo ""
		echo "  -fs <fs_dir>                         : Path to Freesurfer outdir, i.e. SUBJECTS_DIR"
		echo "  -subj <subj_id>                      : Subject ID"
		echo "  -sname <structure_name>              : Name of the subcortical structure"
		echo "  -sid <structure_id>                  : ID of the subcotical structure"
		echo ""
		echo "Options :"
		echo "  -tmp <temp_dir>                      : Path to directory for temp computations. Default = /tmp/"
		echo "  -segvol <segmentation_volume>        : Segmentation to use. Default = aparc.a2009s+aseg.mgz"
		echo "  -resolution <resolution>             : Image isotropic resolution (in  mm) for intermediate calculations. Default = 1"
		echo "  -close <nb_close>                    : Size of the close operator for label morphological operation. Default = 2"
		echo " "
		echo "Usage: ModelOneROI.sh  -fs <fs_dir>  -subj <subj_id>  -sname <structure_name>  -sid <structure_id>  [-tmp <temp_dir>  -segvol <segmentation_volume>  -res <resolution>  -close <nb_close>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

# Set some cool variables
DIR=${fs}/${subj}
tmps=${tmpdir}/${subj}
labdir=${tmps}/my_label
SUBJECTS_DIR=${tmpdir}

# Copy data to temp dir
echo "cp -Rf ${DIR} ${tmpdir}"
cp -Rf ${DIR} ${tmpdir}

# Create some cool dir
if [ ! -d ${labdir} ]
then
	mkdir ${labdir}
else
	rm -rf ${labdir}
	mkdir ${labdir}
fi

# Extract label of interest
echo "mri_extract_label ${DIR}/mri/${segvol} ${sid} ${labdir}/label_orig.mgz"
mri_extract_label ${DIR}/mri/${segvol} ${sid} ${labdir}/label_orig.mgz

# Remove useless files
echo "**** Removing useless files ****"
rm -rf ${tmps}/surf ${tmps}/epilepsy ${tmps}/dti
mkdir ${tmps}/surf
rm -f ${tmps}/mri/aparc+aseg.mgz 
rm -f ${tmps}/mri/aparc.a2009s+aseg.mgz 
rm -f ${tmps}/mri/aseg.auto.mgz 
rm -f ${tmps}/mri/aseg.auto_noCCseg.label_intensities.txt 
rm -f ${tmps}/mri/aseg.auto_noCCseg.mgz 
rm -f ${tmps}/mri/brain.finalsurfs.mgz 
rm -f ${tmps}/mri/brainmask.auto.mgz 
rm -f ${tmps}/mri/brainmask.mgz 
rm -f ${tmps}/mri/ctrl_pts.mgz 
rm -f ${tmps}/mri/filled.mgz 
rm -f ${tmps}/mri/lh.dpial.ribbon.mgz 
rm -f ${tmps}/mri/lh.dwhite.ribbon.mgz 
rm -f ${tmps}/mri/lh.ribbon.mgz 
rm -f ${tmps}/mri/mri_nu_correct.mni.log 
rm -f ${tmps}/mri/rh.dpial.ribbon.mgz 
rm -f ${tmps}/mri/rh.dwhite.ribbon.mgz 
rm -f ${tmps}/mri/rh.ribbon.mgz 
rm -f ${tmps}/mri/ribbon.mgz 
rm -f ${tmps}/mri/segment.dat 
rm -f ${tmps}/mri/wm.asegedit.mgz 
rm -f ${tmps}/mri/wm.mgz 
rm -f ${tmps}/mri/wm.seg.mgz 
rm -f ${tmps}/mri/wmparc.mgz

# Resample volumes to $volres if necessary
if [ ! "${volres}" == "1" ]
then
	echo "**** Resampling Volumes ****"
	# Brain volumes
	mri_convert ${tmps}/mri/brain.mgz ${tmps}/mri/brain_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mri_convert ${tmps}/mri/norm.mgz ${tmps}/mri/norm_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mri_convert ${tmps}/mri/nu.mgz ${tmps}/mri/nu_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mri_convert ${tmps}/mri/orig.mgz ${tmps}/mri/orig_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mri_convert ${tmps}/mri/T1.mgz ${tmps}/mri/T1_${volres}.mgz -vs ${volres} ${volres} ${volres}
	
	mv ${tmps}/mri/brain.mgz ${tmps}/mri/brain_orig.mgz
	mv ${tmps}/mri/norm.mgz ${tmps}/mri/norm_orig.mgz
	mv ${tmps}/mri/nu.mgz ${tmps}/mri/nu_orig.mgz
	mv ${tmps}/mri/orig.mgz ${tmps}/mri/orig_orig.mgz
	mv ${tmps}/mri/T1.mgz ${tmps}/mri/T1_orig.mgz
	
	mv ${tmps}/mri/brain_${volres}.mgz ${tmps}/mri/brain.mgz
	mv ${tmps}/mri/norm_${volres}.mgz ${tmps}/mri/norm.mgz
	mv ${tmps}/mri/nu_${volres}.mgz ${tmps}/mri/nu.mgz
	mv ${tmps}/mri/orig_${volres}.mgz ${tmps}/mri/orig.mgz
	mv ${tmps}/mri/T1_${volres}.mgz ${tmps}/mri/T1.mgz
	
	# Extracted label
	mri_convert ${labdir}/label_orig.mgz ${labdir}/label_orig_${volres}.mgz -vs ${volres} ${volres} ${volres}
	mv ${labdir}/label_orig_${volres}.mgz ${labdir}/label.mgz
else
	mv ${labdir}/label_orig.mgz ${labdir}/label.mgz
fi

# Close & binarize extracted label
echo "mri_morphology ${labdir}/label.mgz close ${nb_close} ${labdir}/label_close.mgz"
mri_morphology ${labdir}/label.mgz close ${nb_close} ${labdir}/label_close.mgz
# if [ ${caudate} -eq 0 ]
# then
#	echo "mri_morphology ${labdir}/label.mgz close ${nb_close} ${labdir}/label_close.mgz"
#	mri_morphology ${labdir}/label.mgz close ${nb_close} ${labdir}/label_close.mgz
# else
#	echo "mri_morphology ${labdir}/label.mgz dilate 3 ${labdir}/temp.mgz"
#	mri_morphology ${labdir}/label.mgz dilate 3 ${labdir}/temp.mgz
#	
#	echo "mri_morphology ${labdir}/temp.mgz erode 2 ${labdir}/label_close.mgz"
#	mri_morphology ${labdir}/temp.mgz erode 2 ${labdir}/label_close.mgz
#	
#	rm -f ${labdir}/temp.mgz
#fi
echo "mri_binarize --i ${labdir}/label_close.mgz --o ${labdir}/label_close_bin.mgz --min 0.1 --max inf"
mri_binarize --i ${labdir}/label_close.mgz --o ${labdir}/label_close_bin.mgz --min 0.1 --max inf

# Extract ROI surface
cp ${labdir}/label_close_bin.mgz ${tmps}/mri/wm.asegedit.mgz

cd ${tmps}/mri
mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz
cp wm.mgz filled.mgz

echo "mri_tessellate ../mri/wm.mgz 1 ../surf/lh.orig.nofix"
mri_tessellate ../mri/wm.mgz 1 ../surf/lh.orig.nofix

echo "mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix"
mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix

echo "mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix"
mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix

echo "mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix"
mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix

echo "mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix"
mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix

echo "cp ../surf/lh.orig.nofix ../surf/lh.orig"
cp ../surf/lh.orig.nofix ../surf/lh.orig 

echo "cp ../surf/lh.inflated.nofix ../surf/lh.inflated "
cp ../surf/lh.inflated.nofix ../surf/lh.inflated

echo "mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 ${subj} lh"
mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 ${subj} lh

echo "mris_euler_number ../surf/lh.orig"
mris_euler_number ../surf/lh.orig

echo "mris_remove_intersection ../surf/lh.orig ../surf/lh.orig "
mris_remove_intersection ../surf/lh.orig ../surf/lh.orig 

echo "rm ../surf/lh.inflated"
rm ../surf/lh.inflated

echo "mri_mask ../mri/T1.mgz ${labdir}/label_close_bin.mgz ../mri/brain.finalsurfs.mgz"
mri_mask ../mri/T1.mgz ${labdir}/label_close_bin.mgz ../mri/brain.finalsurfs.mgz

echo "mris_make_surfaces -noaparc -mgz -T1 brain.finalsurfs ${subj} lh"
mris_make_surfaces -noaparc -mgz -T1 brain.finalsurfs ${subj} lh

echo "mris_smooth ../surf/lh.white ../surf/lh.smoothwm"
mris_smooth ../surf/lh.white ../surf/lh.smoothwm

## Added
echo "mris_smooth ../surf/lh.smoothwm ../surf/lh.smoothwm2"
mris_smooth ../surf/lh.smoothwm ../surf/lh.smoothwm2
##

echo "mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated "
mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated 

echo "mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated"
mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated

echo "mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere"
mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere

# Copy data to original directory
echo "mv -f ${tmps}/surf ${DIR}/${sname}"
mv -f ${tmps}/surf ${DIR}/${sname}


