#! /bin/bash

if [ $# -lt 3 ]
then
	echo ""
	echo "Usage: Surface_features.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  [-comp]"
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo " Option :"
	echo "  -comp                            : Compute surface complexity (time consuming)"
	echo ""
	echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
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
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo " Option :"
		echo "  -comp                            : Compute surface complexity (time consuming)"
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>   [-comp]"
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
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo " Option :"
		echo "  -comp                            : Compute surface complexity (time consuming)"
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>   [-comp]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

# Create epilepsy directory if needed
if [ ! -d ${DIR}/epilepsy ]
then
	mkdir ${DIR}/epilepsy
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



if [ ! -f ${DIR}/epilepsy/T1.mgz ]
then
	if [ -f ${DIR}/mri/T1.mgz ]
	then
		cp ${DIR}/mri/T1.mgz ${DIR}/epilepsy/T1.mgz
	else
		echo "need a T1 file -> ${DIR}/epilepsy/T1.mgz"
	fi
	
else

	### Compute smooth T1 and gradient map
	echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/epilepsy/T1.mnc"
	mri_convert ${DIR}/mri/T1.mgz ${DIR}/epilepsy/T1.mnc

	echo "mincblur -fwhm 2 ${DIR}/epilepsy/T1.mnc ${DIR}/epilepsy/T1_2 -gradient -clobber"
	mincblur -fwhm 2 ${DIR}/epilepsy/T1.mnc ${DIR}/epilepsy/T1_2 -gradient -clobber

	echo "mri_convert ${DIR}/epilepsy/T1_2_blur.mnc ${DIR}/epilepsy/T1_2_blur.mgz"
	mri_convert ${DIR}/epilepsy/T1_2_blur.mnc ${DIR}/epilepsy/T1_2_blur.mgz

	echo "mri_convert ${DIR}/epilepsy/T1_2_dxyz.mnc ${DIR}/epilepsy/T1_2_dxyz.mgz"
	mri_convert ${DIR}/epilepsy/T1_2_dxyz.mnc ${DIR}/epilepsy/T1_2_dxyz.mgz

	rm -f ${DIR}/epilepsy/T1_2_dxyz.mnc ${DIR}/epilepsy/T1_2_blur.mnc ${DIR}/epilepsy/T1.mnc

	### ***********************************************************************************************************************
	### Project Gradient on surface
	echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz

	
	mv ${DIR}/surf/lh.dxyz ${DIR}/epilepsy/lh.dxyz
	mv ${DIR}/surf/rh.dxyz ${DIR}/epilepsy/rh.dxyz
	
	rm -f ${DIR}/surf/lh.dxyz.w ${DIR}/surf/rh.dxyz.w 

	# Resample Gradient to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.dxyz.mgh --tfmt curv

	
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.dxyz.mgh --tfmt curv
	

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

	echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity

	mv ${DIR}/surf/lh.intensity ${DIR}/epilepsy/lh.intensity
	mv ${DIR}/surf/rh.intensity ${DIR}/epilepsy/rh.intensity
	
	rm -f ${DIR}/surf/lh.intensity.w ${DIR}/surf/rh.intensity.w

	# Resample Intensity to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.intensity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.intensity.mgh --tfmt curv


	### ***********************************************************************************************************************
	### Get cortical thickness stuffs
	cp -f ${DIR}/surf/lh.thickness ${DIR}/epilepsy/lh.thickness
	cp -f ${DIR}/surf/rh.thickness ${DIR}/epilepsy/rh.thickness
	cp -f ${DIR}/surf/lh.thickness.fwhm0.fsaverage.mgh ${DIR}/epilepsy/lh.fsaverage.thickness.mgh
	cp -f ${DIR}/surf/rh.thickness.fwhm0.fsaverage.mgh ${DIR}/epilepsy/rh.fsaverage.thickness.mgh
	

	### ***********************************************************************************************************************
	### Compute Depth stuffs
	echo "mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/epilepsy/lh.pial.mgz"
	mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/epilepsy/lh.pial.mgz

	echo "mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/epilepsy/rh.pial.mgz"
	mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/epilepsy/rh.pial.mgz

	echo "mri_morphology ${DIR}/epilepsy/lh.pial.mgz dilate 4 ${DIR}/epilepsy/lh.dilate.mgz"
	mri_morphology ${DIR}/epilepsy/lh.pial.mgz dilate 4 ${DIR}/epilepsy/lh.dilate.mgz

	echo "mri_morphology ${DIR}/epilepsy/rh.pial.mgz dilate 4 ${DIR}/epilepsy/rh.dilate.mgz"
	mri_morphology ${DIR}/epilepsy/rh.pial.mgz dilate 4 ${DIR}/epilepsy/rh.dilate.mgz

	echo "mri_morphology ${DIR}/epilepsy/lh.dilate.mgz erode 4 ${DIR}/epilepsy/lh.outer.mgz"
	mri_morphology ${DIR}/epilepsy/lh.dilate.mgz erode 4 ${DIR}/epilepsy/lh.outer.mgz

	echo "mri_morphology ${DIR}/epilepsy/rh.dilate.mgz erode 4 ${DIR}/epilepsy/rh.outer.mgz"
	mri_morphology ${DIR}/epilepsy/rh.dilate.mgz erode 4 ${DIR}/epilepsy/rh.outer.mgz

	echo "mri_distance_transform ${DIR}/epilepsy/lh.outer.mgz 0 inf 1 ${DIR}/epilepsy/lh.depth.mgz"
	mri_distance_transform ${DIR}/epilepsy/lh.outer.mgz 0 inf 1 ${DIR}/epilepsy/lh.depth.mgz

	echo "mri_distance_transform ${DIR}/epilepsy/rh.outer.mgz 0 inf 1 ${DIR}/epilepsy/rh.depth.mgz"
	mri_distance_transform ${DIR}/epilepsy/rh.outer.mgz 0 inf 1 ${DIR}/epilepsy/rh.depth.mgz

	rm -f ${DIR}/epilepsy/lh.pial.mgz ${DIR}/epilepsy/rh.pial.mgz ${DIR}/epilepsy/lh.dilate.mgz ${DIR}/epilepsy/rh.dilate.mgz

	echo "mri_vol2surf --mov ${DIR}/epilepsy/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth

	mv ${DIR}/surf/lh.depth ${DIR}/epilepsy/lh.depth
	mv ${DIR}/surf/rh.depth ${DIR}/epilepsy/rh.depth

	rm -f ${DIR}/surf/lh.depth.w ${DIR}/surf/rh.depth.w 

	# Resample to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.depth.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.depth.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.depth.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.depth.mgh --tfmt curv

	### ***********************************************************************************************************************
	### Get curvature stuffs
	cp -f ${DIR}/surf/lh.curv ${DIR}/epilepsy/lh.curv
	cp -f ${DIR}/surf/rh.curv ${DIR}/epilepsy/rh.curv
	cp -f ${DIR}/surf/lh.curv.fwhm0.fsaverage.mgh ${DIR}/epilepsy/lh.fsaverage.curv.mgh
	cp -f ${DIR}/surf/rh.curv.fwhm0.fsaverage.mgh ${DIR}/epilepsy/rh.fsaverage.curv.mgh

	### ***********************************************************************************************************************
	# Get Complexity Stuffs
	if [ ${CFLAG} -eq 1 ]
	then

	if [ ! -f ${DIR}/epilepsy/lh.complexity ]
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

	write_curv('${DIR}/epilepsy/lh.complexity', Complexity_left, length(Complexity_left));
	write_curv('${DIR}/epilepsy/rh.complexity', Complexity_right, length(Complexity_right));
EOF
	fi

	# Resample to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.complexity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.complexity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.complexity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.complexity.mgh --tfmt curv

	fi

	### ***********************************************************************************************************************
	### Get jacobian distance 

	cp -f ${DIR}/surf/lh.jacobian_white ${DIR}/epilepsy/lh.jacobian
	cp -f ${DIR}/surf/rh.jacobian_white ${DIR}/epilepsy/rh.jacobian
	cp -f ${DIR}/surf/lh.jacobian_white.fwhm0.fsaverage.mgh ${DIR}/epilepsy/lh.fsaverage.jacobian.mgh
	cp -f ${DIR}/surf/rh.jacobian_white.fwhm0.fsaverage.mgh ${DIR}/epilepsy/rh.fsaverage.jacobian.mgh


	
fi



###########################################################################################################
					
					#FLAIR#
					
###########################################################################################################

### Prepare flair_nuc.nii

if [ ! -f ${DIR}/epilepsy/T1.nii ]
then
	mri_convert ${DIR}/epilepsy/T1.mgz ${DIR}/epilepsy/T1.nii
fi

 
if [ -f ${DIR}/epilepsy/flair.nii.gz ]
then
	gunzip ${DIR}/epilepsy/flair.nii.gz
fi


if [ ! -f ${DIR}/epilepsy/flair.nii ]
then
	echo "need a flair file named flair.nii"
else

	### Non uniformity correction 
	nii2mnc ${DIR}/epilepsy/flair.nii ${DIR}/epilepsy/flair.mnc
	nu_correct -distance 55 -iterations 150 -stop 0.00001 ${DIR}/epilepsy/flair.mnc ${DIR}/epilepsy/flair_nuc.mnc
	mri_convert ${DIR}/epilepsy/flair_nuc.mnc ${DIR}/epilepsy/flair_nuc.nii


	matlab -nodisplay <<EOF
	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);
	cd ${DIR}

	matlabbatch{1}.spm.spatial.coreg.estimate.ref = {'${DIR}/epilepsy/T1.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.source = {'${DIR}/epilepsy/flair_nuc.nii,1'};
	matlabbatch{1}.spm.spatial.coreg.estimate.other = {''};
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

EOF
	


	### ***********************************************************************************************************************
	### Compute smooth Flair and gradient map

	echo "mincblur -fwhm 2 ${DIR}/epilepsy/flair_nuc.mnc ${DIR}/epilepsy/flair_nuc_2 -gradient -clobber"
	mincblur -fwhm 2 ${DIR}/epilepsy/flair_nuc.mnc ${DIR}/epilepsy/flair_nuc_2 -gradient -clobber

	echo "mri_convert ${DIR}/epilepsy/flair_nuc_2_blur.mnc ${DIR}/epilepsy/flair_nuc_2_blur.mgz"
	mri_convert ${DIR}/epilepsy/flair_nuc_2_blur.mnc ${DIR}/epilepsy/flair_nuc_2_blur.mgz

	echo "mri_convert ${DIR}/epilepsy/flair_nuc_2_dxyz.mnc ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz"
	mri_convert ${DIR}/epilepsy/flair_nuc_2_dxyz.mnc ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz

	rm -f ${DIR}/epilepsy/flair_nuc_2_dxyz.mnc ${DIR}/epilepsy/flair_nuc_2_blur.mnc ${DIR}/epilepsy/flair_nuc.mnc

	### ***********************************************************************************************************************
	### Project Gradient on surface
	echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.dxyz.w lh.flair_nuc.dxyz"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.dxyz.w lh.flair_nuc.dxyz

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.dxyz.w rh.flair_nuc.dxyz"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.dxyz.w rh.flair_nuc.dxyz

	mv ${DIR}/surf/lh.flair_nuc.dxyz ${DIR}/epilepsy/lh.flair_nuc.dxyz
	mv ${DIR}/surf/rh.flair_nuc.dxyz ${DIR}/epilepsy/rh.flair_nuc.dxyz
	
	rm -f ${DIR}/surf/lh.flair_nuc.dxyz.w ${DIR}/surf/rh.flair_nuc.dxyz.w 

	# Resample Gradient to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.flair_nuc.fsaverage.dxyz.mgh --tfmt curv


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




	echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.intensity.w lh.flair_nuc.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.flair_nuc.intensity.w lh.flair_nuc.intensity

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.intensity.w rh.flair_nuc.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.flair_nuc.intensity.w rh.flair_nuc.intensity

	mv ${DIR}/surf/lh.flair_nuc.intensity ${DIR}/epilepsy/lh.flair_nuc.intensity
	mv ${DIR}/surf/rh.flair_nuc.intensity ${DIR}/epilepsy/rh.flair_nuc.intensity

	rm -f ${DIR}/surf/lh.flair_nuc.intensity.w ${DIR}/surf/rh.flair_nuc.intensity.w 

	# Resample Intensity to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.flair_nuc.fsaverage.intensity.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.flair_nuc.fsaverage.intensity.mgh --tfmt curv


fi



###########################################################################################################
					
					#PET#
					
###########################################################################################################

if [ ! -f ${DIR}/epilepsy/pet_las.nii ]
then
	echo "need a pet file named pet_las.nii"
else
	if [ ! -r ${DIR}/epilepsy/pve ]
	then
	
		matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		cd ${DIR}

		run_pve('${DIR}/epilepsy/T1_las.nii','${DIR}/epilepsy/pet_las.nii','${DIR}/epilepsy/pve')
	
EOF
	fi

	### ***********************************************************************************************************************
	### 

	echo "mri_convert ${DIR}/epilepsy/pve/t1_MGRousset.img ${DIR}/epilepsy/pve/t1_MGRousset.mnc"
	mri_convert ${DIR}/epilepsy/pve/t1_MGRousset.img ${DIR}/epilepsy/pve/t1_MGRousset.mnc

	echo "mincblur -fwhm 5 ${DIR}/epilepsy/pve/t1_MGRousset.mnc ${DIR}/epilepsy/pve/t1_MGRousset_2 -clobber"
	mincblur -fwhm 5 ${DIR}/epilepsy/pve/t1_MGRousset.mnc ${DIR}/epilepsy/pve/t1_MGRousset_2 -clobber

	echo "mri_convert ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mnc ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz"
	mri_convert ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mnc ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz


	rm -f ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mnc ${DIR}/epilepsy/pve/t1_MGRousset.mnc

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


	echo "mri_vol2surf --mov ${DIR}/epilepsy/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/epilepsy/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.pet.w lh.pet

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.pet.w rh.pet

	mv ${DIR}/surf/lh.pet ${DIR}/epilepsy/lh.pet
	mv ${DIR}/surf/rh.pet ${DIR}/epilepsy/rh.pet

	rm -f ${DIR}/surf/lh.pet.w ${DIR}/surf/rh.pet.w 

	# Resample hypometabolism to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fsaverage.pet.mgh --tfmt curv


	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fsaverage.pet.mgh --tfmt curv


	rm -f ${DIR}/epilepsy/pve/cmdline.txt  ${DIR}/epilepsy/pve/pet.hdr  ${DIR}/epilepsy/pve/pet.img  ${DIR}/epilepsy/pve/t1_CSWMROI.hdr  ${DIR}/epilepsy/pve/t1_CSWMROI.img  ${DIR}/epilepsy/pve/t1_GMROI.hdr  ${DIR}/epilepsy/pve/t1_GMROI.img  ${DIR}/epilepsy/pve/t1.hdr  ${DIR}/epilepsy/pve/t1.img  ${DIR}/epilepsy/pve/t1_Meltzer.hdr  ${DIR}/epilepsy/pve/t1_Meltzer.img  ${DIR}/epilepsy/pve/t1_MGCS.hdr  ${DIR}/epilepsy/pve/t1_MGCS.img  ${DIR}/epilepsy/pve/t1_Occu_Meltzer.hdr  ${DIR}/epilepsy/pve/t1_Occu_Meltzer.img  ${DIR}/epilepsy/pve/t1_Occu_MG.hdr  ${DIR}/epilepsy/pve/t1_Occu_MG.img  ${DIR}/epilepsy/pve/t1_PSF.hdr  ${DIR}/epilepsy/pve/t1_PSF.img  ${DIR}/epilepsy/pve/t1_pve.txt  ${DIR}/epilepsy/pve/t1_Rousset.Mat  ${DIR}/epilepsy/pve/t1_seg1.hdr  ${DIR}/epilepsy/pve/t1_seg1.img  ${DIR}/epilepsy/pve/t1_seg2.hdr  ${DIR}/epilepsy/pve/t1_seg2.img  ${DIR}/epilepsy/pve/t1_seg3.hdr  ${DIR}/epilepsy/pve/t1_seg3.img  ${DIR}/epilepsy/pve/t1_seg8.mat  ${DIR}/epilepsy/pve/t1_Virtual_PET.hdr  ${DIR}/epilepsy/pve/t1_Virtual_PET.img

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



	if [ ! -f ${DIR}/epilepsy/T1_2_blur.mgz ]
	then
		echo "error in data preparation - mincblur fail"
	else

	
		### ***********************************************************************************************************************
		### Project Gradient on surface
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}
	
		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz



		mv ${DIR}/surf/lh.fwhm${FWHM}.dxyz ${DIR}/epilepsy/lh.fwhm${FWHM}.dxyz
		mv ${DIR}/surf/rh.fwhm${FWHM}.dxyz ${DIR}/epilepsy/rh.fwhm${FWHM}.dxyz

		# Resample Gradient to fsaverage
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv


	
		rm -f ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w
		### ***********************************************************************************************************************
		### Project T1 onto surface
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity

		mv ${DIR}/surf/lh.fwhm${FWHM}.intensity ${DIR}/epilepsy/lh.fwhm${FWHM}.intensity
		mv ${DIR}/surf/rh.fwhm${FWHM}.intensity ${DIR}/epilepsy/rh.fwhm${FWHM}.intensity

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.intensity.w ${DIR}/surf/rh.fwhm${FWHM}.intensity.w

		# Resample Intensity to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

		### ***********************************************************************************************************************
		### Get cortical thickness stuffs
		cp -f ${DIR}/surf/lh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.thickness.mgh
		cp -f ${DIR}/surf/rh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.thickness.mgh

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/epilepsy/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/epilepsy/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/epilepsy/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/epilepsy/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

		### ***********************************************************************************************************************
		### Compute Depth stuffs
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/epilepsy/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth

		mv ${DIR}/surf/lh.fwhm${FWHM}.depth ${DIR}/epilepsy/lh.fwhm${FWHM}.depth
		mv ${DIR}/surf/rh.fwhm${FWHM}.depth ${DIR}/epilepsy/rh.fwhm${FWHM}.depth
		rm -f ${DIR}/surf/lh.fwhm${FWHM}.depth.w ${DIR}/surf/rh.fwhm${FWHM}.depth.w

		# Resample to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

	
		### ***********************************************************************************************************************
		### Get curvature stuffs

		cp -f ${DIR}/surf/lh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.curv.mgh
		cp -f ${DIR}/surf/rh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.curv.mgh

		### ***********************************************************************************************************************
		# Get Complexity Stuffs
		if [ ${CFLAG} -eq 1 ]
		then

		if [ ! -f ${DIR}/epilepsy/lh.complexity ]
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

		write_curv('${DIR}/epilepsy/lh.complexity', Complexity_left, length(Complexity_left));
		write_curv('${DIR}/epilepsy/rh.complexity', Complexity_right, length(Complexity_right));
