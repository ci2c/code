#! /bin/bash

if [ $# -lt 12 ]
then
	echo ""
	echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "  -i                           : Path to epi data "
	echo "  -fs                          : Path to freesurfer data "
	echo "  -sid			     : subject id "
	echo "  -fwhm                        : smoothing value "
	echo "  -o                           : Output directory"
	echo "  -pref                        : Output files prefix" 
	echo ""
	echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
	echo ""
	echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
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
		echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -i                           : Path to epi data "
		echo "  -fs                          : Path to freesurfer data "
		echo "  -sid			     : subject id "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
		echo ""
		exit 1
		;;
	-i)
		index=$[$index+1]
		eval epi=\${$index}
		echo "epi data : ${epi}"
		;;
	-fs)
		index=$[$index+1]
		eval SUBJECTS_DIR=\${$index}
		echo "freesurfer directory : ${SUBJECTS_DIR}"
		;;
	-sid)
		index=$[$index+1]
		eval SUBJ=\${$index}
		echo "Subject id : ${SUBJ}"
		;;
	-fwhm)
		index=$[$index+1]
		eval fwhm=\${$index}
		echo "fwhm : ${fwhm}"
		;;
	-o)
		index=$[$index+1]
		eval outdir=\${$index}
		echo "Output directory : ${outdir}"
		;;
	-pref)
		index=$[$index+1]
		eval pref=\${$index}
		echo "Output prefix : ${pref}"
		;;
	-*)
		eval infile=\${$index}
		echo "${infile} : unknown option"
		echo ""
		echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "  -i                           : Path to epi data "
		echo "  -fs                          : Path to freesurfer data "
		echo "  -sid			     : subject id "
		echo "  -fwhm                        : smoothing value "
		echo "  -o                           : Output directory"
		echo "  -pref                        : Output files prefix" 
		echo ""
		echo "Usage:  ProjFMRIOnSurf_FS.sh  -i <data_path>  -fs <fs_path>  -sid <subject>  -fwhm <value>  -o <output_directory>  -pref <output_prefix>"
		echo ""
		echo "Author: Renaud Lopes - CHRU Lille - Jan 20, 2012"
		echo ""
		exit 1
		;;
	esac
	index=$[$index+1]
done


## Check mandatory arguments
if [ -z ${epi} ]
then
	 echo "-i argument mandatory"
	 exit 1
fi

if [ -z ${SUBJECTS_DIR} ]
then
	 echo "-fs argument mandatory"
	 exit 1
fi

if [ -z ${SUBJ} ]
then
	 echo "-sid argument mandatory"
	 exit 1
fi

if [ -z ${fwhm} ]
then
	 echo "-fwhm argument mandatory"
	 exit 1
fi

if [ -z ${outdir} ]
then
	 echo "-o argument mandatory"
	 exit 1
fi

if [ -z ${pref} ]
then
	 echo "-pref argument mandatory"
	 exit 1
fi

DIR="${SUBJECTS_DIR}/${SUBJ}"

## Creates out dir
if [ ! -d ${outdir} ]
then
	mkdir ${outdir}
fi

## Creates log dir
if [ ! -d ${outdir}/log ]
then
	mkdir ${outdir}/log
fi

#=================================================================================
## BUILD MID SURFACE

if [ ! -f "${DIR}"/surf/lh.mid ]
then
echo "${DIR}"/surf/lh.mid
matlab -nodisplay <<EOF
% Load Matlab Path
cd ${HOME}
p = pathdef;
addpath(p);
 
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
else
echo "Already done"
fi

#=================================================================================
## BUILD FMRI SURFACE

# Split EPI time-series into separate volumes.
if [ ! -f "${outdir}"/epi0000.nii.gz ]
then
	pathcur=pwd
	cd ${outdir}
	echo "fslsplit ${epi} epi -t"
	fslsplit ${epi} epi -t
	cd ${pathcur}
else
	echo "fslsplit: Already done"
fi

i=0	
for image in `ls ${outdir}/epi*`
do
	A=$(printf "%.4d" ${i})
	echo ""
	echo ${A}
	
	mri_vol2surf --mov ${image} --hemi lh --surf mid --o lh.epi_${fwhm}_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhm}
	mris_w_to_curv ${SUBJ} lh ${DIR}/surf/lh.epi_${fwhm}_${A}.w ${outdir}/lh.epi_${fwhm}_${A}

	mri_vol2surf --mov ${image} --hemi rh --surf mid --o rh.epi_${fwhm}_${A}.w --regheader ${SUBJ} --out_type paint --surf-fwhm ${fwhm} 
	mris_w_to_curv ${SUBJ} rh ${DIR}/surf/rh.epi_${fwhm}_${A}.w ${outdir}/rh.epi_${fwhm}_${A}

	i=$[$i+1]
done

echo "rm -f ${DIR}/surf/*.w"
rm -f ${DIR}/surf/*.w




