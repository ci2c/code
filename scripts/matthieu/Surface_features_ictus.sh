#! /bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: Surface_features_ictus.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  [-comp]"
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo " Option :"
	echo "  -comp                            : Compute surface complexity (time consuming)"
	echo ""
	echo "Usage: Surface_features_ictus.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
	echo ""
	exit 1
fi


index=1
keeptmp=0
CFLAG=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Surface_features_ictus.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo " Option :"
		echo "  -comp                            : Compute surface complexity (time consuming)"
		echo ""
		echo "Usage: Surface_features_ictus.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>   [-comp]"
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
	
	-comp)
		CFLAG=1
		echo "-> Computes complexity"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Surface_features_ictus.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo " Option :"
		echo "  -comp                            : Compute surface complexity (time consuming)"
		echo ""
		echo "Usage: Surface_features_ictus.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>   [-comp]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Set up FreeSurfer (if not already done so in the running environment)
export FREESURFER_HOME=${Soft_dir}/freesurfer5.3/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

## Set up FSL (if not already done so in the running environment)
FSLDIR=${Soft_dir}/fsl50
. ${FSLDIR}/etc/fslconf/fsl.sh

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

# Create ictus directory if needed
if [ ! -d ${DIR}/ictus ]
then
	mkdir ${DIR}/ictus