EOF
		fi

		# Resample to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.complexity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.complexity.mgh --tfmt curv --fwhm-src ${FWHM}

		fi

		### ***********************************************************************************************************************
		### Get jacobian distance 

		cp -f ${DIR}/surf/lh.jacobian_white.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.jacobian.mgh
		cp -f ${DIR}/surf/rh.jacobian_white.fwhm${FWHM}.fsaverage.mgh ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.jacobian.mgh

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/epilepsy/lh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/epilepsy/lh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/epilepsy/rh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/epilepsy/rh.jacobian --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.jacobian.mgh --tfmt curv --fwhm ${FWHM}

	fi



	###########################################################################################################
					
						#FLAIR#
					
	###########################################################################################################



	### Prepare flair_nuc.nii

	if [ ! -f ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz]
	then
		echo "error in data preparation - flair mapping fail"

	else

		### ***********************************************************************************************************************
		### Project Gradient on surface
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.flair_nuc.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w lh.fwhm${FWHM}.flair_nuc.dxyz"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w lh.fwhm${FWHM}.flair_nuc.dxyz

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w rh.fwhm${FWHM}.flair_nuc.dxyz"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w rh.fwhm${FWHM}.flair_nuc.dxyz

		mv ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.dxyz
		mv ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.dxyz

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.dxyz.w

		# Resample Gradient to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.dxyz.mgh --tfmt curv

		### ***********************************************************************************************************************
		### Project Flair onto surface
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/flair_nuc_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.flair_nuc.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w lh.fwhm${FWHM}.flair_nuc.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w lh.fwhm${FWHM}.flair_nuc.intensity

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w rh.fwhm${FWHM}.flair_nuc.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w rh.fwhm${FWHM}.flair_nuc.intensity

		mv ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.intensity
		mv ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.intensity

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.flair_nuc.intensity.w ${DIR}/surf/rh.fwhm${FWHM}.flair_nuc.intensity.w

		# Resample Intensity to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv

		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.flair_nuc.fsaverage.intensity.mgh --tfmt curv

	fi



	###########################################################################################################
					
						#PET#
					
	###########################################################################################################

	if [ ! -f ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz ]
	then
		echo "error in data preparation - pve fail"
	else
	
		echo "mri_vol2surf --mov ${DIR}/epilepsy/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mri_vol2surf --mov ${DIR}/epilepsy/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
		mri_vol2surf --mov ${DIR}/epilepsy/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

		echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.pet.w lh.fwhm${FWHM}.pet

		echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
		mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.pet.w rh.fwhm${FWHM}.pet

		mv ${DIR}/surf/lh.fwhm${FWHM}.pet ${DIR}/epilepsy/lh.fwhm${FWHM}.pet
		mv ${DIR}/surf/rh.fwhm${FWHM}.pet ${DIR}/epilepsy/rh.fwhm${FWHM}.pet

		rm -f ${DIR}/surf/lh.fwhm${FWHM}.pet.w ${DIR}/surf/rh.fwhm${FWHM}.pet.w

		# Resample hypometabolism to fsaverage
	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	
		echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
		mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/epilepsy/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	
	fi

done
