#! /bin/bash

if [ $# -lt 4 ]
then
	echo ""
	echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir> "
	echo ""
	echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                            : Subject ID"
	echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
	echo "  -o                               : PET directory "
	echo ""
	echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM> "
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
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir> "
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : PET directory "
		echo ""
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM> "
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
		eval PETDIR=\${$index}
		echo "PET directory : $PETDIR"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID> -fwhm <FWHM>  -o <pet_dir> "
		echo ""
		echo "  -sd                              : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                            : Subject ID"
		echo "  -fwhm <FWHM>                     : Set FWHM of surface kernel blur"
		echo "  -o                               : PET directory "
		echo ""
		echo "Usage: PET_ProjectOnSurface.sh -sd <SUBJCETS_DIR>  -subj <SUBJ_ID>  -fwhm <FWHM> "
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

export FREESURFER_HOME=/home/global/freesurfer5.1/
. ${FREESURFER_HOME}/SetUpFreeSurfer.sh

DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

### ***********************************************************************************************************************
#PET
### ***********************************************************************************************************************

if [ ! -f ${DIR}/${PETDIR}/pet_las.nii ]
then
	echo "need a pet file named pet_las.nii"
else
	if [ ! -f ${DIR}/${PETDIR}/T1_las.nii ]
	then
		mri_convert ${DIR}/mri/T1.mgz ${DIR}/${PETDIR}/T1_las.nii --out_orientation LAS
	fi
	if [ ! -r ${DIR}/${PETDIR}/pve ]
	then
	
/usr/local/matlab11/bin/matlab -nodisplay <<EOF
		% Load Matlab Path
		cd ${HOME}
		p = pathdef;
		addpath(p);
		cd ${DIR}

		%run_pve('${DIR}/${PETDIR}/T1_las.nii','${DIR}/${PETDIR}/pet_las.nii','${DIR}/${PETDIR}/pve');
		HOME = getenv('HOME');
    		configfile = [HOME, '/SVN/matlab/pierre/pve/config_pvec'];
		%run_pve('${DIR}/${PETDIR}/T1_las.nii','${DIR}/${PETDIR}/pet_las.nii','${DIR}/${PETDIR}/pve',configfile,'${DIR}',[8 47]);
		run_pve('${DIR}/${PETDIR}/T1_las.nii','${DIR}/${PETDIR}/pet_las.nii','${DIR}/${PETDIR}/pve',configfile);
	
EOF
	fi

	### ***********************************************************************************************************************
	### 

	echo "mri_convert ${DIR}/${PETDIR}/pve/t1_MGRousset.img ${DIR}/${PETDIR}/pve/t1_MGRousset.mnc"
	mri_convert ${DIR}/${PETDIR}/pve/t1_MGRousset.img ${DIR}/${PETDIR}/pve/t1_MGRousset.mnc

	echo "mincblur -fwhm 2 ${DIR}/${PETDIR}/pve/t1_MGRousset.mnc ${DIR}/${PETDIR}/pve/t1_MGRousset_2 -clobber"
	mincblur -fwhm 2 ${DIR}/${PETDIR}/pve/t1_MGRousset.mnc ${DIR}/${PETDIR}/pve/t1_MGRousset_2 -clobber

	echo "mri_convert ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mnc ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz"
	mri_convert ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mnc ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz


	rm -f ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mnc ${DIR}/${PETDIR}/pve/t1_MGRousset.mnc

	#Project Hypometabolism on surface
	###*************************************************************

/usr/local/matlab11/bin/matlab -nodisplay <<EOF
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


	echo "mri_vol2surf --mov ${DIR}/${PETDIR}/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/${PETDIR}/1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
	mri_vol2surf --mov ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz --hemi lh --surf mid --o lh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

	echo "mri_vol2surf --mov ${DIR}/${PETDIR}/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.intensity.w --regheader ${SUBJ} --out_type paint"
	mri_vol2surf --mov ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.pet.w --regheader ${SUBJ} --out_type paint

	echo "mri_vol2surf --mov ${DIR}/${PETDIR}/1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.intensity.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}"
	mri_vol2surf --mov ${DIR}/${PETDIR}/pve/t1_MGRousset_2_blur.mgz --hemi rh --surf mid --o rh.fwhm${FWHM}.pet.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${FWHM}

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.intensity.w lh.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.pet.w lh.pet

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.intensity.w rh.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.pet.w rh.pet

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.intensity.w lh.fwhm${FWHM}.intensity"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${FWHM}.pet.w lh.fwhm${FWHM}.pet

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.intensity.w rh.fwhm${FWHM}.intensity"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${FWHM}.pet.w rh.fwhm${FWHM}.pet

	mv ${DIR}/surf/lh.pet ${DIR}/${PETDIR}/lh.pet
	mv ${DIR}/surf/rh.pet ${DIR}/${PETDIR}/rh.pet
	mv ${DIR}/surf/lh.fwhm${FWHM}.pet ${DIR}/${PETDIR}/lh.fwhm${FWHM}.pet
	mv ${DIR}/surf/rh.fwhm${FWHM}.pet ${DIR}/${PETDIR}/rh.fwhm${FWHM}.pet

	rm -f ${DIR}/surf/lh.pet.w ${DIR}/surf/rh.pet.w ${DIR}/surf/lh.fwhm${FWHM}.pet.w ${DIR}/surf/rh.fwhm${FWHM}.pet.w

	# Resample hypometabolism to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${PETDIR}/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/lh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${PETDIR}/lh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/lh.fsaverage.pet.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${PETDIR}/lh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/lh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/rh.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${PETDIR}/rh.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/rh.fsaverage.pet.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/epilepsy/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${PETDIR}/rh.fwhm${FWHM}.pet --sfmt curv --noreshape --no-cortex --tval ${DIR}/${PETDIR}/rh.fwhm${FWHM}.fsaverage.pet.mgh --tfmt curv

	rm -f ${DIR}/${PETDIR}/pve/cmdline.txt  ${DIR}/${PETDIR}/pve/pet.hdr  ${DIR}/${PETDIR}/pve/pet.img  ${DIR}/${PETDIR}/pve/t1_CSWMROI.hdr  ${DIR}/${PETDIR}/pve/t1_CSWMROI.img  ${DIR}/${PETDIR}/pve/t1_GMROI.hdr  ${DIR}/${PETDIR}/pve/t1_GMROI.img  ${DIR}/${PETDIR}/pve/t1.hdr  ${DIR}/${PETDIR}/pve/t1.img  ${DIR}/${PETDIR}/pve/t1_Meltzer.hdr  ${DIR}/${PETDIR}/pve/t1_Meltzer.img  ${DIR}/${PETDIR}/pve/t1_MGCS.hdr  ${DIR}/${PETDIR}/pve/t1_MGCS.img  ${DIR}/${PETDIR}/pve/t1_Occu_Meltzer.hdr  ${DIR}/${PETDIR}/pve/t1_Occu_Meltzer.img  ${DIR}/${PETDIR}/pve/t1_Occu_MG.hdr  ${DIR}/${PETDIR}/pve/t1_Occu_MG.img  ${DIR}/${PETDIR}/pve/t1_PSF.hdr  ${DIR}/${PETDIR}/pve/t1_PSF.img  ${DIR}/${PETDIR}/pve/t1_pve.txt  ${DIR}/${PETDIR}/pve/t1_Rousset.Mat  ${DIR}/${PETDIR}/pve/t1_seg1.hdr  ${DIR}/${PETDIR}/pve/t1_seg1.img  ${DIR}/${PETDIR}/pve/t1_seg2.hdr  ${DIR}/${PETDIR}/pve/t1_seg2.img  ${DIR}/${PETDIR}/pve/t1_seg3.hdr  ${DIR}/${PETDIR}/pve/t1_seg3.img  ${DIR}/${PETDIR}/pve/t1_seg8.mat  ${DIR}/${PETDIR}/pve/t1_Virtual_PET.hdr  ${DIR}
/${PETDIR}/pve/t1_Virtual_PET.img

fi

