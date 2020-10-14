#! /bin/bash

if [ $# -lt 8 ]
then
	echo ""
	echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID> -fwhm <FWHM> -o <folder>  [-comp]"
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
	echo "  -o                               : output folder "
	echo " "
	echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM> -o <folder> [-comp]"
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
		echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID> -fwhm <FWHM> -o <folder>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : output folder "
		echo " "
		echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM> -o <folder> [-comp]"
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
	-o)
		index=$[$index+1]
		eval output=\${$index}
		echo "output : ${output}"
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID> -fwhm <FWHM> -o <folder>  [-comp]"
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : output folder "
		echo " "
		echo "Usage: ASL_Project.sh -sd <SUBJCETS_DIR> -subj <SUBJ_ID>  -fwhm <FWHM> -o <folder> [-comp]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

echo "mri_convert ${DIR}/${output}/pve_out/t1_MGRousset.img ${DIR}/${output}/asl_pve.mgz"
mri_convert ${DIR}/${output}/pve_out/t1_MGRousset.img ${DIR}/${output}/asl_pve.mgz


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

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2

echo "mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}"
mri_vol2surf --mov ${DIR}/${output}/asl_pve.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.asl.w --regheader ${SUBJ} --out_type paint --fwhm 2 --surf-fwhm ${FWHM}

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.asl.w lh.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.asl.w rh.asl

echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.asl.w lh.fwhm${FWHM}.asl

echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl"
mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.asl.w rh.fwhm${FWHM}.asl

mv ${DIR}/surf/lh.asl ${DIR}/${output}/lh.asl
mv ${DIR}/surf/rh.asl ${DIR}/${output}/rh.asl
mv ${DIR}/surf/lh.fwhm${FWHM}.asl ${DIR}/${output}/lh.fwhm${FWHM}.asl
mv ${DIR}/surf/rh.fwhm${FWHM}.asl ${DIR}/${output}/rh.fwhm${FWHM}.asl

rm -f ${DIR}/surf/lh.asl.w ${DIR}/surf/rh.asl.w ${DIR}/surf/lh.fwhm${FWHM}.asl.w ${DIR}/surf/rh.fwhm${FWHM}.asl.w

# Resample ASL to fsaverage
echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${output}/lh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/lh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fsaverage.asl.mgh --tfmt curv

echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv"
mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${output}/rh.fwhm${FWHM}.asl --sfmt curv --noreshape --no-cortex --tval ${DIR}/${output}/rh.fwhm${FWHM}.fsaverage.asl.mgh --tfmt curv
