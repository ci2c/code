#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM>"
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
	echo ""
	echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM>"
	echo ""
	exit 1
fi


index=1
keeptmp=0

while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM>"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM>"
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
	-fwhm)
		index=$[$index+1]
		eval FWHM=\${$index}
		echo "FWHM : $FWHM"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM>"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo ""
		echo "Usage: Surface_features.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM>"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

# Create asl directory if needed
if [ ! -d ${DIR}/asl ]
then
	mkdir ${DIR}/asl
fi

mri_convert ${DIR}/asl/mean.nii ${DIR}/asl/mean.mgz -c
### Project ASL on T1 surface
mri_vol2surf --mov ${DIR}/asl/mean.mgz --hemi lh --surf white --o lh.asl.w --regheader ${SUBJ} --out_type paint
mri_vol2surf --mov ${DIR}/asl/mean.mgz --hemi rh --surf white --o rh.asl.w --regheader ${SUBJ} --out_type paint

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl.curv

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl.curv

mv ${DIR}/surf/lh.dxyz ${DIR}/asl/lh.dxyz
mv ${DIR}/surf/rh.dxyz ${DIR}/asl/rh.dxyz
mv ${DIR}/surf/lh.fwhm${FWHM}.dxyz ${DIR}/asl/lh.fwhm${FWHM}.dxyz
mv ${DIR}/surf/rh.fwhm${FWHM}.dxyz ${DIR}/asl/rh.fwhm${FWHM}.dxyz

rm -f ${DIR}/surf/lh.dxyz.w ${DIR}/surf/rh.dxyz.w ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w

# Resample Gradient to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv

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

echo "mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/asl/T1_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity

mv ${DIR}/surf/lh.intensity ${DIR}/asl/lh.intensity
mv ${DIR}/surf/rh.intensity ${DIR}/asl/rh.intensity
mv ${DIR}/surf/lh.fwhm${FWHM}.intensity ${DIR}/asl/lh.fwhm${FWHM}.intensity
mv ${DIR}/surf/rh.fwhm${FWHM}.intensity ${DIR}/asl/rh.fwhm${FWHM}.intensity

rm -f ${DIR}/surf/lh.intensity.w ${DIR}/surf/rh.intensity.w ${DIR}/surf/lh.fwhm${FWHM}.intensity.w ${DIR}/surf/rh.fwhm${FWHM}.intensity.w

# Resample Intensity to fsaverage
#echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.intensity.mgh --tfmt curv"
#mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.intensity.mgh --tfmt curv

#echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
#mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

#echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.intensity.mgh --tfmt curv"
#mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.intensity.mgh --tfmt curv

#echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv"
#mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.intensity --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.intensity.mgh --tfmt curv

### ***********************************************************************************************************************
### Get cortical thickness stuffs
#cp -f ${DIR}/surf/lh.thickness ${DIR}/asl/lh.thickness
#cp -f ${DIR}/surf/rh.thickness ${DIR}/asl/rh.thickness
#cp -f ${DIR}/surf/lh.thickness.fwhm0.fsaverage.mgh ${DIR}/asl/lh.fsaverage.thickness.mgh
#cp -f ${DIR}/surf/rh.thickness.fwhm0.fsaverage.mgh ${DIR}/asl/rh.fsaverage.thickness.mgh
#cp -f ${DIR}/surf/lh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.thickness.mgh
#cp -f ${DIR}/surf/rh.thickness.fwhm${FWHM}.fsaverage.mgh ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.thickness.mgh

#echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/asl/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
#mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --trgsubject ${SUBJ} --trghemi lh --sval ${DIR}/asl/lh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/asl/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --trgsubject ${SUBJ} --trghemi rh --sval ${DIR}/asl/rh.thickness --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.thickness.mgh --tfmt curv --fwhm ${FWHM}

### ***********************************************************************************************************************
### Compute Depth stuffs
echo "mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/asl/lh.pial.mgz"
mris_fill -c -r 1 ${DIR}/surf/lh.pial ${DIR}/asl/lh.pial.mgz

echo "mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/asl/rh.pial.mgz"
mris_fill -c -r 1 ${DIR}/surf/rh.pial ${DIR}/asl/rh.pial.mgz