else
	rm -Rf ${DIR}/ictus/*
fi



###########################################################################################################
		###                                                      ####
		 ##                                                      ###
		  # DATA PREPARATION & FEATURES EXTRACTION WHITHOUT BLUR #
		 ##                                                      ##
		###                                                      ###
###########################################################################################################







###########################################################################################################
					
					#T1#
					
###########################################################################################################



if [ ! -f ${DIR}/ictus/T1.mgz ]
then
	if [ -f ${DIR}/mri/T1.mgz ]
	then
		cp ${DIR}/mri/T1.mgz ${DIR}/ictus/T1.mgz
	else
		echo "need a T1 file -> ${DIR}/ictus/T1.mgz"
	fi
	
fi

	### Compute smooth T1 and gradient map
	echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/ictus/T1.mnc"
	mri_convert ${DIR}/mri/T1.mgz ${DIR}/ictus/T1.mnc

	echo "mincblur -fwhm 2 ${DIR}/ictus/T1.mnc ${DIR}/ictus/T1_2 -gradient -clobber"
	mincblur -fwhm 2 ${DIR}/ictus/T1.mnc ${DIR}/ictus/T1_2 -gradient -clobber

	echo "mri_convert ${DIR}/ictus/T1_2_blur.mnc ${DIR}/ictus/T1_2_blur.mgz"
	mri_convert ${DIR}/ictus/T1_2_blur.mnc ${DIR}/ictus/T1_2_blur.mgz

	echo "mri_convert ${DIR}/ictus/T1_2_dxyz.mnc ${DIR}/ictus/T1_2_dxyz.mgz"
	mri_convert ${DIR}/ictus/T1_2_dxyz.mnc ${DIR}/ictus/T1_2_dxyz.mgz

	rm -f ${DIR}/ictus/T1_2_dxyz.mnc ${DIR}/ictus/T1_2_blur.mnc ${DIR}/ictus/T1.mnc

	### ***********************************************************************************************************************
	### Project Gradient on surface
	echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz

	
	mv ${DIR}/surf/lh.dxyz ${DIR}/ictus/lh.dxyz
	mv ${DIR}/surf/rh.dxyz ${DIR}/ictus/rh.dxyz
	
	rm -f ${DIR}/surf/lh.dxyz.w ${DIR}/surf/rh.dxyz.w 

	# Resample Gradient to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.dxyz.mgh --tfmt curv

	
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.dxyz.mgh --tfmt curv
	

	### ***********************************************************************************************************************
	### Project T1 onto surface
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
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

	echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity

	mv ${DIR}/surf/lh.intensity ${DIR}/ictus/lh.intensity
	mv ${DIR}/surf/rh.intensity ${DIR}/ictus/rh.intensity
	
	rm -f ${DIR}/surf/lh.intensity.w ${DIR}/surf/rh.intensity.w

	# Resample Intensity to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.intensity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.intensity.mgh --tfmt curv


	### ***********************************************************************************************************************
	### Get cortical thickness stuffs
	cp -f ${DIR}/surf/lh.thickness ${DIR}/ictus/lh.thickness
	cp -f ${DIR}/surf/rh.thickness ${DIR}/ictus/rh.thickness
	cp -f ${DIR}/surf/lh.thickness.fwhm0.fsaverage.mgh ${DIR}/ictus/lh.fsaverage.thickness.mgh
	cp -f ${DIR}/surf/rh.thickness.fwhm0.fsaverage.mgh ${DIR}/ictus/rh.fsaverage.thickness.mgh
	

	### ***********************************************************************************************************************
	### Compute Depth stuffs
	echo "mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/ictus/lh.pial.mgz"
	mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/ictus/lh.pial.mgz

	echo "mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/ictus/rh.pial.mgz"
	mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/ictus/rh.pial.mgz

	echo "mri_morphology ${DIR}/ictus/lh.pial.mgz dilate 4 ${DIR}/ictus/lh.dilate.mgz"
	mri_morphology ${DIR}/ictus/lh.pial.mgz dilate 4 ${DIR}/ictus/lh.dilate.mgz

	echo "mri_morphology ${DIR}/ictus/rh.pial.mgz dilate 4 ${DIR}/ictus/rh.dilate.mgz"
	mri_morphology ${DIR}/ictus/rh.pial.mgz dilate 4 ${DIR}/ictus/rh.dilate.mgz

	echo "mri_morphology ${DIR}/ictus/lh.dilate.mgz erode 4 ${DIR}/ictus/lh.outer.mgz"
	mri_morphology ${DIR}/ictus/lh.dilate.mgz erode 4 ${DIR}/ictus/lh.outer.mgz

	echo "mri_morphology ${DIR}/ictus/rh.dilate.mgz erode 4 ${DIR}/ictus/rh.outer.mgz"
	mri_morphology ${DIR}/ictus/rh.dilate.mgz erode 4 ${DIR}/ictus/rh.outer.mgz

	echo "mri_distance_transform ${DIR}/ictus/lh.outer.mgz 0 inf 1 ${DIR}/ictus/lh.depth.mgz"
	mri_distance_transform ${DIR}/ictus/lh.outer.mgz 0 inf 1 ${DIR}/ictus/lh.depth.mgz

	echo "mri_distance_transform ${DIR}/ictus/rh.outer.mgz 0 inf 1 ${DIR}/ictus/rh.depth.mgz"
	mri_distance_transform ${DIR}/ictus/rh.outer.mgz 0 inf 1 ${DIR}/ictus/rh.depth.mgz

	rm -f ${DIR}/ictus/lh.pial.mgz ${DIR}/ictus/rh.pial.mgz ${DIR}/ictus/lh.dilate.mgz ${DIR}/ictus/rh.dilate.mgz

	echo "mri_vol2surf --mov ${DIR}/ictus/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth

	mv ${DIR}/surf/lh.depth ${DIR}/ictus/lh.depth
	mv ${DIR}/surf/rh.depth ${DIR}/ictus/rh.depth

	rm -f ${DIR}/surf/lh.depth.w ${DIR}/surf/rh.depth.w 

	# Resample to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.depth.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.depth.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.depth.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.depth.mgh --tfmt curv

	### ***********************************************************************************************************************
	### Get curvature stuffs
	cp -f ${DIR}/surf/lh.curv ${DIR}/ictus/lh.curv
	cp -f ${DIR}/surf/rh.curv ${DIR}/ictus/rh.curv
	cp -f ${DIR}/surf/lh.curv.fwhm0.fsaverage.mgh ${DIR}/ictus/lh.fsaverage.curv.mgh
	cp -f ${DIR}/surf/rh.curv.fwhm0.fsaverage.mgh ${DIR}/ictus/rh.fsaverage.curv.mgh

	### ***********************************************************************************************************************
	# Get Complexity Stuffs
	if [ ${CFLAG} -eq 1 ]
	then

	if [ ! -f ${DIR}/ictus/lh.complexity ]
	then
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${DIR}
	 
	surf_left = SurfStatReadSurf('${DIR}/surf/lh.mid');
	Complexity_left = getSurfaceComplexity(surf_left, 20);
	surf_right = SurfStatReadSurf('${DIR}/surf/rh.mid');
	Complexity_right = getSurfaceComplexity(surf_right, 20);

	write_curv('${DIR}/ictus/lh.complexity', Complexity_left, length(Complexity_left));
	write_curv('${DIR}/ictus/rh.complexity', Complexity_right, length(Complexity_right));
EOF
	fi

	# Resample to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.complexity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.complexity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.complexity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.complexity.mgh --tfmt curv

	fi

	### ***********************************************************************************************************************
	### Get jacobian distance 

	cp -f ${DIR}/surf/lh.jacobian_white ${DIR}/ictus/lh.jacobian
	cp -f ${DIR}/surf/rh.jacobian_white ${DIR}/ictus/rh.jacobian
	cp -f ${DIR}/surf/lh.jacobian_white.fwhm0.fsaverage.mgh ${DIR}/ictus/lh.fsaverage.jacobian.mgh
	cp -f ${DIR}/surf/rh.jacobian_white.fwhm0.fsaverage.mgh ${DIR}/ictus/rh.fsaverage.jacobian.mgh



###########################################################################################################
					
					#FLAIR#
					
###########################################################################################################

### Prepare flair_nuc.nii

if [ ! -f ${DIR}/ictus/T1.nii ]
then
	mri_convert ${DIR}/ictus/T1.mgz ${DIR}/ictus/T1.nii
fi

 
if [ -f ${DIR}/ictus/flair.nii.gz ]
then
	gunzip ${DIR}/ictus/flair.nii.gz
fi


if [ ! -f ${DIR}/ictus/flair.nii ]
then
	echo "need a flair file named flair.nii"
else

	### Non uniformity correction 
	nii2mnc ${DIR}/ictus/flair.nii ${DIR}/ictus/flair.mnc
	nu_correct -distance 55 -iterations 150 -stop 0.00001 ${DIR}/ictus/flair.mnc ${DIR}/ictus/flair_nuc.mnc
	mri_convert ${DIR}/ictus/flair_nuc.mnc ${DIR}/ictus/flair_nuc.nii


	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${DIR}

	matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'${DIR}/ictus/T1.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.source = {'${DIR}/ictus/flair_nuc.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

EOF
	


	### ***********************************************************************************************************************
	### Compute smooth Flair and gradient map

	echo "mincblur -fwhm 2 ${DIR}/ictus/flair_nuc.mnc ${DIR}/ictus/flair_nuc_2 -gradient -clobber"
	mincblur -fwhm 2 ${DIR}/ictus/flair_nuc.mnc ${DIR}/ictus/flair_nuc_2 -gradient -clobber

	echo "mri_convert ${DIR}/ictus/flair_nuc_2_blur.mnc ${DIR}/ictus/flair_nuc_2_blur.mgz"
	mri_convert ${DIR}/ictus/flair_nuc_2_blur.mnc ${DIR}/ictus/flair_nuc_2_blur.mgz

	echo "mri_convert ${DIR}/ictus/flair_nuc_2_dxyz.mnc ${DIR}/ictus/flair_nuc_2_dxyz.mgz"
	mri_convert ${DIR}/ictus/flair_nuc_2_dxyz.mnc ${DIR}/ictus/flair_nuc_2_dxyz.mgz

	rm -f ${DIR}/ictus/flair_nuc_2_dxyz.mnc ${DIR}/ictus/flair_nuc_2_blur.mnc ${DIR}/ictus/flair_nuc.mnc

	### ***********************************************************************************************************************
	### Project Gradient on surface
	echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.dxyz.w lh.flair_nuc.dxyz"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.dxyz.w lh.flair_nuc.dxyz

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.dxyz.w rh.flair_nuc.dxyz"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.dxyz.w rh.flair_nuc.dxyz

	mv ${DIR}/surf/lh.flair_nuc.dxyz ${DIR}/ictus/lh.flair_nuc.dxyz
	mv ${DIR}/surf/rh.flair_nuc.dxyz ${DIR}/ictus/rh.flair_nuc.dxyz
	
	rm -f ${DIR}/surf/lh.flair_nuc.dxyz.w ${DIR}/surf/rh.flair_nuc.dxyz.w 

	# Resample Gradient to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv


	### ***********************************************************************************************************************
	### Project Flair onto surface
	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
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




	echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.intensity.w lh.flair_nuc.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.intensity.w lh.flair_nuc.intensity

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.intensity.w rh.flair_nuc.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.intensity.w rh.flair_nuc.intensity

	mv ${DIR}/surf/lh.flair_nuc.intensity ${DIR}/ictus/lh.flair_nuc.intensity
	mv ${DIR}/surf/rh.flair_nuc.intensity ${DIR}/ictus/rh.flair_nuc.intensity

	rm -f ${DIR}/surf/lh.flair_nuc.intensity.w ${DIR}/surf/rh.flair_nuc.intensity.w 

	# Resample Intensity to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.flair_nuc.fsaverage.intensity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.flair_nuc.fsaverage.intensity.mgh --tfmt curv


fi



###########################################################################################################
					
					#PET#
					
###########################################################################################################

if [ ! -f ${DIR}/ictus/pet_las.nii ]
then
	echo "need a pet file named pet_las.nii"
else
	if [ ! -r ${DIR}/ictus/pve ]
	then
	
		matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		cd ${DIR}

		run_pve('${DIR}/ictus/T1_las.nii','${DIR}/ictus/pet_las.nii','${DIR}/ictus/pve')
	
EOF
	fi

	### ***********************************************************************************************************************
	### 

	echo "mri_convert ${DIR}/ictus/pve/t1_MGRousset.img ${DIR}/ictus/pve/t1_MGRousset.mnc"
	mri_convert ${DIR}/ictus/pve/t1_MGRousset.img ${DIR}/ictus/pve/t1_MGRousset.mnc

	echo "mincblur -fwhm 5 ${DIR}/ictus/pve/t1_MGRousset.mnc ${DIR}/ictus/pve/t1_MGRousset_2 -clobber"
	mincblur -fwhm 5 ${DIR}/ictus/pve/t1_MGRousset.mnc ${DIR}/ictus/pve/t1_MGRousset_2 -clobber

	echo "mri_convert ${DIR}/ictus/pve/t1_MGRousset_2_blur.mnc ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz"
	mri_convert ${DIR}/ictus/pve/t1_MGRousset_2_blur.mnc ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz


	rm -f ${DIR}/ictus/pve/t1_MGRousset_2_blur.mnc ${DIR}/ictus/pve/t1_MGRousset.mnc

	#Project Hypometabolism on surface
	###*************************************************************

	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
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


	echo "mri_vol2surf --mov ${DIR}/ictus/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/ictus/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.pet.w lh.pet

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.pet.w rh.pet

	mv ${DIR}/surf/lh.pet ${DIR}/ictus/lh.pet
	mv ${DIR}/surf/rh.pet ${DIR}/ictus/rh.pet

	rm -f ${DIR}/surf/lh.pet.w ${DIR}/surf/rh.pet.w 

	# Resample hypometabolism to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fsaverage.pet.mgh --tfmt curv


	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fsaverage.pet.mgh --tfmt curv


	rm -f ${DIR}/ictus/pve/cmdline.txt  ${DIR}/ictus/pve/pet.hdr  ${DIR}/ictus/pve/pet.img  ${DIR}/ictus/pve/t1_CSWMROI.hdr  ${DIR}/ictus/pve/t1_CSWMROI.img  ${DIR}/ictus/pve/t1_GMROI.hdr  ${DIR}/ictus/pve/t1_GMROI.img  ${DIR}/ictus/pve/t1.hdr  ${DIR}/ictus/pve/t1.img  ${DIR}/ictus/pve/t1_Meltzer.hdr  ${DIR}/ictus/pve/t1_Meltzer.img  ${DIR}/ictus/pve/t1_MGCS.hdr  ${DIR}/ictus/pve/t1_MGCS.img  ${DIR}/ictus/pve/t1_Occu_Meltzer.hdr  ${DIR}/ictus/pve/t1_Occu_Meltzer.img  ${DIR}/ictus/pve/t1_Occu_MG.hdr  ${DIR}/ictus/pve/t1_Occu_MG.img  ${DIR}/ictus/pve/t1_PSF.hdr  ${DIR}/ictus/pve/t1_PSF.img  ${DIR}/ictus/pve/t1_pve.txt  ${DIR}/ictus/pve/t1_Rousset.Mat  ${DIR}/ictus/pve/t1_seg1.hdr  ${DIR}/ictus/pve/t1_seg1.img  ${DIR}/ictus/pve/t1_seg2.hdr  ${DIR}/ictus/pve/t1_seg2.img  ${DIR}/ictus/pve/t1_seg3.hdr  ${DIR}/ictus/pve/t1_seg3.img  ${DIR}/ictus/pve/t1_seg8.mat  ${DIR}/ictus/pve/t1_Virtual_PET.hdr  ${DIR}/ictus/pve/t1_Virtual_PET.
img

fi


###########################################################################################################
			###                                                 ####
			 ##                                                 ###
			  # FEATURES EXTRACTION WHITH BLUR - 5, 10, 15 & 20 #
			 ##                                                 ##
			###                                                 ###
###########################################################################################################





for FWHM in 5 10 15 20
do


	###########################################################################################################
					
						#T1#
					
	###########################################################################################################



	if [ ! -f ${DIR}/ictus/T1_2_blur.mgz ]
	then
		echo "error in data preparation - mincblur fail"
	else

	
		### ***********************************************************************************************************************
		### Project Gradient on surface
	
		echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}
	
		echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}
	
		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz



		mv ${DIR}/surf/lh.fwhm${FWHM}.dxyz ${DIR}/ictus/lh.fwhm${FWHM}.dxyz
		mv ${DIR}/surf/rh.fwhm${FWHM}.dxyz ${DIR}/ictus/rh.fwhm${FWHM}.dxyz

		# Resample Gradient to fsaverage
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv


	
		rm -f ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w
		### ***********************************************************************************************************************
		### Project T1 onto surface
	
		echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity

		mv ${DIR}/surf/lh.fwhm${FWHM}.intensity ${DIR}/ictus/lh.fwhm${FWHM}.intensity
		mv ${DIR}/surf/rh.fwhm${FWHM}.intensity ${DIR}/ictus/rh.fwhm${FWHM}.intensity

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.intensity.w ${DIR}/surf/rh.fwhm${FWHM}.intensity.w

		# Resample Intensity to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

		### ***********************************************************************************************************************
		### Get cortical thickness stuffs
		cp -f ${DIR}/surf/lh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.thickness.mgh
		cp -f ${DIR}/surf/rh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.thickness.mgh

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/ictus/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/ictus/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/ictus/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/ictus/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

		### ***********************************************************************************************************************
		### Compute Depth stuffs
	
		echo "mri_vol2surf --mov ${DIR}/ictus/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/ictus/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth

		mv ${DIR}/surf/lh.fwhm${FWHM}.depth ${DIR}/ictus/lh.fwhm${FWHM}.depth
		mv ${DIR}/surf/rh.fwhm${FWHM}.depth ${DIR}/ictus/rh.fwhm${FWHM}.depth
		rm -f ${DIR}/surf/lh.fwhm${FWHM}.depth.w ${DIR}/surf/rh.fwhm${FWHM}.depth.w

		# Resample to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

	
		### ***********************************************************************************************************************
		### Get curvature stuffs

		cp -f ${DIR}/surf/lh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.curv.mgh
		cp -f ${DIR}/surf/rh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.curv.mgh

		### ***********************************************************************************************************************
		# Get Complexity Stuffs
		if [ ${CFLAG} -eq 1 ]
		then

		if [ ! -f ${DIR}/ictus/lh.complexity ]
		then
		matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		cd ${DIR}
		 
		surf_left = SurfStatReadSurf('${DIR}/surf/lh.mid');
		Complexity_left = getSurfaceComplexity(surf_left, 20);
		surf_right = SurfStatReadSurf('${DIR}/surf/rh.mid');
		Complexity_right = getSurfaceComplexity(surf_right, 20);

		write_curv('${DIR}/ictus/lh.complexity', Complexity_left, length(Complexity_left));
		write_curv('${DIR}/ictus/rh.complexity', Complexity_right, length(Complexity_right));
EOF
		fi

		# Resample to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}

		fi

		### ***********************************************************************************************************************
		### Get jacobian distance 

		cp -f ${DIR}/surf/lh.jacobian_white.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.jacobian.mgh
		cp -f ${DIR}/surf/rh.jacobian_white.fwhm${FWHM}.fsaverage.mgh ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.jacobian.mgh

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/ictus/lh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/ictus/lh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/ictus/rh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/ictus/rh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}

	fi



	###########################################################################################################
					
						#FLAIR#
					
	###########################################################################################################



	### Prepare flair_nuc.nii

	if [ ! -f ${DIR}/ictus/flair_nuc_2_dxyz.mgz ]
	then
		echo "error in data preparation - flair mapping fail"

	else

		### ***********************************************************************************************************************
		### Project Gradient on surface
	
		echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w lh.fwhm${FWHM}.flair_nuc.dxyz"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w lh.fwhm${FWHM}.flair_nuc.dxyz

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w rh.fwhm${FWHM}.flair_nuc.dxyz"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w rh.fwhm${FWHM}.flair_nuc.dxyz

		mv ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.dxyz
		mv ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.dxyz

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w

		# Resample Gradient to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

		### ***********************************************************************************************************************
		### Project Flair onto surface
	
		echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w lh.fwhm${FWHM}.flair_nuc.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w lh.fwhm${FWHM}.flair_nuc.intensity

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w rh.fwhm${FWHM}.flair_nuc.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w rh.fwhm${FWHM}.flair_nuc.intensity

		mv ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.intensity
		mv ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.intensity

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w

		# Resample Intensity to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv

	fi



	###########################################################################################################
					
						#PET#
					
	###########################################################################################################

	if [ ! -f ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz ]
	then
		echo "error in data preparation - pve fail"
	else
	
		echo "mri_vol2surf --mov ${DIR}/ictus/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/ictus/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/ictus/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.pet.w lh.fwhm${FWHM}.pet

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.pet.w rh.fwhm${FWHM}.pet

		mv ${DIR}/surf/lh.fwhm${FWHM}.pet ${DIR}/ictus/lh.fwhm${FWHM}.pet
		mv ${DIR}/surf/rh.fwhm${FWHM}.pet ${DIR}/ictus/rh.fwhm${FWHM}.pet

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.pet.w ${DIR}/surf/rh.fwhm${FWHM}.pet.w

		# Resample hypometabolism to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/ictus/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/ictus/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/ictus/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	
	fi

done