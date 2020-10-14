#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
	echo ""
	echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
	echo "  -subj                        : Subject I "
	echo "  -epi                         : fmri file "
	echo "  -fwhmsurf                    : smoothing value (surface) "
	echo "  -prep                        : 1 if do preprocessing; 0 else "
	echo "  -o                           : output directory "
	echo "  -TR                          : TR value "
	echo "  -N                           : Number of slices "
	echo "  -fwhmvol                     : smoothing value (volume) "
	echo "  -refslice                    : slice of reference for slice timing correction "
	echo "  -acquis                      : 'ascending' or 'interleaved' "
	echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
	echo ""
	echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
	echo ""
	exit 1
fi

HOME=/home/renaud
index=1
TR=2.4
N=40
fwhmvol=1.5
refslice=33
acquis=interleaved
resamp=0


while [ $index -le $# ]
do
	eval arg=\${$index}
	case "$arg" in
	-h|-help)
		echo ""
		echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -prep                        : 1 if do preprocessing; 0 else "
		echo "  -o                           : output directory "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo ""
		echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
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
	-fwhmsurf)
		index=$[$index+1]
		eval fwhmsurf=\${$index}
		echo "fwhm surface : ${fwhmsurf}"
		;;
	-prep)
		index=$[$index+1]
		eval doprep=\${$index}
		echo "do preprocessing : $doprep"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "output directory : $outdir"
		;;
	-TR)
		index=$[$index+1]
		eval TR=\${$index}
		echo "TR value : ${TR}"
		;;
	-N)
		index=$[$index+1]
		eval N=\${$index}
		echo "number of slices : ${N}"
		;;
	-fwhmvol)
		index=$[$index+1]
		eval fwhmvol=\${$index}
		echo "fwhm volume : ${fwhmvol}"
		;;
	-refslice)
		index=$[$index+1]
		eval refslice=\${$index}
		echo "slice of reference : ${refslice}"
		;;
	-acquis)
		index=$[$index+1]
		eval acquis=\${$index}
		echo "acquisition : ${acquis}"
		;;
	-resampling)
		index=$[$index+1]
		eval resamp=\${$index}
		echo "resampling : ${resamp}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
		echo ""
		echo "  -sd                          : Path to FreeSurfer output directory (i.e. SUBJECTS_DIR)"
		echo "  -subj                        : Subject I "
		echo "  -epi                         : fmri file "
		echo "  -fwhmsurf                    : smoothing value (surface) "
		echo "  -prep                        : 1 if do preprocessing; 0 else "
		echo "  -o                           : output directory "
		echo "  -TR                          : TR value "
		echo "  -N                           : Number of slices "
		echo "  -fwhmvol                     : smoothing value (volume) "
		echo "  -refslice                    : slice of reference for slice timing correction "
		echo "  -acquis                      : 'ascending' or 'interleaved' "
		echo "  -resampling                  : '0' = no resampling ; '1' = resampling epi on anat "
		echo ""
		echo "Usage: Project_FMRI.sh -sd <SUBJECTS_DIR>  -subj <SUBJ_ID>  -epi <fmri_file>  -fwhmsurf <value>  -prep <value>  -o <folder>  [-TR <value>  -N <value>  -fwhmvol <value>  -refslice <value>  -acquis <name>  -resampling <value>]"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done

## Check mandatory arguments
if [ -z ${SUBJECTS_DIR} ]
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

if [ -z ${fwhmsurf} ]
then
	 echo "-fwhmsurf argument mandatory"
	 exit 1
fi

if [ -z ${doprep} ]
then
	 echo "-prep argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi


DIR="${SD}/${SUBJ}"
SUBJECTS_DIR=${SD}

## Creates out dir
if [ ! -d ${DIR}/${outdir} ]
then
	echo "mkdir ${DIR}/${outdir}"
	mkdir ${DIR}/${outdir}
fi

## Creates log dir
if [ ! -d ${DIR}/fmri/log ]
then
	echo "mkdir ${DIR}/${outdir}/log"
	mkdir ${DIR}/${outdir}/log
fi

if [ ! -f ${DIR}/${outdir}/T1_las.nii ]
then
	echo "mri_convert ${DIR}/mri/T1.mgz ${DIR}/${outdir}/T1_las.nii --out_orientation LAS"
	mri_convert ${DIR}/mri/T1.mgz ${DIR}/${outdir}/T1_las.nii --out_orientation LAS
fi

