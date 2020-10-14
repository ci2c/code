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
CFLAG=0

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

# Create CQ directory if needed
if [ ! -d ${DIR}/CQ ]
then
	mkdir ${DIR}/CQ
fi

### Compute smooth T1 and gradient map
echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/CQ/T1.mnc"
mri_convert ${DIR}/mri/T1.mgz ${DIR}/CQ/T1.mnc

echo "mincblur -fwhm 2 ${DIR}/CQ/T1.mnc ${DIR}/CQ/T1_2 -gradient -clobber"
mincblur -fwhm 2 ${DIR}/CQ/T1.mnc ${DIR}/CQ/T1_2 -gradient -clobber

echo "mri_convert ${DIR}/CQ/T1_2_blur.mnc ${DIR}/CQ/T1_2_blur.mgz"
mri_convert ${DIR}/CQ/T1_2_blur.mnc ${DIR}/CQ/T1_2_blur.mgz

echo "mri_convert ${DIR}/CQ/T1_2_dxyz.mnc ${DIR}/CQ/T1_2_dxyz.mgz"
mri_convert ${DIR}/CQ/T1_2_dxyz.mnc ${DIR}/CQ/T1_2_dxyz.mgz

rm -f ${DIR}/CQ/T1_2_dxyz.mnc ${DIR}/CQ/T1_2_blur.mnc ${DIR}/CQ/T1.mnc

### ***********************************************************************************************************************
### Project Gradient on surface
echo "mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi lh --surf white --o lh.dxyz.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi lh --surf white --o lh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint"
mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi rh --surf white --o rh.dxyz.w --regheader ${SUBJ} --out_type paint

echo "mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/CQ/T1_2_dxyz.mgz --hemi rh --surf white --o rh.fwhm${FWHM}.dxyz.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.dxyz.w lh.dxyz

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.dxyz.w rh.dxyz

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w lh.fwhm${FWHM}.dxyz

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w rh.fwhm${FWHM}.dxyz

mv ${DIR}/surf/lh.dxyz ${DIR}/CQ/lh.dxyz
mv ${DIR}/surf/rh.dxyz ${DIR}/CQ/rh.dxyz
mv ${DIR}/surf/lh.fwhm${FWHM}.dxyz ${DIR}/CQ/lh.fwhm${FWHM}.dxyz
mv ${DIR}/surf/rh.fwhm${FWHM}.dxyz ${DIR}/CQ/rh.fwhm${FWHM}.dxyz

rm -f ${DIR}/surf/lh.dxyz.w ${DIR}/surf/rh.dxyz.w ${DIR}/surf/lh.fwhm${FWHM}.dxyz.w ${DIR}/surf/rh.fwhm${FWHM}.dxyz.w

# Resample Gradient to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/CQ/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/lh.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/CQ/lh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/lh.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/CQ/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/CQ/lh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/lh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/CQ/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/rh.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/CQ/rh.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/rh.fsaverage.dxyz.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/CQ/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/CQ/rh.fwhm${FWHM}.dxyz --sfmt curv --noreshape --no-cortex --tval ${DIR}/CQ/rh.fwhm${FWHM}.fsaverage.dxyz.mgh --tfmt curv
echo
echo "Mapping gradient terminé"
echo

matlab -nodisplay << EOF
l = read_curv('${DIR}/CQ/lh.dxyz');
r = read_curv('${DIR}/CQ/rh.dxyz');
b = [l'  r'];
s = SurfStatReadSurf({'${DIR}/surf/lh.white','${DIR}/surf/rh.white'});
save_surface_vtk(s,surfaceCA.vtk,'BINARY',b);
EOF
