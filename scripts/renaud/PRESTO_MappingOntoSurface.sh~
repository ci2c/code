#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -o                           : output folder "
	echo "  -s                           : method for smoothing "
	echo "  -surffwhm                    : smoothing value (surface) "
	echo ""
	echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
smooth=1
surffwhm=6

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output folder "
		echo "  -s                           : method for smoothing "
		echo "  -surffwhm                    : smoothing value (surface) "
		echo ""
		echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
		echo ""
		exit 1
		;;
	-sd)
		index=$[$index+1]
		eval SD=\${$index}
		echo "SD : $SD"
		;;
	-subj)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subj : $SUBJ"
		;;
	-epi)
		index=$[$index+1]
		eval epi=\${$index}
		echo "fMRI file : $epi"
		;;
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output folder : $output"
		;;
	-s)
		index=$[$index+1]
		eval smooth=\${$index}
		echo "method for smoothing : ${smooth}"
		;;
	-surffwhm)
		index=$[$index+1]
		eval surffwhm=\${$index}
		echo "smoothing value in surface : ${surffwhm}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -o                           : output folder "
		echo "  -s                           : method for smoothing "
		echo "  -surffwhm                    : smoothing value (surface) "
		echo ""
		echo "Usage: PRESTO_MappingOntoSurface.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -o <path>  [-s <value>  -surffwhm <value> ]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SD} ]
then
	 echo "-sd argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-subj argument mandatory"
	 exit 1
fi

if [ -z ${epi} ]
then
	 echo "-epi argument mandatory"
	 exit 1
fi

if [ -z ${output} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

if [ ! -d ${output} ]
then
	echo "mkdir ${output}"
	mkdir ${output}
fi

#=========================================================================================
#                              Project FMRI onto surface
#=========================================================================================

if [ ! -f ${DIR}/surf/lh.mid ]
then

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
	% Load Matlab Path
	p = pathdef;
	addpath(p);
	cd ${DIR}
	  
	inner_surf = SurfStatReadSurf('${DIR}/surf/lh.white');
	outer_surf = SurfStatReadSurf('${DIR}/surf/lh.pial');

	mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
	mid_surf.tri = inner_surf.tri;

	freesurfer_write_surf('${DIR}/surf/lh.mid', mid_surf.coord', mid_surf.tri);

	inner_surf = SurfStatReadSurf('${DIR}/surf/rh.white');
	outer_surf = SurfStatReadSurf('${DIR}/surf/rh.pial');

	mid_surf.coord = (inner_surf.coord + outer_surf.coord) ./ 2;
	mid_surf.tri = inner_surf.tri;

	freesurfer_write_surf('${DIR}/surf/rh.mid', mid_surf.coord', mid_surf.tri);
EOF

fi

if [ ! -f ${output}/register_epi2struct.dat ]
then
	echo "tkregister2 --mov ${epi} --s ${SUBJ} --regheader --noedit --reg ${output}/register_epi2struct.dat"
	tkregister2 --mov ${epi} --s ${SUBJ} --regheader --noedit --reg ${output}/register_epi2struct.dat
fi

if [ ! -f ${output}/surfepi_sm${smooth}.rh.nii ]
then

	if [ ${smooth} -eq 1 ]
	then
	
		# Left hemisphere
		echo "mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${output}/surfepi.lh.nii --noreshape --cortex --surfreg sphere.reg"
		mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${output}/surfepi.lh.nii --noreshape --cortex --surfreg sphere.reg
		 
		# Right hemisphere
		echo "mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${output}/surfepi.rh.nii --noreshape --cortex --surfreg sphere.reg"
		mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${output}/surfepi.rh.nii --noreshape --cortex --surfreg sphere.reg	
	
	else

		# Left hemisphere
		echo "mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${output}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}"
		mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi lh --o ${output}/surfepi_sm${smooth}.lh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}

		# Right hemisphere
		echo "mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${output}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}"
		mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --interp trilin --projfrac 0.5 --hemi rh --o ${output}/surfepi_sm${smooth}.rh.nii --noreshape --cortex --surfreg sphere.reg --surf-fwhm ${surffwhm}
	
	fi

fi

if [ ! -f ${output}/sm${surffwhm}_surfepi_fsaverage.rh.nii ]
then
	"Resampling EPI data to fsaverage and smoothing"
	"Left hemisphere"
	mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi lh --o ${output}/surfepi_fsaverage.lh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi lh --smooth-only --i ${output}/surfepi_fsaverage.lh.nii --fwhm ${surffwhm} --o ${output}/sm${surffwhm}_surfepi_fsaverage.lh.nii
	"Right hemisphere"
	mri_vol2surf --mov ${epi} --reg ${output}/register_epi2struct.dat --trgsubject fsaverage --interp trilin --projfrac 0.5 --hemi rh --o ${output}/surfepi_fsaverage.rh.nii --noreshape --cortex --surfreg sphere.reg
	mris_fwhm --s fsaverage --hemi rh --smooth-only --i ${output}/surfepi_fsaverage.rh.nii --fwhm ${surffwhm} --o ${output}/sm${surffwhm}_surfepi_fsaverage.rh.nii
fi