echo "mri_morphology ${DIR}/asl/lh.pial.mgz dilate 4 ${DIR}/asl/lh.dilate.mgz"
mri_morphology ${DIR}/asl/lh.pial.mgz dilate 4 ${DIR}/asl/lh.dilate.mgz

echo "mri_morphology ${DIR}/asl/rh.pial.mgz dilate 4 ${DIR}/asl/rh.dilate.mgz"
mri_morphology ${DIR}/asl/rh.pial.mgz dilate 4 ${DIR}/asl/rh.dilate.mgz

echo "mri_morphology ${DIR}/asl/lh.dilate.mgz erode 4 ${DIR}/asl/lh.outer.mgz"
mri_morphology ${DIR}/asl/lh.dilate.mgz erode 4 ${DIR}/asl/lh.outer.mgz

echo "mri_morphology ${DIR}/asl/rh.dilate.mgz erode 4 ${DIR}/asl/rh.outer.mgz"
mri_morphology ${DIR}/asl/rh.dilate.mgz erode 4 ${DIR}/asl/rh.outer.mgz

echo "mri_distance_transform ${DIR}/asl/lh.outer.mgz 0 inf 1 ${DIR}/asl/lh.depth.mgz"
mri_distance_transform ${DIR}/asl/lh.outer.mgz 0 inf 1 ${DIR}/asl/lh.depth.mgz

echo "mri_distance_transform ${DIR}/asl/rh.outer.mgz 0 inf 1 ${DIR}/asl/rh.depth.mgz"
mri_distance_transform ${DIR}/asl/rh.outer.mgz 0 inf 1 ${DIR}/asl/rh.depth.mgz

rm -f ${DIR}/asl/lh.pial.mgz ${DIR}/asl/rh.pial.mgz ${DIR}/asl/lh.dilate.mgz ${DIR}/asl/rh.dilate.mgz

echo "mri_vol2surf --mov ${DIR}/asl/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/asl/lh.depth.mgz --hemi lh --surf white --o lh.depth.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/asl/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/asl/lh.depth.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/asl/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/asl/rh.depth.mgz --hemi rh --surf white --o rh.depth.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/asl/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/asl/rh.depth.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.depth.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.depth.w lh.depth

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.depth.w rh.depth

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.depth.w lh.fwhm${FWHM}.depth

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.depth.w rh.fwhm${FWHM}.depth

mv ${DIR}/surf/lh.depth ${DIR}/asl/lh.depth
mv ${DIR}/surf/rh.depth ${DIR}/asl/rh.depth
mv ${DIR}/surf/lh.fwhm${FWHM}.depth ${DIR}/asl/lh.fwhm${FWHM}.depth
mv ${DIR}/surf/rh.fwhm${FWHM}.depth ${DIR}/asl/rh.fwhm${FWHM}.depth
rm -f ${DIR}/surf/lh.depth.w ${DIR}/surf/rh.depth.w ${DIR}/surf/lh.fwhm${FWHM}.depth.w ${DIR}/surf/rh.fwhm${FWHM}.depth.w

# Resample to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.depth.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fsaverage.depth.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/asl/lh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.fwhm${FWHM}.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.depth.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.depth.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/asl/rh.depth --sfmt curv --noreshape --no-cortex --tval ${DIR}/asl/rh.fsaverage.depth.mgh --tfmt curv

### ***********************************************************************************************************************
### Get curvature stuffs
cp -f ${DIR}/surf/lh.curv ${DIR}/asl/lh.curv
cp -f ${DIR}/surf/rh.curv ${DIR}/asl/rh.curv
cp -f ${DIR}/surf/lh.curv.fwhm0.fsaverage.mgh ${DIR}/asl/lh.fsaverage.curv.mgh
cp -f ${DIR}/surf/rh.curv.fwhm0.fsaverage.mgh ${DIR}/asl/rh.fsaverage.curv.mgh
cp -f ${DIR}/surf/lh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/asl/lh.fwhm${FWHM}.fsaverage.curv.mgh
cp -f ${DIR}/surf/rh.curv.fwhm${FWHM}.fsaverage.mgh ${DIR}/asl/rh.fwhm${FWHM}.fsaverage.curv.mgh