#=========================================================================================
#                           PREPROCESSING WITH SPM8
#=========================================================================================
if [ ${doprep} -eq 1 ]
then 

	if [ ! -d ${DIR}/${outdir}/spm ]
	then
		mkdir ${DIR}/${outdir}/spm
	else
		rm -rf ${DIR}/${outdir}/spm/*
	fi

	echo "fslsplit ${epi} ${DIR}/${outdir}/spm/epi_ -t"
	fslsplit ${epi} ${DIR}/${outdir}/spm/epi_ -t
	echo "gunzip ${DIR}/${outdir}/spm/*.gz"
	gunzip ${DIR}/${outdir}/spm/*.gz

	echo "${DIR}/${outdir}/spm"
	cd ${DIR}/${outdir}/spm

	echo "FMRI_PreprocessingSPM8ForProj('${DIR}/${outdir}/spm','${DIR}/${outdir}/T1_las.nii',${TR},${N},${refslice},${fwhmvol},'${acquis}',${resamp});"
	matlab -nodisplay <<EOF

	% Load Matlab Path
	cd ${HOME}
	p = pathdef;
	addpath(p);

	FMRI_PreprocessingSPM8ForProj('${DIR}/${outdir}/spm','${DIR}/${outdir}/T1_las.nii',${TR},${N},${refslice},${fwhmvol},'${acquis}',${resamp});
  
EOF

	echo "cd ${DIR}/${outdir}" 
	cd ${DIR}/${outdir}
	echo "fslmerge -t ${DIR}/${outdir}/epi_pre.nii ${DIR}/${outdir}/spm/s*"
	fslmerge -t ${DIR}/${outdir}/epi_pre.nii ${DIR}/${outdir}/spm/s*
	echo "gunzip ${DIR}/${outdir}/epi_pre.nii.gz"
	gunzip ${DIR}/${outdir}/epi_pre.nii.gz

else
	echo "no preprocessing"
fi

if [ ! -f ${DIR}/${outdir}/epi_pre.nii ]
then
	echo "no preprocessing epi file"
	exit 1
fi

#=========================================================================================
#                              Project FMRI onto surface
#=========================================================================================
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

i=0	
for image in `ls ${DIR}/${outdir}/spm/s*`
do
	A=$(printf "%.4d" ${i})
	echo ""
	echo ${A}

	# Only projection on surface subject
	echo "mri_vol2surf --mov ${image} --hemi lh --surf mid --o lh.fwhm${fwhmsurf}_fmri_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhmsurf}"
	mri_vol2surf --mov ${image} --hemi lh --surf mid --o lh.fwhm${fwhmsurf}_fmri_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhmsurf}

	echo "mri_vol2surf --mov ${image} --hemi rh --surf mid --o rh.fwhm${fwhmsurf}_fmri_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhmsurf}"
	mri_vol2surf --mov ${image} --hemi rh --surf mid --o rh.fwhm${fwhmsurf}_fmri_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhmsurf}

	echo "mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${fwhmsurf}_fmri_${A}.w lh.fwhm${fwhmsurf}_fmri_${A}"
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.fwhm${fwhmsurf}_fmri_${A}.w lh.fwhm${fwhmsurf}_fmri_${A}

	echo "mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${fwhmsurf}_fmri_${A}.w rh.fwhm${fwhmsurf}_fmri_${A}"
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.fwhm${fwhmsurf}_fmri_${A}.w rh.fwhm${fwhmsurf}_fmri_${A}
	
	mv ${DIR}/surf/lh.fwhm${fwhmsurf}_fmri_${A} ${DIR}/${outdir}/lh.fwhm${fwhmsurf}_fmri_${A}
	mv ${DIR}/surf/rh.fwhm${fwhmsurf}_fmri_${A} ${DIR}/${outdir}/rh.fwhm${fwhmsurf}_fmri_${A}

	rm -f ${DIR}/surf/lh.fwhm${fwhmsurf}_fmri_${A}.w
	rm -f ${DIR}/surf/rh.fwhm${fwhmsurf}_fmri_${A}.w 

	# Resample to fsaverage
	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${outdir}/lh.fwhm${fwhmsurf}_fmri_${A} --sfmt curv --noreshape --no-cortex --tval ${DIR}/${outdir}/lh.fsaverage_fwhm${fwhmsurf}_fmri_${A}.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi lh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi lh --trgsurfreg sphere.reg --sval ${DIR}/${outdir}/lh.fwhm${fwhmsurf}_fmri_${A} --sfmt curv --noreshape --no-cortex --tval ${DIR}/${outdir}/lh.fsaverage_fwhm${fwhmsurf}_fmri_${A}.mgh --tfmt curv

	echo "mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${outdir}/rh.fwhm${fwhmsurf}_fmri_${A} --sfmt curv --noreshape --no-cortex --tval ${DIR}/${outdir}/rh.fsaverage_fwhm${fwhmsurf}_fmri_${A}.mgh --tfmt curv"
	mri_surf2surf --srcsubject ${SUBJ} --srchemi rh --srcsurfreg sphere.reg --trgsubject fsaverage --trghemi rh --trgsurfreg sphere.reg --sval ${DIR}/${outdir}/rh.fwhm${fwhmsurf}_fmri_${A} --sfmt curv --noreshape --no-cortex --tval ${DIR}/${outdir}/rh.fsaverage_fwhm${fwhmsurf}_fmri_${A}.mgh --tfmt curv

	i=$[$i+1]
done


